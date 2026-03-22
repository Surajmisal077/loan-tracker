class LoanModel {
  final String loanId;
  final String userId;
  final String userName;
  final String loanType;
  final double totalAmount;
  final double usedAmount;
  final String status;
  final String purpose;
  final DateTime createdAt;
  final String? officerNote;

  // ✅ नवीन fields
  final String mobile;
  final String address;
  final String tal;
  final String dist;
  final String pinCode;
  final Map<String, String> documentUrls;

  LoanModel({
    required this.loanId,
    required this.userId,
    required this.userName,
    required this.loanType,
    required this.totalAmount,
    required this.usedAmount,
    required this.status,
    required this.purpose,
    required this.createdAt,
    this.officerNote,
    this.mobile = '',
    this.address = '',
    this.tal = '',
    this.dist = '',
    this.pinCode = '',
    this.documentUrls = const {},
  });

  double get remainingAmount => totalAmount - usedAmount;

  double get utilizationPercentage {
    if (totalAmount <= 0) return 0;
    return (usedAmount / totalAmount * 100).clamp(0, 100);
  }

  Map<String, dynamic> toMap() {
    return {
      'loanId': loanId,
      'userId': userId,
      'userName': userName,
      'loanType': loanType,
      'totalAmount': totalAmount,
      'usedAmount': usedAmount,
      'status': status,
      'purpose': purpose,
      'createdAt': createdAt.toIso8601String(),
      'officerNote': officerNote ?? '',
      // ✅ नवीन fields
      'mobile': mobile,
      'address': address,
      'tal': tal,
      'dist': dist,
      'pinCode': pinCode,
      'documentUrls': documentUrls,
    };
  }

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      loanId: map['loanId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      loanType: map['loanType'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      usedAmount: (map['usedAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      purpose: map['purpose'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      officerNote: map['officerNote'] ?? '',
      // ✅ नवीन fields
      mobile: map['mobile'] ?? '',
      address: map['address'] ?? '',
      tal: map['tal'] ?? '',
      dist: map['dist'] ?? '',
      pinCode: map['pinCode'] ?? '',
      documentUrls: map['documentUrls'] != null
          ? Map<String, String>.from(map['documentUrls'])
          : {},
    );
  }

  LoanModel copyWith({
    String? loanId,
    String? userId,
    String? userName,
    String? loanType,
    double? totalAmount,
    double? usedAmount,
    String? status,
    String? purpose,
    DateTime? createdAt,
    String? officerNote,
    String? mobile,
    String? address,
    String? tal,
    String? dist,
    String? pinCode,
    Map<String, String>? documentUrls,
  }) {
    return LoanModel(
      loanId: loanId ?? this.loanId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      loanType: loanType ?? this.loanType,
      totalAmount: totalAmount ?? this.totalAmount,
      usedAmount: usedAmount ?? this.usedAmount,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      createdAt: createdAt ?? this.createdAt,
      officerNote: officerNote ?? this.officerNote,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      tal: tal ?? this.tal,
      dist: dist ?? this.dist,
      pinCode: pinCode ?? this.pinCode,
      documentUrls: documentUrls ?? this.documentUrls,
    );
  }
}
