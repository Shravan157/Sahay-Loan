import 'dart:convert';

/// Provider Document Model - Business KYC Documents
/// Similar to how banks and fintech companies collect business documents
class ProviderDocumentModel {
  final String uid;
  final String companyId;
  
  // Company Registration Documents
  final BusinessDocument? certificateOfIncorporation;
  final BusinessDocument? memorandumOfAssociation;
  final BusinessDocument? articlesOfAssociation;
  final BusinessDocument? partnershipDeed;
  final BusinessDocument? llpAgreement;
  
  // Tax & Compliance Documents
  final BusinessDocument? gstCertificate;
  final BusinessDocument? panCard;
  final BusinessDocument? tanCertificate;
  final BusinessDocument? shopActLicense;
  
  // Financial Documents
  final BusinessDocument? bankStatement;
  final BusinessDocument? auditedFinancials;
  final BusinessDocument? itrFiling;
  
  // Regulatory Documents
  final BusinessDocument? nbfcLicense;
  final BusinessDocument? rbiRegistration;
  final BusinessDocument? sebiRegistration;
  
  // Operational Documents
  final BusinessDocument? officeAddressProof;
  final BusinessDocument? boardResolution;
  final BusinessDocument? authorizedSignatoryProof;
  
  // Director/Partner KYC
  final List<DirectorKYC>? directorsKyc;
  
  // Document Status
  final String verificationStatus;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  
  ProviderDocumentModel({
    required this.uid,
    required this.companyId,
    this.certificateOfIncorporation,
    this.memorandumOfAssociation,
    this.articlesOfAssociation,
    this.partnershipDeed,
    this.llpAgreement,
    this.gstCertificate,
    this.panCard,
    this.tanCertificate,
    this.shopActLicense,
    this.bankStatement,
    this.auditedFinancials,
    this.itrFiling,
    this.nbfcLicense,
    this.rbiRegistration,
    this.sebiRegistration,
    this.officeAddressProof,
    this.boardResolution,
    this.authorizedSignatoryProof,
    this.directorsKyc,
    this.verificationStatus = 'pending',
    this.rejectionReason,
    this.submittedAt,
    this.verifiedAt,
    this.verifiedBy,
  });

  factory ProviderDocumentModel.fromJson(Map<String, dynamic> json) {
    return ProviderDocumentModel(
      uid: json['uid'] ?? '',
      companyId: json['company_id'] ?? '',
      certificateOfIncorporation: json['certificate_of_incorporation'] != null
          ? BusinessDocument.fromJson(json['certificate_of_incorporation'])
          : null,
      memorandumOfAssociation: json['memorandum_of_association'] != null
          ? BusinessDocument.fromJson(json['memorandum_of_association'])
          : null,
      articlesOfAssociation: json['articles_of_association'] != null
          ? BusinessDocument.fromJson(json['articles_of_association'])
          : null,
      partnershipDeed: json['partnership_deed'] != null
          ? BusinessDocument.fromJson(json['partnership_deed'])
          : null,
      llpAgreement: json['llp_agreement'] != null
          ? BusinessDocument.fromJson(json['llp_agreement'])
          : null,
      gstCertificate: json['gst_certificate'] != null
          ? BusinessDocument.fromJson(json['gst_certificate'])
          : null,
      panCard: json['pan_card'] != null
          ? BusinessDocument.fromJson(json['pan_card'])
          : null,
      tanCertificate: json['tan_certificate'] != null
          ? BusinessDocument.fromJson(json['tan_certificate'])
          : null,
      shopActLicense: json['shop_act_license'] != null
          ? BusinessDocument.fromJson(json['shop_act_license'])
          : null,
      bankStatement: json['bank_statement'] != null
          ? BusinessDocument.fromJson(json['bank_statement'])
          : null,
      auditedFinancials: json['audited_financials'] != null
          ? BusinessDocument.fromJson(json['audited_financials'])
          : null,
      itrFiling: json['itr_filing'] != null
          ? BusinessDocument.fromJson(json['itr_filing'])
          : null,
      nbfcLicense: json['nbfc_license'] != null
          ? BusinessDocument.fromJson(json['nbfc_license'])
          : null,
      rbiRegistration: json['rbi_registration'] != null
          ? BusinessDocument.fromJson(json['rbi_registration'])
          : null,
      sebiRegistration: json['sebi_registration'] != null
          ? BusinessDocument.fromJson(json['sebi_registration'])
          : null,
      officeAddressProof: json['office_address_proof'] != null
          ? BusinessDocument.fromJson(json['office_address_proof'])
          : null,
      boardResolution: json['board_resolution'] != null
          ? BusinessDocument.fromJson(json['board_resolution'])
          : null,
      authorizedSignatoryProof: json['authorized_signatory_proof'] != null
          ? BusinessDocument.fromJson(json['authorized_signatory_proof'])
          : null,
      directorsKyc: json['directors_kyc'] != null
          ? (json['directors_kyc'] as List)
              .map((d) => DirectorKYC.fromJson(d))
              .toList()
          : null,
      verificationStatus: json['verification_status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'])
          : null,
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'])
          : null,
      verifiedBy: json['verified_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'company_id': companyId,
      'certificate_of_incorporation': certificateOfIncorporation?.toJson(),
      'memorandum_of_association': memorandumOfAssociation?.toJson(),
      'articles_of_association': articlesOfAssociation?.toJson(),
      'partnership_deed': partnershipDeed?.toJson(),
      'llp_agreement': llpAgreement?.toJson(),
      'gst_certificate': gstCertificate?.toJson(),
      'pan_card': panCard?.toJson(),
      'tan_certificate': tanCertificate?.toJson(),
      'shop_act_license': shopActLicense?.toJson(),
      'bank_statement': bankStatement?.toJson(),
      'audited_financials': auditedFinancials?.toJson(),
      'itr_filing': itrFiling?.toJson(),
      'nbfc_license': nbfcLicense?.toJson(),
      'rbi_registration': rbiRegistration?.toJson(),
      'sebi_registration': sebiRegistration?.toJson(),
      'office_address_proof': officeAddressProof?.toJson(),
      'board_resolution': boardResolution?.toJson(),
      'authorized_signatory_proof': authorizedSignatoryProof?.toJson(),
      'directors_kyc': directorsKyc?.map((d) => d.toJson()).toList(),
      'verification_status': verificationStatus,
      'rejection_reason': rejectionReason,
      'submitted_at': submittedAt?.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by': verifiedBy,
    };
  }

  // Get completion percentage - For testing, we consider any 1 document as 20%
  double get completionPercentage {
    final docs = [
      certificateOfIncorporation,
      gstCertificate,
      panCard,
      bankStatement,
      officeAddressProof,
      memorandumOfAssociation,
      articlesOfAssociation,
      partnershipDeed,
      llpAgreement,
    ];
    final uploaded = docs.where((d) => d != null && d.isUploaded).length;
    if (uploaded == 0) return 0;
    // Cap at 100%, but 5 documents give 100%
    return (uploaded / 5).clamp(0.0, 1.0) * 100;
  }

  // Check if all required documents are uploaded - Relaxed for testing
  bool get isComplete {
    // Return true if at least ONE document is uploaded
    return certificateOfIncorporation?.isUploaded == true ||
           gstCertificate?.isUploaded == true ||
           panCard?.isUploaded == true ||
           bankStatement?.isUploaded == true ||
           officeAddressProof?.isUploaded == true;
  }

  // Get list of missing required documents
  List<String> get missingDocuments {
    final missing = <String>[];
    if (certificateOfIncorporation?.isUploaded != true) missing.add('Certificate of Incorporation');
    if (gstCertificate?.isUploaded != true) missing.add('GST Certificate');
    if (panCard?.isUploaded != true) missing.add('Company PAN Card');
    if (bankStatement?.isUploaded != true) missing.add('Bank Statement');
    if (officeAddressProof?.isUploaded != true) missing.add('Office Address Proof');
    return missing;
  }
}

/// Individual Business Document
class BusinessDocument {
  final String documentType;
  final String documentName;
  final String? fileUrl;
  final String? fileName;
  final String? fileBase64;
  final String? extractedText;
  final Map<String, dynamic>? extractedData;
  final String status;
  final String? rejectionReason;
  final DateTime? uploadedAt;
  final DateTime? verifiedAt;

  BusinessDocument({
    required this.documentType,
    required this.documentName,
    this.fileUrl,
    this.fileName,
    this.fileBase64,
    this.extractedText,
    this.extractedData,
    this.status = 'pending',
    this.rejectionReason,
    this.uploadedAt,
    this.verifiedAt,
  });

  factory BusinessDocument.fromJson(Map<String, dynamic> json) {
    return BusinessDocument(
      documentType: json['document_type'] ?? '',
      documentName: json['document_name'] ?? '',
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      fileBase64: json['file_base64'],
      extractedText: json['extracted_text'],
      extractedData: json['extracted_data'],
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'])
          : null,
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_type': documentType,
      'document_name': documentName,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_base64': fileBase64,
      'extracted_text': extractedText,
      'extracted_data': extractedData,
      'status': status,
      'rejection_reason': rejectionReason,
      'uploaded_at': uploadedAt?.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }

  bool get isUploaded => fileUrl != null || fileBase64 != null;
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';
}

/// Director/Partner KYC Information
class DirectorKYC {
  final String name;
  final String designation;
  final String panNumber;
  final String? aadhaarNumber;
  final BusinessDocument? panCard;
  final BusinessDocument? aadhaarCard;
  final BusinessDocument? addressProof;
  final String? photoUrl;
  final String status;

  DirectorKYC({
    required this.name,
    required this.designation,
    required this.panNumber,
    this.aadhaarNumber,
    this.panCard,
    this.aadhaarCard,
    this.addressProof,
    this.photoUrl,
    this.status = 'pending',
  });

  factory DirectorKYC.fromJson(Map<String, dynamic> json) {
    return DirectorKYC(
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      panNumber: json['pan_number'] ?? '',
      aadhaarNumber: json['aadhaar_number'],
      panCard: json['pan_card'] != null
          ? BusinessDocument.fromJson(json['pan_card'])
          : null,
      aadhaarCard: json['aadhaar_card'] != null
          ? BusinessDocument.fromJson(json['aadhaar_card'])
          : null,
      addressProof: json['address_proof'] != null
          ? BusinessDocument.fromJson(json['address_proof'])
          : null,
      photoUrl: json['photo_url'],
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'designation': designation,
      'pan_number': panNumber,
      'aadhaar_number': aadhaarNumber,
      'pan_card': panCard?.toJson(),
      'aadhaar_card': aadhaarCard?.toJson(),
      'address_proof': addressProof?.toJson(),
      'photo_url': photoUrl,
      'status': status,
    };
  }
}

/// Document Categories for UI Organization
class DocumentCategory {
  final String title;
  final String description;
  final List<DocumentRequirement> documents;
  final bool isRequired;

  DocumentCategory({
    required this.title,
    required this.description,
    required this.documents,
    this.isRequired = false,
  });
}

class DocumentRequirement {
  final String key;
  final String name;
  final String description;
  final List<String> acceptedFormats;
  final int maxSizeMB;
  final bool isRequired;
  final String? sampleImageUrl;

  DocumentRequirement({
    required this.key,
    required this.name,
    required this.description,
    this.acceptedFormats = const ['pdf', 'jpg', 'jpeg', 'png'],
    this.maxSizeMB = 5,
    this.isRequired = false, // All optional for testing/dev
    this.sampleImageUrl,
  });
}

/// Predefined Document Categories
final List<DocumentCategory> providerDocumentCategories = [
  DocumentCategory(
    title: 'Company Registration',
    description: 'Legal documents proving company existence',
    documents: [
      DocumentRequirement(
        key: 'certificate_of_incorporation',
        name: 'Certificate of Incorporation',
        description: 'ROC issued certificate (CIN Number)',
        acceptedFormats: ['pdf', 'jpg', 'png'],
        isRequired: false,
      ),
      DocumentRequirement(
        key: 'memorandum_of_association',
        name: 'Memorandum of Association (MOA)',
        description: 'Company objectives and scope',
        acceptedFormats: ['pdf'],
        isRequired: false,
      ),
      DocumentRequirement(
        key: 'articles_of_association',
        name: 'Articles of Association (AOA)',
        description: 'Company bylaws and regulations',
        acceptedFormats: ['pdf'],
        isRequired: false,
      ),
    ],
  ),
  DocumentCategory(
    title: 'Tax & Compliance',
    description: 'Tax registration and compliance certificates',
    documents: [
      DocumentRequirement(
        key: 'gst_certificate',
        name: 'GST Registration Certificate',
        description: 'Valid GST certificate with GSTIN',
        acceptedFormats: ['pdf', 'jpg', 'png'],
        isRequired: false,
      ),
      DocumentRequirement(
        key: 'pan_card',
        name: 'Company PAN Card',
        description: 'Permanent Account Number of company',
        acceptedFormats: ['pdf', 'jpg', 'png'],
        isRequired: false,
      ),
      DocumentRequirement(
        key: 'tan_certificate',
        name: 'TAN Certificate',
        description: 'Tax Deduction Account Number (if applicable)',
        acceptedFormats: ['pdf', 'jpg', 'png'],
        isRequired: false,
      ),
    ],
  ),
  DocumentCategory(
    title: 'Financial Documents',
    description: 'Financial health and banking information',
    documents: [
      DocumentRequirement(
        key: 'bank_statement',
        name: 'Bank Statement (Last 6 Months)',
        description: 'Company bank account statement',
        acceptedFormats: ['pdf'],
        maxSizeMB: 10,
        isRequired: false,
      ),
      DocumentRequirement(
        key: 'audited_financials',
        name: 'Audited Financial Statements',
        description: 'Last 2 years audited balance sheet & P&L',
        acceptedFormats: ['pdf'],
        maxSizeMB: 10,
        isRequired: false,
      ),
      DocumentRequirement(
        key: 'itr_filing',
        name: 'Income Tax Returns',
        description: 'Last 2 years ITR filing acknowledgement',
        acceptedFormats: ['pdf'],
        isRequired: false,
      ),
    ],
  ),
  DocumentCategory(
    title: 'Regulatory Licenses',
    description: 'Industry-specific regulatory approvals',
    documents: [
      DocumentRequirement(
        key: 'nbfc_license',
        name: 'NBFC License',
        description: 'RBI NBFC registration certificate (if applicable)',
        acceptedFormats: ['pdf', 'jpg', 'png'],
        isRequired: false,
      ),
      DocumentRequirement(
        key: 'rbi_registration',
        name: 'RBI Registration',
        description: 'RBI registration for financial institutions',
        acceptedFormats: ['pdf', 'jpg', 'png'],
        isRequired: false,
      ),
    ],
  ),
  DocumentCategory(
    title: 'Office & Operations',
    description: 'Physical office and operational proofs',
    documents: [
      DocumentRequirement(
        key: 'office_address_proof',
        name: 'Registered Office Address Proof',
        description: 'Electricity bill / Rent agreement / Property deed',
        acceptedFormats: ['pdf', 'jpg', 'png'],
        isRequired: false,
      ),
      DocumentRequirement(
        key: 'board_resolution',
        name: 'Board Resolution',
        description: 'Authorized to partner with SAHAY',
        acceptedFormats: ['pdf'],
        isRequired: false,
      ),
      DocumentRequirement(
        key: 'authorized_signatory_proof',
        name: 'Authorized Signatory ID Proof',
        description: 'PAN & Aadhaar of authorized signatory',
        acceptedFormats: ['pdf', 'jpg', 'png'],
        isRequired: true,
      ),
    ],
  ),
];
