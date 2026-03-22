import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();

  // ─── Cloudinary Config ────────────────────────────────────
  static const String _cloudName = 'dawadpvhe';
  static const String _uploadPreset = 'loan_docs';

  // ─── Cloudinary Image Upload ──────────────────────────────
  Future<String?> _uploadToCloudinary(File imageFile, String folder) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['folder'] = folder
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        print('✅ Cloudinary upload success: ${jsonData['secure_url']}');
        return jsonData['secure_url'] as String?;
      } else {
        print('❌ Cloudinary error: ${jsonData['error']}');
        return null;
      }
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }

  // ─── Cloudinary PDF Upload ✅ NEW ─────────────────────────
  Future<String?> _uploadPdfToCloudinary(File pdfFile, String folder) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/raw/upload',
      );

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['folder'] = folder
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            pdfFile.path,
            contentType: MediaType('application', 'pdf'),
          ),
        );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        print('✅ PDF uploaded: ${jsonData['secure_url']}');
        return jsonData['secure_url'] as String?;
      } else {
        print('❌ PDF upload error: ${jsonData['error']}');
        return null;
      }
    } catch (e) {
      print('❌ PDF upload error: $e');
      return null;
    }
  }

  // ─── Pick PDF File ✅ NEW ─────────────────────────────────
  Future<File?> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.single.path == null) return null;
      return File(result.files.single.path!);
    } catch (e) {
      print('❌ PDF pick error: $e');
      return null;
    }
  }

  // ─── Pick Image from Gallery ─────────────────────────────
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile == null) return null;
      final croppedFile = await _cropImage(pickedFile.path);
      return croppedFile;
    } catch (e) {
      return null;
    }
  }

  // ─── Pick Image from Camera ──────────────────────────────
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (pickedFile == null) return null;
      final croppedFile = await _cropImage(pickedFile.path);
      return croppedFile;
    } catch (e) {
      return null;
    }
  }

  // ─── Crop Image ──────────────────────────────────────────
  Future<File?> _cropImage(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF2E7D32),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF2E7D32),
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: false),
        ],
      );
      if (croppedFile == null) return null;
      return File(croppedFile.path);
    } catch (e) {
      return null;
    }
  }

  // ─── Upload Profile Image ────────────────────────────────
  Future<String?> uploadProfileImage({
    required String uid,
    required File imageFile,
  }) async {
    try {
      return await _uploadToCloudinary(imageFile, 'profiles/$uid');
    } catch (e) {
      print('❌ Profile upload error: $e');
      return null;
    }
  }

  // ─── Upload Bill ✅ Image + PDF support ───────────────────
  Future<String?> uploadBillImage({
    required String userId,
    required String expenseId,
    required File imageFile,
  }) async {
    try {
      final isPdf = imageFile.path.toLowerCase().endsWith('.pdf');
      if (isPdf) {
        return await _uploadPdfToCloudinary(
          imageFile,
          'bills/$userId/$expenseId',
        );
      } else {
        return await _uploadToCloudinary(imageFile, 'bills/$userId/$expenseId');
      }
    } catch (e) {
      print('❌ Bill upload error: $e');
      return null;
    }
  }

  // ─── Upload Loan Document ✅ Image + PDF support ──────────
  Future<String?> uploadLoanDocument({
    required String userId,
    required String loanId,
    required String docKey,
    required File imageFile,
  }) async {
    try {
      final isPdf = imageFile.path.toLowerCase().endsWith('.pdf');
      String? url;

      if (isPdf) {
        url = await _uploadPdfToCloudinary(
          imageFile,
          'loan_docs/$userId/$loanId',
        );
      } else {
        url = await _uploadToCloudinary(imageFile, 'loan_docs/$userId/$loanId');
      }

      print('✅ Document uploaded ($docKey): $url');
      return url;
    } catch (e) {
      print('❌ Loan doc upload error ($docKey): $e');
      return null;
    }
  }

  // ─── Delete Image ─────────────────────────────────────────
  Future<bool> deleteImage(String imageUrl) async {
    return true;
  }

  // ─── Pick Bill — Image किंवा PDF ✅ NEW ───────────────────
  Future<File?> pickBillFile(String type) async {
    try {
      if (type == 'pdf') {
        return await pickPdfFile();
      } else if (type == 'camera') {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (pickedFile == null) return null;
        return File(pickedFile.path);
      } else {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (pickedFile == null) return null;
        return File(pickedFile.path);
      }
    } catch (e) {
      return null;
    }
  }

  // ─── Pick Bill Image (No Crop) — backward compat ─────────
  Future<File?> pickBillImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      return null;
    }
  }
}
