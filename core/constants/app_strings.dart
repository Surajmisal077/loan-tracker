import 'package:get_storage/get_storage.dart';
import '../../l10n/app_en.dart';
import '../../l10n/app_mr.dart';
import '../../l10n/app_hi.dart';

class AppStrings {
  static final GetStorage _storage = GetStorage();
  static String get _lang => _storage.read('language') ?? 'en';

  static String _t(String en, String mr, String hi) {
    if (_lang == 'mr') return mr;
    if (_lang == 'hi') return hi;
    return en;
  }

  // Auth
  static String get appName => _t(AppEn.appName, AppMr.appName, AppHi.appName);
  static String get login => _t(AppEn.login, AppMr.login, AppHi.login);
  static String get register =>
      _t(AppEn.register, AppMr.register, AppHi.register);
  static String get email => _t(AppEn.email, AppMr.email, AppHi.email);
  static String get password =>
      _t(AppEn.password, AppMr.password, AppHi.password);
  static String get confirmPassword =>
      _t(AppEn.confirmPassword, AppMr.confirmPassword, AppHi.confirmPassword);
  static String get fullName =>
      _t(AppEn.fullName, AppMr.fullName, AppHi.fullName);
  static String get phoneNumber =>
      _t(AppEn.phoneNumber, AppMr.phoneNumber, AppHi.phoneNumber);
  static String get selectRole =>
      _t(AppEn.selectRole, AppMr.selectRole, AppHi.selectRole);
  static String get borrower =>
      _t(AppEn.borrower, AppMr.borrower, AppHi.borrower);
  static String get bankOfficer =>
      _t(AppEn.bankOfficer, AppMr.bankOfficer, AppHi.bankOfficer);
  static String get forgotPassword =>
      _t(AppEn.forgotPassword, AppMr.forgotPassword, AppHi.forgotPassword);
  static String get dontHaveAccount =>
      _t(AppEn.dontHaveAccount, AppMr.dontHaveAccount, AppHi.dontHaveAccount);
  static String get alreadyHaveAccount => _t(
    AppEn.alreadyHaveAccount,
    AppMr.alreadyHaveAccount,
    AppHi.alreadyHaveAccount,
  );
  static String get loginHere =>
      _t(AppEn.loginHere, AppMr.loginHere, AppHi.loginHere);
  static String get registerHere =>
      _t(AppEn.registerHere, AppMr.registerHere, AppHi.registerHere);

  // OTP
  static String get otpVerification =>
      _t(AppEn.otpVerification, AppMr.otpVerification, AppHi.otpVerification);
  static String get enterOtp =>
      _t(AppEn.enterOtp, AppMr.enterOtp, AppHi.enterOtp);
  static String get verifyOtp =>
      _t(AppEn.verifyOtp, AppMr.verifyOtp, AppHi.verifyOtp);
  static String get resendOtp =>
      _t(AppEn.resendOtp, AppMr.resendOtp, AppHi.resendOtp);
  static String get otpSentTo =>
      _t(AppEn.otpSentTo, AppMr.otpSentTo, AppHi.otpSentTo);
  static String get sendOtp => _t(AppEn.sendOtp, AppMr.sendOtp, AppHi.sendOtp);

  // Dashboard
  static String get hello => _t(AppEn.hello, AppMr.hello, AppHi.hello);
  static String get myLoans => _t(AppEn.myLoans, AppMr.myLoans, AppHi.myLoans);
  static String get myExpenses =>
      _t(AppEn.myExpenses, AppMr.myExpenses, AppHi.myExpenses);
  static String get report => _t(AppEn.report, AppMr.report, AppHi.report);
  static String get home => _t(AppEn.home, AppMr.home, AppHi.home);
  static String get seeAll => _t(AppEn.seeAll, AppMr.seeAll, AppHi.seeAll);
  static String get totalLoan =>
      _t(AppEn.totalLoan, AppMr.totalLoan, AppHi.totalLoan);
  static String get usedAmount =>
      _t(AppEn.usedAmount, AppMr.usedAmount, AppHi.usedAmount);
  static String get remainingAmount =>
      _t(AppEn.remainingAmount, AppMr.remainingAmount, AppHi.remainingAmount);
  static String get approved =>
      _t(AppEn.approved, AppMr.approved, AppHi.approved);
  static String get pending => _t(AppEn.pending, AppMr.pending, AppHi.pending);
  static String get rejected =>
      _t(AppEn.rejected, AppMr.rejected, AppHi.rejected);
  static String get noLoansYet =>
      _t(AppEn.noLoansYet, AppMr.noLoansYet, AppHi.noLoansYet);
  static String get noExpensesYet =>
      _t(AppEn.noExpensesYet, AppMr.noExpensesYet, AppHi.noExpensesYet);
  static String get noReportYet =>
      _t(AppEn.noReportYet, AppMr.noReportYet, AppHi.noReportYet);

  // Apply Loan
  static String get applyLoan =>
      _t(AppEn.applyLoan, AppMr.applyLoan, AppHi.applyLoan);
  static String get applyForNewLoan =>
      _t(AppEn.applyForNewLoan, AppMr.applyForNewLoan, AppHi.applyForNewLoan);
  static String get selectLoanType =>
      _t(AppEn.selectLoanType, AppMr.selectLoanType, AppHi.selectLoanType);
  static String get loanAmount =>
      _t(AppEn.loanAmount, AppMr.loanAmount, AppHi.loanAmount);
  static String get loanPurpose =>
      _t(AppEn.loanPurpose, AppMr.loanPurpose, AppHi.loanPurpose);
  static String get submitApplication => _t(
    AppEn.submitApplication,
    AppMr.submitApplication,
    AppHi.submitApplication,
  );
  static String get applicationSubmitted => _t(
    AppEn.applicationSubmitted,
    AppMr.applicationSubmitted,
    AppHi.applicationSubmitted,
  );
  static String get officerWillReview => _t(
    AppEn.officerWillReview,
    AppMr.officerWillReview,
    AppHi.officerWillReview,
  );

  // Loan Types
  static String get agricultureLoan =>
      _t(AppEn.agricultureLoan, AppMr.agricultureLoan, AppHi.agricultureLoan);
  static String get educationLoan =>
      _t(AppEn.educationLoan, AppMr.educationLoan, AppHi.educationLoan);
  static String get msmeLoan =>
      _t(AppEn.msmeLoan, AppMr.msmeLoan, AppHi.msmeLoan);
  static String get personalLoan =>
      _t(AppEn.personalLoan, AppMr.personalLoan, AppHi.personalLoan);
  static String get homeLoan =>
      _t(AppEn.homeLoan, AppMr.homeLoan, AppHi.homeLoan);
  static String get agricultureDesc =>
      _t(AppEn.agricultureDesc, AppMr.agricultureDesc, AppHi.agricultureDesc);
  static String get educationDesc =>
      _t(AppEn.educationDesc, AppMr.educationDesc, AppHi.educationDesc);
  static String get msmeDesc =>
      _t(AppEn.msmeDesc, AppMr.msmeDesc, AppHi.msmeDesc);
  static String get personalDesc =>
      _t(AppEn.personalDesc, AppMr.personalDesc, AppHi.personalDesc);
  static String get homeDesc =>
      _t(AppEn.homeDesc, AppMr.homeDesc, AppHi.homeDesc);

  // Add Expense
  static String get addExpense =>
      _t(AppEn.addExpense, AppMr.addExpense, AppHi.addExpense);
  static String get selectLoan =>
      _t(AppEn.selectLoan, AppMr.selectLoan, AppHi.selectLoan);
  static String get chooseLoan =>
      _t(AppEn.chooseLoan, AppMr.chooseLoan, AppHi.chooseLoan);
  static String get selectCategory =>
      _t(AppEn.selectCategory, AppMr.selectCategory, AppHi.selectCategory);
  static String get amount => _t(AppEn.amount, AppMr.amount, AppHi.amount);
  static String get description =>
      _t(AppEn.description, AppMr.description, AppHi.description);
  static String get location =>
      _t(AppEn.location, AppMr.location, AppHi.location);
  static String get billPhoto =>
      _t(AppEn.billPhoto, AppMr.billPhoto, AppHi.billPhoto);
  static String get tapToAddBillPhoto => _t(
    AppEn.tapToAddBillPhoto,
    AppMr.tapToAddBillPhoto,
    AppHi.tapToAddBillPhoto,
  );
  static String get uploadingBill =>
      _t(AppEn.uploadingBill, AppMr.uploadingBill, AppHi.uploadingBill);
  static String get camera => _t(AppEn.camera, AppMr.camera, AppHi.camera);
  static String get gallery => _t(AppEn.gallery, AppMr.gallery, AppHi.gallery);
  static String get selectBillImage =>
      _t(AppEn.selectBillImage, AppMr.selectBillImage, AppHi.selectBillImage);

  // Categories
  static String get seeds => _t(AppEn.seeds, AppMr.seeds, AppHi.seeds);
  static String get fertilizer =>
      _t(AppEn.fertilizer, AppMr.fertilizer, AppHi.fertilizer);
  static String get pesticide =>
      _t(AppEn.pesticide, AppMr.pesticide, AppHi.pesticide);
  static String get equipment =>
      _t(AppEn.equipment, AppMr.equipment, AppHi.equipment);
  static String get irrigation =>
      _t(AppEn.irrigation, AppMr.irrigation, AppHi.irrigation);
  static String get labor => _t(AppEn.labor, AppMr.labor, AppHi.labor);
  static String get fees => _t(AppEn.fees, AppMr.fees, AppHi.fees);
  static String get books => _t(AppEn.books, AppMr.books, AppHi.books);
  static String get hostel => _t(AppEn.hostel, AppMr.hostel, AppHi.hostel);
  static String get rawMaterial =>
      _t(AppEn.rawMaterial, AppMr.rawMaterial, AppHi.rawMaterial);
  static String get machinery =>
      _t(AppEn.machinery, AppMr.machinery, AppHi.machinery);
  static String get rent => _t(AppEn.rent, AppMr.rent, AppHi.rent);
  static String get salary => _t(AppEn.salary, AppMr.salary, AppHi.salary);
  static String get marketing =>
      _t(AppEn.marketing, AppMr.marketing, AppHi.marketing);
  static String get food => _t(AppEn.food, AppMr.food, AppHi.food);
  static String get transport =>
      _t(AppEn.transport, AppMr.transport, AppHi.transport);
  static String get medical => _t(AppEn.medical, AppMr.medical, AppHi.medical);

  // Loan Detail
  static String get loanDetails =>
      _t(AppEn.loanDetails, AppMr.loanDetails, AppHi.loanDetails);
  static String get loanInformation =>
      _t(AppEn.loanInformation, AppMr.loanInformation, AppHi.loanInformation);
  static String get loanUtilization =>
      _t(AppEn.loanUtilization, AppMr.loanUtilization, AppHi.loanUtilization);
  static String get purpose => _t(AppEn.purpose, AppMr.purpose, AppHi.purpose);
  static String get date => _t(AppEn.date, AppMr.date, AppHi.date);
  static String get type => _t(AppEn.type, AppMr.type, AppHi.type);
  static String get officerNote =>
      _t(AppEn.officerNote, AppMr.officerNote, AppHi.officerNote);
  static String get expenseRecords =>
      _t(AppEn.expenseRecords, AppMr.expenseRecords, AppHi.expenseRecords);
  static String get noExpensesRecorded => _t(
    AppEn.noExpensesRecorded,
    AppMr.noExpensesRecorded,
    AppHi.noExpensesRecorded,
  );
  static String get billAttached =>
      _t(AppEn.billAttached, AppMr.billAttached, AppHi.billAttached);
  static String get viewBill =>
      _t(AppEn.viewBill, AppMr.viewBill, AppHi.viewBill);

  // Report
  static String get utilizationScore => _t(
    AppEn.utilizationScore,
    AppMr.utilizationScore,
    AppHi.utilizationScore,
  );
  static String get loanProgress =>
      _t(AppEn.loanProgress, AppMr.loanProgress, AppHi.loanProgress);
  static String get categorySummary =>
      _t(AppEn.categorySummary, AppMr.categorySummary, AppHi.categorySummary);
  static String get overallUtilization => _t(
    AppEn.overallUtilization,
    AppMr.overallUtilization,
    AppHi.overallUtilization,
  );
  static String get loansBreakdown =>
      _t(AppEn.loansBreakdown, AppMr.loansBreakdown, AppHi.loansBreakdown);
  static String get highUtilizationAlert => _t(
    AppEn.highUtilizationAlert,
    AppMr.highUtilizationAlert,
    AppHi.highUtilizationAlert,
  );
  static String get moderateUtilization => _t(
    AppEn.moderateUtilization,
    AppMr.moderateUtilization,
    AppHi.moderateUtilization,
  );
  static String get goodUtilization =>
      _t(AppEn.goodUtilization, AppMr.goodUtilization, AppHi.goodUtilization);

  // Officer
  static String get helloOfficer =>
      _t(AppEn.helloOfficer, AppMr.helloOfficer, AppHi.helloOfficer);
  static String get totalBorrowers =>
      _t(AppEn.totalBorrowers, AppMr.totalBorrowers, AppHi.totalBorrowers);
  static String get totalLoans =>
      _t(AppEn.totalLoans, AppMr.totalLoans, AppHi.totalLoans);
  static String get totalDisbursed =>
      _t(AppEn.totalDisbursed, AppMr.totalDisbursed, AppHi.totalDisbursed);
  static String get pendingLoans =>
      _t(AppEn.pendingLoans, AppMr.pendingLoans, AppHi.pendingLoans);
  static String get allBorrowers =>
      _t(AppEn.allBorrowers, AppMr.allBorrowers, AppHi.allBorrowers);
  static String get noPendingLoans =>
      _t(AppEn.noPendingLoans, AppMr.noPendingLoans, AppHi.noPendingLoans);
  static String get review => _t(AppEn.review, AppMr.review, AppHi.review);
  static String get searchBorrowers =>
      _t(AppEn.searchBorrowers, AppMr.searchBorrowers, AppHi.searchBorrowers);

  // Loan Approval
  static String get loanReview =>
      _t(AppEn.loanReview, AppMr.loanReview, AppHi.loanReview);
  static String get approveLoan =>
      _t(AppEn.approveLoan, AppMr.approveLoan, AppHi.approveLoan);
  static String get rejectLoan =>
      _t(AppEn.rejectLoan, AppMr.rejectLoan, AppHi.rejectLoan);
  static String get sendAlert =>
      _t(AppEn.sendAlert, AppMr.sendAlert, AppHi.sendAlert);
  static String get addNote => _t(AppEn.addNote, AppMr.addNote, AppHi.addNote);
  static String get reasonForRejection => _t(
    AppEn.reasonForRejection,
    AppMr.reasonForRejection,
    AppHi.reasonForRejection,
  );
  static String get alertMessage =>
      _t(AppEn.alertMessage, AppMr.alertMessage, AppHi.alertMessage);
  static String get areYouSureApprove => _t(
    AppEn.areYouSureApprove,
    AppMr.areYouSureApprove,
    AppHi.areYouSureApprove,
  );
  static String get areYouSureReject => _t(
    AppEn.areYouSureReject,
    AppMr.areYouSureReject,
    AppHi.areYouSureReject,
  );
  static String get utilization =>
      _t(AppEn.utilization, AppMr.utilization, AppHi.utilization);
  static String get loanApprovedSuccess => _t(
    AppEn.loanApprovedSuccess,
    AppMr.loanApprovedSuccess,
    AppHi.loanApprovedSuccess,
  );
  static String get loanRejectedSuccess => _t(
    AppEn.loanRejectedSuccess,
    AppMr.loanRejectedSuccess,
    AppHi.loanRejectedSuccess,
  );
  static String get alertSentSuccess => _t(
    AppEn.alertSentSuccess,
    AppMr.alertSentSuccess,
    AppHi.alertSentSuccess,
  );

  // ✅ हे नवीन add केले — sendAlertToBorrower
  static String get sendAlertToBorrower => _t(
    AppEn.sendAlertToBorrower,
    AppMr.sendAlertToBorrower,
    AppHi.sendAlertToBorrower,
  );

  // Profile
  static String get profile => _t(AppEn.profile, AppMr.profile, AppHi.profile);
  static String get editProfile =>
      _t(AppEn.editProfile, AppMr.editProfile, AppHi.editProfile);
  static String get changePhoto =>
      _t(AppEn.changePhoto, AppMr.changePhoto, AppHi.changePhoto);
  static String get bankName =>
      _t(AppEn.bankName, AppMr.bankName, AppHi.bankName);
  static String get designation =>
      _t(AppEn.designation, AppMr.designation, AppHi.designation);
  static String get save => _t(AppEn.save, AppMr.save, AppHi.save);
  static String get logout => _t(AppEn.logout, AppMr.logout, AppHi.logout);
  static String get logoutConfirm =>
      _t(AppEn.logoutConfirm, AppMr.logoutConfirm, AppHi.logoutConfirm);
  static String get profileUpdated =>
      _t(AppEn.profileUpdated, AppMr.profileUpdated, AppHi.profileUpdated);
  static String get memberSince =>
      _t(AppEn.memberSince, AppMr.memberSince, AppHi.memberSince);
  static String get contactInformation => _t(
    AppEn.contactInformation,
    AppMr.contactInformation,
    AppHi.contactInformation,
  );

  // General
  static String get cancel => _t(AppEn.cancel, AppMr.cancel, AppHi.cancel);
  static String get ok => _t(AppEn.ok, AppMr.ok, AppHi.ok);
  static String get yes => _t(AppEn.yes, AppMr.yes, AppHi.yes);
  static String get no => _t(AppEn.no, AppMr.no, AppHi.no);
  static String get loading => _t(AppEn.loading, AppMr.loading, AppHi.loading);
  static String get somethingWentWrong => _t(
    AppEn.somethingWentWrong,
    AppMr.somethingWentWrong,
    AppHi.somethingWentWrong,
  );
  static String get continueText =>
      _t(AppEn.continueText, AppMr.continueText, AppHi.continueText);
  static String get selectLanguage =>
      _t(AppEn.selectLanguage, AppMr.selectLanguage, AppHi.selectLanguage);

  // Validation
  static String get emailRequired =>
      _t(AppEn.emailRequired, AppMr.emailRequired, AppHi.emailRequired);
  static String get invalidEmail =>
      _t(AppEn.invalidEmail, AppMr.invalidEmail, AppHi.invalidEmail);
  static String get passwordRequired => _t(
    AppEn.passwordRequired,
    AppMr.passwordRequired,
    AppHi.passwordRequired,
  );
  static String get passwordTooShort => _t(
    AppEn.passwordTooShort,
    AppMr.passwordTooShort,
    AppHi.passwordTooShort,
  );
  static String get confirmPasswordRequired => _t(
    AppEn.confirmPasswordRequired,
    AppMr.confirmPasswordRequired,
    AppHi.confirmPasswordRequired,
  );
  static String get passwordsDoNotMatch => _t(
    AppEn.passwordsDoNotMatch,
    AppMr.passwordsDoNotMatch,
    AppHi.passwordsDoNotMatch,
  );
  static String get nameRequired =>
      _t(AppEn.nameRequired, AppMr.nameRequired, AppHi.nameRequired);
  static String get phoneRequired =>
      _t(AppEn.phoneRequired, AppMr.phoneRequired, AppHi.phoneRequired);
  static String get phoneInvalid =>
      _t(AppEn.phoneInvalid, AppMr.phoneInvalid, AppHi.phoneInvalid);
  static String get fieldRequired =>
      _t(AppEn.fieldRequired, AppMr.fieldRequired, AppHi.fieldRequired);
  static String get amountRequired =>
      _t(AppEn.amountRequired, AppMr.amountRequired, AppHi.amountRequired);
  static String get purposeTooShort =>
      _t(AppEn.purposeTooShort, AppMr.purposeTooShort, AppHi.purposeTooShort);
  static String get amountMin =>
      _t(AppEn.amountMin, AppMr.amountMin, AppHi.amountMin);
  static String get amountMax =>
      _t(AppEn.amountMax, AppMr.amountMax, AppHi.amountMax);
}
