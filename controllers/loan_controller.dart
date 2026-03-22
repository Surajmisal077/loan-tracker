import 'dart:io';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/loan_model.dart';
import '../core/utils/helpers.dart';

class LoanController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  final RxList<LoanModel> userLoans = <LoanModel>[].obs;
  final RxList<LoanModel> allLoans = <LoanModel>[].obs;
  final Rx<LoanModel?> selectedLoan = Rx<LoanModel?>(null);
  final RxBool isLoading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  // ─── Load User Loans ─────────────────────────────────────
  void loadUserLoans(String userId) {
    _firestoreService.getUserLoans(userId).listen((loans) {
      userLoans.value = loans;
    });
  }

  // ─── Load All Loans (Officer) ────────────────────────────
  void loadAllLoans() {
    _firestoreService.getAllLoans().listen((loans) {
      allLoans.value = loans;
      // ✅ Debug — URL check
      if (loans.isNotEmpty) {
        for (final loan in loans) {
          if (loan.documentUrls.isNotEmpty) {
            print('📄 Loan: ${loan.loanId}');
            print('📄 Docs: ${loan.documentUrls}');
            loan.documentUrls.forEach((key, url) {
              print('   🔗 $key: $url');
            });
          } else {
            print('⚠️ Loan ${loan.loanId} has no documents');
          }
        }
      }
    });
  }

  // ─── Select Loan ─────────────────────────────────────────
  void selectLoan(LoanModel loan) {
    selectedLoan.value = loan;
    // ✅ Debug
    print('🔍 Selected loan docs: ${loan.documentUrls}');
  }

  // ─── Apply Loan (Borrower) ────────────────────────────────
  Future<bool> applyLoan({
    required String userId,
    required String userName,
    required String loanType,
    required double totalAmount,
    required String purpose,
    required String mobile,
    required String address,
    required String tal,
    required String dist,
    required String pinCode,
    required Map<String, File?> documents,
  }) async {
    isLoading.value = true;
    try {
      final loanId = const Uuid().v4();

      Helpers.showInfo('📤 Uploading documents...');
      final Map<String, String> documentUrls = {};
      final uploadedDocs = documents.entries
          .where((e) => e.value != null)
          .toList();

      for (int i = 0; i < uploadedDocs.length; i++) {
        final entry = uploadedDocs[i];
        uploadProgress.value = (i + 1) / uploadedDocs.length;

        final url = await _storageService.uploadLoanDocument(
          userId: userId,
          loanId: loanId,
          docKey: entry.key,
          imageFile: entry.value!,
        );

        if (url != null) {
          documentUrls[entry.key] = url;
          print('✅ Uploaded ${entry.key}: $url');
        } else {
          print('❌ Failed to upload ${entry.key}');
        }
      }

      print('📦 Total uploaded: ${documentUrls.length}/${uploadedDocs.length}');
      uploadProgress.value = 0.0;

      final loan = LoanModel(
        loanId: loanId,
        userId: userId,
        userName: userName,
        loanType: loanType,
        totalAmount: totalAmount,
        usedAmount: 0,
        status: 'pending',
        purpose: purpose,
        mobile: mobile,
        address: address,
        tal: tal,
        dist: dist,
        pinCode: pinCode,
        documentUrls: documentUrls,
        createdAt: DateTime.now(),
      );

      final success = await _firestoreService.addLoan(loan);

      if (success) {
        loadUserLoans(userId);
        Helpers.showSuccess(
          '✅ Application submitted!\nBank Officer will review it soon.',
        );
      } else {
        Helpers.showError('❌ Failed to submit. Try again.');
      }
      return success;
    } catch (e) {
      print('❌ APPLY LOAN ERROR: $e');
      Helpers.showError('❌ Error: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  // ─── Add Loan (Officer use) ───────────────────────────────
  Future<bool> addLoan({
    required String userId,
    required String userName,
    required String loanType,
    required double totalAmount,
    required String purpose,
  }) async {
    isLoading.value = true;
    try {
      final loanId = const Uuid().v4();
      final loan = LoanModel(
        loanId: loanId,
        userId: userId,
        userName: userName,
        loanType: loanType,
        totalAmount: totalAmount,
        usedAmount: 0,
        status: 'pending',
        purpose: purpose,
        mobile: '',
        address: '',
        tal: '',
        dist: '',
        pinCode: '',
        documentUrls: {},
        createdAt: DateTime.now(),
      );

      final success = await _firestoreService.addLoan(loan);
      if (success) {
        Helpers.showSuccess('Loan added successfully! 🎉');
      } else {
        Helpers.showError('Failed to add loan. Try again.');
      }
      return success;
    } catch (e) {
      Helpers.showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Update Loan Status (Officer) ────────────────────────
  Future<bool> updateLoanStatus({
    required String loanId,
    required String status,
    String? officerNote,
  }) async {
    isLoading.value = true;
    try {
      final success = await _firestoreService.updateLoanStatus(
        loanId: loanId,
        status: status,
        officerNote: officerNote,
      );

      if (success) {
        if (status == 'approved') {
          Helpers.showSuccess('Loan Approved! ✅');
        } else {
          Helpers.showWarning('Loan Rejected ❌');
        }
      } else {
        Helpers.showError('Failed to update status.');
      }
      return success;
    } catch (e) {
      Helpers.showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Update Used Amount ──────────────────────────────────
  Future<bool> updateUsedAmount({
    required String loanId,
    required double newExpenseAmount,
  }) async {
    try {
      final loan = await _firestoreService.getLoan(loanId);
      if (loan == null) return false;

      final newUsedAmount = loan.usedAmount + newExpenseAmount;

      if (newUsedAmount > loan.totalAmount) {
        Helpers.showError('Expense exceeds loan amount! ⚠️');
        return false;
      }

      return await _firestoreService.updateLoanUsedAmount(
        loanId: loanId,
        usedAmount: newUsedAmount,
      );
    } catch (e) {
      Helpers.showError(e.toString());
      return false;
    }
  }

  // ─── Get Loan Types ──────────────────────────────────────
  List<Map<String, String>> getLoanTypes() {
    return [
      {'value': 'agriculture', 'label': '🌾 Agriculture Loan'},
      {'value': 'education', 'label': '🎓 Education Loan'},
      {'value': 'msme', 'label': '🏭 MSME Loan'},
      {'value': 'personal', 'label': '👤 Personal Loan'},
      {'value': 'home', 'label': '🏠 Home Loan'},
    ];
  }

  // ─── Total Stats ─────────────────────────────────────────
  double get totalLoanAmount =>
      userLoans.fold(0, (sum, loan) => sum + loan.totalAmount);

  double get totalUsedAmount =>
      userLoans.fold(0, (sum, loan) => sum + loan.usedAmount);

  double get totalRemainingAmount => totalLoanAmount - totalUsedAmount;

  int get approvedLoansCount =>
      userLoans.where((l) => l.status == 'approved').length;

  int get pendingLoansCount =>
      userLoans.where((l) => l.status == 'pending').length;
}
