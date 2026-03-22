import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/officer_model.dart';
import '../core/routes/app_routes.dart';
import '../core/utils/helpers.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final GetStorage _storage = GetStorage();

  // Observable Variables
  final RxBool isLoading = false.obs;
  final RxString currentRole = ''.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<OfficerModel?> currentOfficer = Rx<OfficerModel?>(null);
  final RxString verificationId = ''.obs;
  final RxString selectedLanguage = 'en'.obs;
  final RxString selectedRole = 'borrower'.obs;

  @override
  void onInit() {
    super.onInit();
    selectedLanguage.value = _storage.read('language') ?? 'en';
    // ✅ Auto login नाही — user ला नेहमी login करावं लागेल
  }

  // ─── Set Language ────────────────────────────────────────
  void setLanguage(String lang) {
    selectedLanguage.value = lang;
    _storage.write('language', lang);
  }

  // ─── Set Role ────────────────────────────────────────────
  void setRole(String role) {
    selectedRole.value = role;
  }

  // ─── Register ────────────────────────────────────────────
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String bankName = '',
    String designation = '',
  }) async {
    isLoading.value = true;
    try {
      final result = await _authService.registerWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: selectedRole.value,
        bankName: bankName,
        designation: designation,
      );

      if (result['success']) {
        // ✅ Register झाल्यावर Firebase logout करा
        // म्हणजे user ला manually login करावं लागेल
        await _authService.logout();

        Helpers.showSuccess('✅ Registration successful! Please login now.');

        // ✅ Login screen वर पाठवा
        Get.offAllNamed(AppRoutes.login);
      } else {
        final msg = result['message'];
        if (msg == 'userAlreadyExists') {
          Helpers.showError(
            '❌ This email is already registered! Please login.',
          );
        } else {
          Helpers.showError(msg ?? 'Registration failed');
        }
      }
    } catch (e) {
      Helpers.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Login ───────────────────────────────────────────────
  Future<void> login({required String email, required String password}) async {
    isLoading.value = true;
    try {
      final result = await _authService.loginWithEmail(
        email: email,
        password: password,
      );

      if (result['success']) {
        final role = result['role'];
        final uid = result['uid'];
        currentRole.value = role;

        if (role == 'officer') {
          final officerData = await _authService.getOfficerData(uid);
          currentOfficer.value = officerData;
          Helpers.showSuccess('Welcome back Officer! 🏦');
          // ✅ Officer dashboard
          Get.offAllNamed(AppRoutes.officerDashboard);
        } else {
          final userData = await _authService.getUserData(uid);
          currentUser.value = userData;
          Helpers.showSuccess('Welcome back! 👋');
          // ✅ Borrower dashboard
          Get.offAllNamed(AppRoutes.borrowerDashboard);
        }
      } else {
        final msg = result['message'];
        if (msg == 'userNotFound') {
          Helpers.showError('❌ User not found! Please register first.');
        } else if (msg == 'wrongCredentials') {
          Helpers.showError('❌ Wrong email or password! Try again.');
        } else {
          Helpers.showError(msg ?? 'Login failed');
        }
      }
    } catch (e) {
      Helpers.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Send OTP ────────────────────────────────────────────
  Future<void> sendOtp(String phone) async {
    isLoading.value = true;
    try {
      await _authService.sendOtp(
        phoneNumber: phone,
        onCodeSent: (String vid) {
          verificationId.value = vid;
          Helpers.showSuccess('OTP sent successfully! 📱');
          Get.toNamed(
            AppRoutes.otp,
            arguments: {'phone': phone, 'type': 'login'},
          );
        },
        onError: (String error) {
          Helpers.showError(error);
        },
      );
    } catch (e) {
      Helpers.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Verify OTP ──────────────────────────────────────────
  Future<void> verifyOtp(String otp) async {
    isLoading.value = true;
    try {
      final result = await _authService.verifyOtp(
        verificationId: verificationId.value,
        otp: otp,
      );

      if (result['success']) {
        final user = _authService.currentUser;
        if (user != null) {
          final userData = await _authService.getUserData(user.uid);
          if (userData != null) {
            currentUser.value = userData;
            currentRole.value = userData.role;
            Helpers.showSuccess('OTP verified! Welcome 👋');
            Get.offAllNamed(AppRoutes.borrowerDashboard);
          } else {
            final officerData = await _authService.getOfficerData(user.uid);
            if (officerData != null) {
              currentOfficer.value = officerData;
              currentRole.value = 'officer';
              Helpers.showSuccess('OTP verified! Welcome Officer 🏦');
              Get.offAllNamed(AppRoutes.officerDashboard);
            } else {
              Helpers.showError('User data not found!');
              await _authService.logout();
              Get.offAllNamed(AppRoutes.login);
            }
          }
        }
      } else {
        Helpers.showError('❌ Invalid OTP. Please try again.');
      }
    } catch (e) {
      Helpers.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Logout ──────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _authService.logout();
      // ✅ सगळं clear करा
      currentUser.value = null;
      currentOfficer.value = null;
      currentRole.value = '';
      selectedRole.value = 'borrower';
      // ✅ Login screen वर जा
      Get.offAllNamed(AppRoutes.login);
      Helpers.showSuccess('Logged out successfully! 👋');
    } catch (e) {
      Helpers.showError(e.toString());
    }
  }

  // ─── Get Display Name ────────────────────────────────────
  String get displayName {
    if (currentUser.value != null) {
      return currentUser.value!.fullName;
    }
    if (currentOfficer.value != null) {
      return currentOfficer.value!.fullName;
    }
    return '';
  }

  // ─── Get Display Email ───────────────────────────────────
  String get displayEmail {
    if (currentUser.value != null) {
      return currentUser.value!.email;
    }
    if (currentOfficer.value != null) {
      return currentOfficer.value!.email;
    }
    return '';
  }

  // ─── Get Profile Image ───────────────────────────────────
  String get profileImage {
    if (currentUser.value != null) {
      return currentUser.value!.profileImage ?? '';
    }
    if (currentOfficer.value != null) {
      return currentOfficer.value!.profileImage ?? '';
    }
    return '';
  }
}
