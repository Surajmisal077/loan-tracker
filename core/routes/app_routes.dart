import 'package:get/get.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/auth/otp_screen.dart';
import '../../views/borrower/borrower_dashboard.dart';
import '../../views/borrower/apply_loan_screen.dart';
import '../../views/officer/officer_dashboard.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/borrower/loan_detail_screen.dart';
import '../../views/borrower/add_expense_screen.dart';
import '../../views/borrower/expense_list_screen.dart';
import '../../views/borrower/borrower_report_screen.dart';
import '../../views/officer/borrower_list_screen.dart';
import '../../views/officer/borrower_detail_screen.dart';
import '../../views/officer/loan_approval_screen.dart';
import '../../views/officer/officer_report_screen.dart';

class AppRoutes {
  // Route Names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String borrowerDashboard = '/borrower-dashboard';
  static const String officerDashboard = '/officer-dashboard';
  static const String applyLoan = '/apply-loan'; // ✅ NEW
  static const String profile = '/profile';
  static const String loanDetail = '/loan-detail';
  static const String addExpense = '/add-expense';
  static const String expenseList = '/expense-list';
  static const String borrowerReport = '/borrower-report';
  static const String borrowerList = '/borrower-list';
  static const String borrowerDetail = '/borrower-detail';
  static const String loanApproval = '/loan-approval';
  static const String officerReport = '/officer-report';

  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: otp,
      page: () => const OtpScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: borrowerDashboard,
      page: () => const BorrowerDashboard(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: officerDashboard,
      page: () => const OfficerDashboard(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: applyLoan, // ✅ NEW
      page: () => const ApplyLoanScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: loanDetail,
      page: () => const LoanDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: addExpense,
      page: () => const AddExpenseScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: expenseList,
      page: () => const ExpenseListScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: borrowerReport,
      page: () => const BorrowerReportScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: borrowerList,
      page: () => const BorrowerListScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: borrowerDetail,
      page: () => const BorrowerDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: loanApproval,
      page: () => const LoanApprovalScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: officerReport,
      page: () => const OfficerReportScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
