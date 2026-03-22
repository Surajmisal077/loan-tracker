import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/officer_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current User
  User? get currentUser => _auth.currentUser;

  // Auth State Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Register with Email & Password ─────────────────────
  Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    String bankName = '',
    String designation = '',
  }) async {
    try {
      // ✅ fetchSignInMethodsForEmail काढला — directly create करा
      // Firebase आपोआप 'email-already-in-use' error देतो
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final String uid = credential.user!.uid;

      // Save to Firestore
      if (role == 'officer') {
        final officer = OfficerModel(
          uid: uid,
          fullName: fullName,
          email: email,
          phone: phone,
          bankName: bankName,
          designation: designation,
          createdAt: DateTime.now(),
        );
        await _firestore.collection('officers').doc(uid).set(officer.toMap());
      } else {
        final user = UserModel(
          uid: uid,
          fullName: fullName,
          email: email,
          phone: phone,
          role: role,
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(uid).set(user.toMap());
      }

      return {'success': true, 'uid': uid, 'role': role};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Login with Email & Password ────────────────────────
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // ✅ fetchSignInMethodsForEmail काढला — directly signIn करा
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = credential.user!.uid;

      // ✅ Firestore मध्ये role check करा
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final user = UserModel.fromMap(userDoc.data()!);
        return {'success': true, 'role': user.role, 'uid': uid};
      }

      final officerDoc = await _firestore.collection('officers').doc(uid).get();
      if (officerDoc.exists) {
        return {'success': true, 'role': 'officer', 'uid': uid};
      }

      // Firebase मध्ये user आहे पण Firestore मध्ये नाही
      await _auth.signOut();
      return {'success': false, 'message': 'userNotFound'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Phone OTP ───────────────────────────────────────────
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'OTP verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // ─── Verify OTP ──────────────────────────────────────────
  Future<Map<String, dynamic>> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    }
  }

  // ─── Get User Data ───────────────────────────────────────
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ─── Get Officer Data ────────────────────────────────────
  Future<OfficerModel?> getOfficerData(String uid) async {
    try {
      final doc = await _firestore.collection('officers').doc(uid).get();
      if (doc.exists) {
        return OfficerModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ─── Logout ──────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── Error Messages ──────────────────────────────────────
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'userNotFound';
      case 'wrong-password':
        return 'wrongCredentials';
      case 'invalid-credential':
        // ✅ New Firebase SDK मध्ये wrong password साठी हा code येतो
        return 'wrongCredentials';
      case 'email-already-in-use':
        return 'userAlreadyExists';
      case 'invalid-email':
        return 'invalidEmail';
      case 'weak-password':
        return 'invalidPassword';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong: $code';
    }
  }
}
