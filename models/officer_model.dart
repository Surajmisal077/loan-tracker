class OfficerModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String bankName;
  final String designation;
  final String? profileImage;
  final DateTime createdAt;

  OfficerModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.bankName,
    required this.designation,
    this.profileImage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'bankName': bankName,
      'designation': designation,
      'profileImage': profileImage ?? '',
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OfficerModel.fromMap(Map<String, dynamic> map) {
    return OfficerModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      bankName: map['bankName'] ?? '',
      designation: map['designation'] ?? '',
      profileImage: map['profileImage'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  OfficerModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? bankName,
    String? designation,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return OfficerModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bankName: bankName ?? this.bankName,
      designation: designation ?? this.designation,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
