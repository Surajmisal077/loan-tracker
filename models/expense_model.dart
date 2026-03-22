class ExpenseModel {
  final String expenseId;
  final String loanId;
  final String userId;
  final String category;
  final double amount;
  final String description;
  final String? billImageUrl;
  final String location;
  final DateTime createdAt;
  final bool isValid;

  // ✅ नवीन fields — Bill Verification साठी
  final String verificationStatus; // 'pending', 'valid', 'invalid'
  final String? officerMessage; // Officer चा message
  final bool amountDeducted; // Amount cut झाला का?

  ExpenseModel({
    required this.expenseId,
    required this.loanId,
    required this.userId,
    required this.category,
    required this.amount,
    required this.description,
    this.billImageUrl,
    required this.location,
    required this.createdAt,
    required this.isValid,
    this.verificationStatus = 'pending',
    this.officerMessage,
    this.amountDeducted = false,
  });

  // ✅ Helper getters
  bool get isPending => verificationStatus == 'pending';
  bool get isVerifiedValid => verificationStatus == 'valid';
  bool get isVerifiedInvalid => verificationStatus == 'invalid';
  bool get hasBill => billImageUrl != null && billImageUrl!.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'expenseId': expenseId,
      'loanId': loanId,
      'userId': userId,
      'category': category,
      'amount': amount,
      'description': description,
      'billImageUrl': billImageUrl ?? '',
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'isValid': isValid,
      // ✅ नवीन fields
      'verificationStatus': verificationStatus,
      'officerMessage': officerMessage ?? '',
      'amountDeducted': amountDeducted,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      expenseId: map['expenseId'] ?? '',
      loanId: map['loanId'] ?? '',
      userId: map['userId'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      billImageUrl: map['billImageUrl'] ?? '',
      location: map['location'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      isValid: map['isValid'] ?? true,
      // ✅ नवीन fields — जुन्या data साठी default values
      verificationStatus: map['verificationStatus'] ?? 'pending',
      officerMessage: map['officerMessage'] ?? '',
      amountDeducted: map['amountDeducted'] ?? false,
    );
  }

  ExpenseModel copyWith({
    String? expenseId,
    String? loanId,
    String? userId,
    String? category,
    double? amount,
    String? description,
    String? billImageUrl,
    String? location,
    DateTime? createdAt,
    bool? isValid,
    String? verificationStatus,
    String? officerMessage,
    bool? amountDeducted,
  }) {
    return ExpenseModel(
      expenseId: expenseId ?? this.expenseId,
      loanId: loanId ?? this.loanId,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      billImageUrl: billImageUrl ?? this.billImageUrl,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      isValid: isValid ?? this.isValid,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      officerMessage: officerMessage ?? this.officerMessage,
      amountDeducted: amountDeducted ?? this.amountDeducted,
    );
  }
}
