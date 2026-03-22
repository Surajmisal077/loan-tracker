import 'package:get/get.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../models/user_model.dart';
import '../models/loan_model.dart';
import '../core/utils/helpers.dart';
import 'loan_controller.dart';

class OfficerController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  final LoanController _loanController = Get.find<LoanController>();

  // Observable Variables
  final RxList<UserModel> allBorrowers = <UserModel>[].obs;
  final Rx<UserModel?> selectedBorrower = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString alertMessage = ''.obs;

  // ─── Load All Borrowers ──────────────────────────────────
  void loadAllBorrowers() {
    _firestoreService.getAllBorrowers().listen((borrowers) {
      allBorrowers.value = borrowers;
    });
  }

  // ─── Select Borrower ─────────────────────────────────────
  void selectBorrower(UserModel borrower) {
    selectedBorrower.value = borrower;
  }

  // ─── Approve Loan ────────────────────────────────────────
  Future<bool> approveLoan({
    required String loanId,
    required String userId,
    String? note,
  }) async {
    isLoading.value = true;
    try {
      final success = await _loanController.updateLoanStatus(
        loanId: loanId,
        status: 'approved',
        officerNote: note,
      );

      if (success) {
        await _notificationService.sendLoanStatusNotification(
          userId: userId,
          loanId: loanId,
          status: 'approved',
        );
      }
      return success;
    } catch (e) {
      Helpers.showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Reject Loan ─────────────────────────────────────────
  Future<bool> rejectLoan({
    required String loanId,
    required String userId,
    String? note,
  }) async {
    isLoading.value = true;
    try {
      final success = await _loanController.updateLoanStatus(
        loanId: loanId,
        status: 'rejected',
        officerNote: note,
      );

      if (success) {
        await _notificationService.sendLoanStatusNotification(
          userId: userId,
          loanId: loanId,
          status: 'rejected',
        );
      }
      return success;
    } catch (e) {
      Helpers.showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Send Alert to Borrower ──────────────────────────────
  Future<bool> sendAlert({
    required String userId,
    required String loanId,
    required String message,
    required String officerId,
  }) async {
    isLoading.value = true;
    try {
      final success = await _firestoreService.sendAlert(
        userId: userId,
        loanId: loanId,
        message: message,
        officerId: officerId,
      );

      if (success) {
        await _notificationService.sendAlertNotification(
          userId: userId,
          loanId: loanId,
          title: '⚠️ Alert from Bank Officer',
          message: message,
          officerId: officerId,
        );
        Helpers.showSuccess('Alert sent successfully! 🚨');
      } else {
        Helpers.showError('Failed to send alert.');
      }
      return success;
    } catch (e) {
      Helpers.showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Get Borrower Loans ──────────────────────────────────
  List<LoanModel> getBorrowerLoans(String userId) {
    return _loanController.allLoans
        .where((loan) => loan.userId == userId)
        .toList();
  }

  // ─── Stats for Officer Dashboard ─────────────────────────
  int get totalBorrowers => allBorrowers.length;

  int get totalLoans => _loanController.allLoans.length;

  int get pendingLoans =>
      _loanController.allLoans.where((l) => l.status == 'pending').length;

  int get approvedLoans =>
      _loanController.allLoans.where((l) => l.status == 'approved').length;

  double get totalDisbursedAmount => _loanController.allLoans
      .where((l) => l.status == 'approved')
      .fold(0, (sum, l) => sum + l.totalAmount);
}
