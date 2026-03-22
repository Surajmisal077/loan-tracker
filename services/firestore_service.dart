import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loan_model.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── LOANS ───────────────────────────────────────────────

  Future<bool> addLoan(LoanModel loan) async {
    try {
      await _firestore.collection('loans').doc(loan.loanId).set(loan.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<LoanModel>> getUserLoans(String userId) {
    return _firestore
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LoanModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Stream<List<LoanModel>> getAllLoans() {
    return _firestore
        .collection('loans')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LoanModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<LoanModel?> getLoan(String loanId) async {
    try {
      final doc = await _firestore.collection('loans').doc(loanId).get();
      if (doc.exists) return LoanModel.fromMap(doc.data()!);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateLoanStatus({
    required String loanId,
    required String status,
    String? officerNote,
  }) async {
    try {
      await _firestore.collection('loans').doc(loanId).update({
        'status': status,
        'officerNote': officerNote ?? '',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateLoanUsedAmount({
    required String loanId,
    required double usedAmount,
  }) async {
    try {
      await _firestore.collection('loans').doc(loanId).update({
        'usedAmount': usedAmount,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── EXPENSES ────────────────────────────────────────────

  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      await _firestore
          .collection('expenses')
          .doc(expense.expenseId)
          .set(expense.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<ExpenseModel>> getLoanExpenses(String loanId) {
    return _firestore
        .collection('expenses')
        .where('loanId', isEqualTo: loanId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Stream<List<ExpenseModel>> getUserExpenses(String userId) {
    return _firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // ─── Bill Verification ✅ NEW ─────────────────────────────
  Future<bool> updateExpenseVerification({
    required String expenseId,
    required String verificationStatus,
    required String officerMessage,
    required bool amountDeducted,
  }) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).update({
        'verificationStatus': verificationStatus,
        'officerMessage': officerMessage,
        'amountDeducted': amountDeducted,
        'isValid': verificationStatus == 'valid',
      });
      return true;
    } catch (e) {
      print('❌ updateExpenseVerification error: $e');
      return false;
    }
  }

  // ─── Pending Bills साठी ✅ NEW ────────────────────────────
  Stream<List<ExpenseModel>> getPendingBillExpenses() {
    return _firestore
        .collection('expenses')
        .where('verificationStatus', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // ─── USERS ───────────────────────────────────────────────

  Stream<List<UserModel>> getAllBorrowers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'borrower')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<bool> updateUserProfile({
    required String uid,
    required String fullName,
    required String phone,
    String? profileImage,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fullName': fullName,
        'phone': phone,
        if (profileImage != null) 'profileImage': profileImage,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateOfficerProfile({
    required String uid,
    required String fullName,
    required String phone,
    required String bankName,
    required String designation,
    String? profileImage,
  }) async {
    try {
      await _firestore.collection('officers').doc(uid).update({
        'fullName': fullName,
        'phone': phone,
        'bankName': bankName,
        'designation': designation,
        if (profileImage != null) 'profileImage': profileImage,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── ALERTS ──────────────────────────────────────────────

  Future<bool> sendAlert({
    required String userId,
    required String loanId,
    required String message,
    required String officerId,
  }) async {
    try {
      await _firestore.collection('alerts').add({
        'userId': userId,
        'loanId': loanId,
        'message': message,
        'officerId': officerId,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> getUserAlerts(String userId) {
    return _firestore
        .collection('alerts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> markAlertRead(String alertId) async {
    await _firestore.collection('alerts').doc(alertId).update({'isRead': true});
  }
}
