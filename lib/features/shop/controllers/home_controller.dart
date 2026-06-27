import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  // 🔥 هنا يعيش المتغير السحري الذي تبحث عنه
  RxList<String> blockedStoreIds = <String>[].obs;
  final isSettingsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // جلب القائمة فور تشغيل التطبيق أو الكنترولر
    fetchBlockedStores();
  }

  /// دالة جلب معرّفات المتاجر المحظورة من مستند واحد عام في الفايربيز
  Future<void> fetchBlockedStores() async {
    try {
      isSettingsLoading.value = true;

      final doc = await FirebaseFirestore.instance
          .collection('SystemSettings')
          .doc('disabled_stores')
          .get();

      if (doc.exists && doc.data() != null) {
        List<dynamic> ids = doc.data()!['ids'] ?? [];
        // تحويل البيانات وتخزينها في المتغير المستهدف
        blockedStoreIds.assignAll(ids.map((e) => e.toString()).toList());
      }
    } catch (e) {
      print("خطأ أثناء جلب قائمة المتاجر المحظورة: $e");
    } finally {
      isSettingsLoading.value = false;
    }
  }
}
