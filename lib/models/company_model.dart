class CompanyModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? description;
  final String type;
  final DateTime? createdAt;

  CompanyModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.description,
    required this.type,
    this.createdAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      description: json['description'],
      type: json['type'] ?? 'Bank',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'description': description,
      'type': type,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  CompanyModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? description,
    String? type,
    DateTime? createdAt,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AddCompanyInput {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String? description;
  final String type;

  AddCompanyInput({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.description,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'description': description ?? '',
      'type': type,
    };
  }
}
