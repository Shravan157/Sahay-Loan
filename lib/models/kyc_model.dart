class KYCModel {
  final String uid;
  final String name;
  final int age;
  final String occupation;
  final double annualIncome;
  final double monthlyInhandSalary;
  final String phone;
  final String email;
  final String aadhaarNumber;
  final String panNumber;
  final bool kycVerified;
  final DateTime? submittedAt;

  KYCModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.occupation,
    required this.annualIncome,
    required this.monthlyInhandSalary,
    required this.phone,
    required this.email,
    required this.aadhaarNumber,
    required this.panNumber,
    this.kycVerified = false,
    this.submittedAt,
  });

  factory KYCModel.fromJson(Map<String, dynamic> json) {
    return KYCModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      occupation: json['occupation'] ?? '',
      annualIncome: (json['annual_income'] ?? 0).toDouble(),
      monthlyInhandSalary: (json['monthly_inhand_salary'] ?? 0).toDouble(),
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      aadhaarNumber: json['aadhaar_number'] ?? '',
      panNumber: json['pan_number'] ?? '',
      kycVerified: json['kyc_verified'] ?? false,
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'occupation': occupation,
      'annual_income': annualIncome,
      'monthly_inhand_salary': monthlyInhandSalary,
      'phone': phone,
      'email': email,
      'aadhaar_number': aadhaarNumber,
      'pan_number': panNumber,
      'kyc_verified': kycVerified,
      'submitted_at': submittedAt?.toIso8601String(),
    };
  }

  KYCModel copyWith({
    String? uid,
    String? name,
    int? age,
    String? occupation,
    double? annualIncome,
    double? monthlyInhandSalary,
    String? phone,
    String? email,
    String? aadhaarNumber,
    String? panNumber,
    bool? kycVerified,
    DateTime? submittedAt,
  }) {
    return KYCModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      age: age ?? this.age,
      occupation: occupation ?? this.occupation,
      annualIncome: annualIncome ?? this.annualIncome,
      monthlyInhandSalary: monthlyInhandSalary ?? this.monthlyInhandSalary,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      panNumber: panNumber ?? this.panNumber,
      kycVerified: kycVerified ?? this.kycVerified,
      submittedAt: submittedAt ?? this.submittedAt,
    );
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
