import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send Alert Notification to Borrower
  Future<bool> sendAlertNotification({
    required String userId,
    required String loanId,
    required String title,
    required String message,
    required String officerId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'loanId': loanId,
        'title': title,
        'message': message,
        'officerId': officerId,
        'isRead': false,
        'type': 'alert',
        'createdAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Send Loan Approval Notification
  Future<bool> sendLoanStatusNotification({
    required String userId,
    required String loanId,
    required String status,
  }) async {
    try {
      String title = '';
      String message = '';

      if (status == 'approved') {
        title = '✅ Loan Approved!';
        message = 'Your loan has been approved by the bank officer.';
      } else if (status == 'rejected') {
        title = '❌ Loan Rejected';
        message = 'Your loan has been rejected. Please contact your bank.';
      }

      await _firestore.collection('notifications').add({
        'userId': userId,
        'loanId': loanId,
        'title': title,
        'message': message,
        'isRead': false,
        'type': 'loan_status',
        'createdAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get User Notifications
  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  // Mark Notification as Read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      // ignore
    }
  }

  // Get Unread Count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
