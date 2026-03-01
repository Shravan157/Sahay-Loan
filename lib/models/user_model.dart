class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool kycVerified;
  final String? companyId;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.kycVerified = false,
    this.companyId,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user',
      kycVerified: json['kyc_verified'] ?? false,
      companyId: json['company_id'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'kyc_verified': kycVerified,
      'company_id': companyId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? kycVerified,
    String? companyId,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      kycVerified: kycVerified ?? this.kycVerified,
      companyId: companyId ?? this.companyId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isAdmin => role == 'sahay_admin';
  bool get isProviderAdmin => role == 'provider_admin';
  bool get isUser => role == 'user';
}
