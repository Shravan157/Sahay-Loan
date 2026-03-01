import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_endpoints.dart';
import '../models/kyc_model.dart';

class KYCProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String? _error;
  int _currentStep = 0;
  KYCModel? _kycData;
  OCRResult? _aadhaarResult;
  OCRResult? _panResult;
  File? _aadhaarImage;
  File? _panImage;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentStep => _currentStep;
  KYCModel? get kycData => _kycData;
  OCRResult? get aadhaarResult => _aadhaarResult;
  OCRResult? get panResult => _panResult;
  File? get aadhaarImage => _aadhaarImage;
  File? get panImage => _panImage;

  bool get isAadhaarScanned => _aadhaarResult != null && _aadhaarResult!.success;
  bool get isPanScanned => _panResult != null && _panResult!.success;
  bool get canProceedToReview => isAadhaarScanned && isPanScanned;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setKYCData(KYCModel data) {
    _kycData = data;
    notifyListeners();
  }

  Future<bool> pickImage(bool isAadhaar, {bool fromCamera = false}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (isAadhaar) {
          _aadhaarImage = file;
        } else {
          _panImage = file;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to pick image: $e');
      return false;
    }
  }

  Future<bool> scanDocument(bool isAadhaar) async {
    final file = isAadhaar ? _aadhaarImage : _panImage;
    if (file == null) {
      _setError('Please select an image first');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await _api.post(
        ApiEndpoints.ocrScan,
        body: {
          'image_base64': base64Image,
          'doc_type': isAadhaar ? 'aadhaar' : 'pan',
        },
      );

      _setLoading(false);

      if (response.success) {
        final result = OCRResult.fromJson(response.data);
        if (isAadhaar) {
          _aadhaarResult = result;
        } else {
          _panResult = result;
        }
        notifyListeners();
        return result.success;
      } else {
        _setError(response.error);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('Failed to scan document: $e');
      return false;
    }
  }

  Future<bool> submitKYC() async {
    if (_kycData == null) {
      _setError('KYC data is missing');
      return false;
    }

    _setLoading(true);
    _setError(null);

    final response = await _api.post(
      ApiEndpoints.submitKyc,
      body: _kycData!.toJson(),
    );

    _setLoading(false);

    if (response.success) {
      return true;
    } else {
      _setError(response.error);
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _currentStep = 0;
    _kycData = null;
    _aadhaarResult = null;
    _panResult = null;
    _aadhaarImage = null;
    _panImage = null;
    _error = null;
    notifyListeners();
  }

  // Fetch existing KYC data from backend
  Future<bool> fetchKYCData() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _api.get(ApiEndpoints.getKycStatus);
      _setLoading(false);

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        // Check if KYC is verified and has kyc data
        if (data['kyc_verified'] == true && data['kyc'] != null) {
          _kycData = KYCModel.fromJson(data['kyc'] as Map<String, dynamic>);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to fetch KYC data: $e');
      return false;
    }
  }

  // Update existing KYC data
  Future<bool> updateKYC(KYCModel updatedData) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _api.put(
        ApiEndpoints.updateKyc,
        body: updatedData.toJson(),
      );

      _setLoading(false);

      if (response.success) {
        _kycData = updatedData;
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to update KYC');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('Failed to update KYC: $e');
      return false;
    }
  }
}

class OCRResult {
  final String docType;
  final Map<String, dynamic> extracted;
  final bool success;
  final String message;

  OCRResult({
    required this.docType,
    required this.extracted,
    required this.success,
    required this.message,
  });

  factory OCRResult.fromJson(Map<String, dynamic> json) {
    return OCRResult(
      docType: json['doc_type'] ?? '',
      extracted: json['extracted'] ?? {},
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
