import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_endpoints.dart';
import '../models/provider_document_model.dart';

class DocumentProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  String? _error;
  ProviderDocumentModel? _providerDocuments;
  List<ProviderDocumentModel> _pendingVerifications = [];
  double _uploadProgress = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  ProviderDocumentModel? get providerDocuments => _providerDocuments;
  List<ProviderDocumentModel> get pendingVerifications => _pendingVerifications;
  double get uploadProgress => _uploadProgress;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _setUploadProgress(double value) {
    _uploadProgress = value;
    notifyListeners();
  }

  // Load provider documents
  Future<void> loadProviderDocuments(String companyId) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.get(
      ApiEndpoints.providerDocuments(companyId),
    );

    _setLoading(false);

    if (response.success) {
      _providerDocuments = ProviderDocumentModel.fromJson(response.data);
      notifyListeners();
    } else {
      _setError(response.error);
    }
  }

  // Upload a single document
  Future<bool> uploadDocument({
    required String companyId,
    required String documentType,
    required String documentName,
    required File file,
    String? extractedText,
    Map<String, dynamic>? extractedData,
  }) async {
    _setLoading(true);
    _setUploadProgress(0);
    _setError(null);

    try {
      // Read file as base64
      final bytes = await file.readAsBytes();
      final base64File = base64Encode(bytes);

      final response = await _api.post(
        ApiEndpoints.uploadProviderDocument,
        body: {
          'company_id': companyId,
          'document_type': documentType,
          'document_name': documentName,
          'file_base64': base64File,
          'file_name': file.path.split('/').last,
          'extracted_text': extractedText,
          'extracted_data': extractedData,
        },
      );

      _setLoading(false);
      _setUploadProgress(100);

      if (response.success) {
        await loadProviderDocuments(companyId);
        return true;
      } else {
        _setError(response.error);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('Failed to upload document: $e');
      return false;
    }
  }

  // Upload multiple documents
  Future<bool> uploadMultipleDocuments({
    required String companyId,
    required Map<String, BusinessDocument> documents,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.uploadMultipleProviderDocuments,
      body: {
        'company_id': companyId,
        'documents': documents.map((key, doc) => MapEntry(key, doc.toJson())),
      },
    );

    _setLoading(false);

    if (response.success) {
      await loadProviderDocuments(companyId);
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  // Delete a document
  Future<bool> deleteDocument({
    required String companyId,
    required String documentType,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.delete(
      ApiEndpoints.deleteProviderDocument(companyId, documentType),
    );

    _setLoading(false);

    if (response.success) {
      await loadProviderDocuments(companyId);
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  // Submit all documents for verification
  Future<bool> submitForVerification(String companyId) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.submitProviderDocuments(companyId),
      body: {
        'company_id': companyId,
        'submitted_at': DateTime.now().toIso8601String(),
      },
    );

    _setLoading(false);

    if (response.success) {
      await loadProviderDocuments(companyId);
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  // Admin: Verify provider document
  Future<bool> verifyDocument({
    required String companyId,
    required String documentType,
    required bool isApproved,
    String? rejectionReason,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.verifyProviderDocument,
      body: {
        'company_id': companyId,
        'document_type': documentType,
        'is_approved': isApproved,
        'rejection_reason': rejectionReason,
        'verified_at': DateTime.now().toIso8601String(),
      },
    );

    _setLoading(false);

    if (response.success) {
      await loadProviderDocuments(companyId);
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  // Admin: Get all pending provider documents
  Future<List<ProviderDocumentModel>> getPendingVerifications() async {
    _setLoading(true);
    _setError(null);

    final response = await _api.get(
      ApiEndpoints.pendingProviderDocuments,
    );

    _setLoading(false);

    if (response.success) {
      final List<dynamic> docs = response.data['documents'] ?? [];
      _pendingVerifications = docs.map((d) => ProviderDocumentModel.fromJson(d)).toList();
      notifyListeners();
      return _pendingVerifications;
    } else {
      _setError(response.error);
      return [];
    }
  }

  // Admin: Verify entire company
  Future<bool> verifyCompany({
    required String companyId,
    required String status,
    String? reason,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.verifyProviderStatus,
      body: {
        'company_id': companyId,
        'status': status,
        'reason': reason,
      },
    );

    _setLoading(false);

    if (response.success) {
      await getPendingVerifications();
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  // Get document upload status
  String getDocumentStatus(String documentType) {
    if (_providerDocuments == null) return 'not_uploaded';

    final doc = _getDocumentByType(documentType);
    if (doc == null) return 'not_uploaded';
    return doc.status;
  }

  BusinessDocument? _getDocumentByType(String type) {
    switch (type) {
      case 'certificate_of_incorporation':
        return _providerDocuments?.certificateOfIncorporation;
      case 'memorandum_of_association':
        return _providerDocuments?.memorandumOfAssociation;
      case 'articles_of_association':
        return _providerDocuments?.articlesOfAssociation;
      case 'partnership_deed':
        return _providerDocuments?.partnershipDeed;
      case 'llp_agreement':
        return _providerDocuments?.llpAgreement;
      case 'gst_certificate':
        return _providerDocuments?.gstCertificate;
      case 'pan_card':
        return _providerDocuments?.panCard;
      case 'tan_certificate':
        return _providerDocuments?.tanCertificate;
      case 'shop_act_license':
        return _providerDocuments?.shopActLicense;
      case 'bank_statement':
        return _providerDocuments?.bankStatement;
      case 'audited_financials':
        return _providerDocuments?.auditedFinancials;
      case 'itr_filing':
        return _providerDocuments?.itrFiling;
      case 'nbfc_license':
        return _providerDocuments?.nbfcLicense;
      case 'rbi_registration':
        return _providerDocuments?.rbiRegistration;
      case 'sebi_registration':
        return _providerDocuments?.sebiRegistration;
      case 'office_address_proof':
        return _providerDocuments?.officeAddressProof;
      case 'board_resolution':
        return _providerDocuments?.boardResolution;
      case 'authorized_signatory_proof':
        return _providerDocuments?.authorizedSignatoryProof;
      default:
        return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _providerDocuments = null;
    _uploadProgress = 0;
    notifyListeners();
  }
}
