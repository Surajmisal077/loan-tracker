import 'dart:io';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/expense_model.dart';
import '../core/utils/helpers.dart';
import 'loan_controller.dart';

class ExpenseController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final LoanController _loanController = Get.find<LoanController>();

  final RxList<ExpenseModel> loanExpenses = <ExpenseModel>[].obs;
  final RxList<ExpenseModel> userExpenses = <ExpenseModel>[].obs;
  final Rx<File?> selectedBillImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxString selectedCategory = ''.obs;

  // ─── Load Loan Expenses ──────────────────────────────────
  void loadLoanExpenses(String loanId) {
    _firestoreService.getLoanExpenses(loanId).listen((expenses) {
      loanExpenses.value = expenses;
    });
  }

  // ─── Load User Expenses ──────────────────────────────────
  void loadUserExpenses(String userId) {
    _firestoreService.getUserExpenses(userId).listen((expenses) {
      userExpenses.value = expenses;
    });
  }

  // ─── Pick Bill Image ─────────────────────────────────────
  Future<void> pickBillFromGallery() async {
    final file = await _storageService.pickImageFromGallery();
    if (file != null) {
      selectedBillImage.value = file;
      Helpers.showSuccess('Bill image selected! 📸');
    }
  }

  Future<void> pickBillFromCamera() async {
    final file = await _storageService.pickImageFromCamera();
    if (file != null) {
      selectedBillImage.value = file;
      Helpers.showSuccess('Bill photo taken! 📸');
    }
  }

  void clearSelectedImage() {
    selectedBillImage.value = null;
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  // ─── Add Expense ✅ Amount आता cut होणार नाही ────────────
  Future<bool> addExpense({
    required String loanId,
    required String userId,
    required double amount,
    required String description,
    required String location,
  }) async {
    if (selectedCategory.value.isEmpty) {
      Helpers.showError('Please select a category! ⚠️');
      return false;
    }

    isLoading.value = true;
    try {
      final expenseId = const Uuid().v4();
      String? billImageUrl;

      // Bill upload
      if (selectedBillImage.value != null) {
        isUploading.value = true;
        billImageUrl = await _storageService.uploadBillImage(
          userId: userId,
          expenseId: expenseId,
          imageFile: selectedBillImage.value!,
        );
        isUploading.value = false;
      }

      final expense = ExpenseModel(
        expenseId: expenseId,
        loanId: loanId,
        userId: userId,
        category: selectedCategory.value,
        amount: amount,
        description: description,
        billImageUrl: billImageUrl,
        location: location,
        createdAt: DateTime.now(),
        isValid: true,
        // ✅ नवीन — pending verification
        verificationStatus: billImageUrl != null ? 'pending' : 'valid',
        amountDeducted: billImageUrl == null, // bill नसेल तर लगेच cut
      );

      final success = await _firestoreService.addExpense(expense);

      if (success) {
        // ✅ Bill नसेल तरच amount लगेच cut होईल
        // Bill असेल तर officer verify केल्यावर cut होईल
        if (billImageUrl == null) {
          await _loanController.updateUsedAmount(
            loanId: loanId,
            newExpenseAmount: amount,
          );
        }
        selectedBillImage.value = null;
        selectedCategory.value = '';

        if (billImageUrl != null) {
          Helpers.showInfo(
            '📤 Expense submitted! Officer will verify your bill.',
          );
        } else {
          Helpers.showSuccess('✅ Expense added successfully!');
        }
      } else {
        Helpers.showError('Failed to add expense. Try again.');
      }
      return success;
    } catch (e) {
      Helpers.showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
      isUploading.value = false;
    }
  }

  // ─── Verify Bill ✅ Officer साठी ─────────────────────────
  Future<bool> verifyBill({
    required String expenseId,
    required String loanId,
    required double amount,
    required bool isValid,
    required String message,
    required String userId,
  }) async {
    isLoading.value = true;
    try {
      // Firestore मध्ये update
      final success = await _firestoreService.updateExpenseVerification(
        expenseId: expenseId,
        verificationStatus: isValid ? 'valid' : 'invalid',
        officerMessage: message,
        amountDeducted: isValid,
      );

      if (success) {
        if (isValid) {
          // ✅ Valid — Amount cut कर
          await _loanController.updateUsedAmount(
            loanId: loanId,
            newExpenseAmount: amount,
          );

          // Borrower ला alert पाठव
          await _firestoreService.sendAlert(
            userId: userId,
            loanId: loanId,
            message:
                '✅ Your bill has been verified! ₹${amount.toStringAsFixed(0)} has been deducted from your loan.',
            officerId: 'system',
          );

          Helpers.showSuccess('✅ Bill verified! Amount deducted.');
        } else {
          // ❌ Invalid — Alert पाठव
          await _firestoreService.sendAlert(
            userId: userId,
            loanId: loanId,
            message:
                '❌ Your bill is invalid! Reason: $message. Amount has NOT been deducted.',
            officerId: 'system',
          );

          Helpers.showWarning('❌ Bill marked as invalid!');
        }
      }
      return success;
    } catch (e) {
      Helpers.showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Get Expense Categories ──────────────────────────────
  List<Map<String, String>> getCategories(String loanType) {
    switch (loanType) {
      case 'agriculture':
        return [
          {'value': 'seeds', 'label': '🌱 Seeds / बियाणे'},
          {'value': 'fertilizer', 'label': '🌿 Fertilizer / खत'},
          {'value': 'pesticide', 'label': '💊 Pesticide / औषधे'},
          {'value': 'equipment', 'label': '🚜 Equipment / उपकरणे'},
          {'value': 'irrigation', 'label': '💧 Irrigation / सिंचन'},
          {'value': 'labor', 'label': '👨‍🌾 Labor / मजुरी'},
          {'value': 'other', 'label': '📦 Other / इतर'},
        ];
      case 'education':
        return [
          {'value': 'fees', 'label': '🎓 College Fees / फी'},
          {'value': 'books', 'label': '📚 Books / पुस्तके'},
          {'value': 'hostel', 'label': '🏠 Hostel / वसतिगृह'},
          {'value': 'transport', 'label': '🚌 Transport / प्रवास'},
          {'value': 'other', 'label': '📦 Other / इतर'},
        ];
      case 'msme':
        return [
          {'value': 'raw_material', 'label': '🏭 Raw Material / कच्चा माल'},
          {'value': 'machinery', 'label': '⚙️ Machinery / यंत्रसामग्री'},
          {'value': 'rent', 'label': '🏢 Rent / भाडे'},
          {'value': 'salary', 'label': '💰 Salary / पगार'},
          {'value': 'marketing', 'label': '📢 Marketing / विपणन'},
          {'value': 'other', 'label': '📦 Other / इतर'},
        ];
      default:
        return [
          {'value': 'food', 'label': '🍽️ Food / अन्न'},
          {'value': 'transport', 'label': '🚌 Transport / प्रवास'},
          {'value': 'medical', 'label': '🏥 Medical / वैद्यकीय'},
          {'value': 'other', 'label': '📦 Other / इतर'},
        ];
    }
  }

  double get totalExpenseAmount {
    return loanExpenses.fold(0, (sum, e) => sum + e.amount);
  }

  Map<String, double> getCategoryWiseTotal() {
    final Map<String, double> categoryTotal = {};
    for (final expense in loanExpenses) {
      categoryTotal[expense.category] =
          (categoryTotal[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotal;
  }
}
