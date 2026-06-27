import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled2_ecom/utils/popups/loaders.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // استماع لحظي للإشعارات مرتبة حسب الأحدث
  Stream<QuerySnapshot> getNotifications() {
    return _db
        .collection('Users')
        .doc(userId)
        .collection('Notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // تحديث حالة الفتح
  Future<void> markAsOpened(String docId) async {
    await _db
        .collection('Users')
        .doc(userId)
        .collection('Notifications')
        .doc(docId)
        .update({'isOpened': true, 'isRead': true});
  }

  // حذف الإشعار (سيفشل إذا لم يكن مفتوحاً بسبب القواعد الأمنية)
  Future<void> deleteNotification(String docId, bool isOpened) async {
    if (!isOpened) {
      TLoaders.warningSnackBar(
        title: "تنبيه",
        message: "لا يمكنك حذف الإشعار قبل فتحه وقراءته",
      );
      return;
    }
    await _db
        .collection('Users')
        .doc(userId)
        .collection('Notifications')
        .doc(docId)
        .delete();
  }
}
