import 'dart:io';
import 'package:get/get.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../core/utils/helpers.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final AuthController _authController = Get.find<AuthController>();

  // Observable Variables
  final RxBool isLoading = false.obs;
  final Rx<File?> selectedProfileImage = Rx<File?>(null);

  // ─── Pick Profile Image from Gallery ────────────────────
  Future<void> pickProfileImageFromGallery() async {
    final file = await _storageService.pickImageFromGallery();
    if (file != null) {
      selectedProfileImage.value = file;
    }
  }

  // ─── Pick Profile Image from Camera ─────────────────────
  Future<void> pickProfileImageFromCamera() async {
    final file = await _storageService.pickImageFromCamera();
    if (file != null) {
      selectedProfileImage.value = file;
    }
  }

  // ─── Update Borrower Profile ─────────────────────────────
  Future<bool> updateBorrowerProfile({
    required String uid,
    required String fullName,
    required String phone,
  }) async {
    isLoading.value = true;
    try {
      String? profileImageUrl;

      // Upload profile image if selected
      if (selectedProfileImage.value != null) {
        profileImageUrl = await _storageService.uploadProfileImage(
          uid: uid,
          imageFile: selectedProfileImage.value!,
        );
      }

      final success = await _firestoreService.updateUserProfile(
        uid: uid,
        fullName: fullName,
        phone: phone,
        profileImage: profileImageUrl,
      );

      if (success) {
        // Update current user in auth controller
        final updatedUser = _authController.currentUser.value?.copyWith(
          fullName: fullName,
          phone: phone,
          profileImage:
              profileImageUrl ??
              _authController.currentUser.value?.profileImage,
        );
        _authController.currentUser.value = updatedUser;
        selectedProfileImage.value = null;
        Helpers.showSuccess('Profile updated successfully! ✅');
      } else {
        Helpers.showError('Failed to update profile. Try again.');
      }
      return success;
    } catch (e) {
      Helpers.showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Update Officer Profile ──────────────────────────────
  Future<bool> updateOfficerProfile({
    required String uid,
    required String fullName,
    required String phone,
    required String bankName,
    required String designation,
  }) async {
    isLoading.value = true;
    try {
      String? profileImageUrl;

      // Upload profile image if selected
      if (selectedProfileImage.value != null) {
        profileImageUrl = await _storageService.uploadProfileImage(
          uid: uid,
          imageFile: selectedProfileImage.value!,
        );
      }

      final success = await _firestoreService.updateOfficerProfile(
        uid: uid,
        fullName: fullName,
        phone: phone,
        bankName: bankName,
        designation: designation,
        profileImage: profileImageUrl,
      );

      if (success) {
        // Update current officer in auth controller
        final updatedOfficer = _authController.currentOfficer.value?.copyWith(
          fullName: fullName,
          phone: phone,
          bankName: bankName,
          designation: designation,
          profileImage:
              profileImageUrl ??
              _authController.currentOfficer.value?.profileImage,
        );
        _authController.currentOfficer.value = updatedOfficer;
        selectedProfileImage.value = null;
        Helpers.showSuccess('Profile updated successfully! ✅');
      } else {
        Helpers.showError('Failed to update profile. Try again.');
      }
      return success;
    } catch (e) {
      Helpers.showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Clear Selected Image ────────────────────────────────
  void clearSelectedImage() {
    selectedProfileImage.value = null;
  }
}
