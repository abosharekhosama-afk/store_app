import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled2_ecom/utils/popups/loaders.dart';

class NotificationController extends GetxController {
  static NotificationController get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final String? storeId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    // 1. مراقبة تحديث التوكن (يعمل في الخلفية ولا يعطل التشغيل)
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      saveTokenToFirestore(newToken);
    });

    // 2. إعداد "المستمعات" فقط دون طلب إذن هنا لضمان سرعة فتح التطبيق
    _initNotificationListeners();
  }

  // إعداد المستمعات فقط (Listeners)
  void _initNotificationListeners() {
    // الإشعار والتطبيق مفتوح
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Get.snackbar(
        message.notification?.title ?? "تحديث جديد",
        message.notification?.body ?? "",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    });

    // عند الضغط على الإشعار من شريط التنبيهات
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationClick(message);
    });
  }

  // --- جزء إدارة الـ FCM (Push Notifications) ---
  /*
  Future<void> setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    final token = await fcm.getToken();
    if (token != null) {
      saveTokenToFirestore(token);
    }

    // الإشعار والتطبيق مفتوح
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Get.snackbar(
        message.notification?.title ?? "تحديث جديد",
        message.notification?.body ?? "",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    });

    // عند الضغط على الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationClick(message);
    });
  }
*/
  // الدالة الأساسية التي سنستدعيها في الصفحة الرئيسية
  Future<void> requestPermissionAndGetToken() async {
    try {
      final fcm = FirebaseMessaging.instance;
      await subscribeToUserTopics();
      // طلب الإذن (يظهر للمستخدم هنا في الصفحة الرئيسية)
      NotificationSettings settings = await fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // جلب التوكن (وضعناه داخل try-catch لتجنب مشكلة SERVICE_NOT_AVAILABLE)
        String? token = await fcm.getToken().timeout(
          const Duration(seconds: 10),
        );
        if (token != null) {
          saveTokenToFirestore(token);
        }
      }
    } catch (e) {
      print("📡 Notification Service Error: $e");
      // لا نحتاج لإظهار خطأ للمستخدم، التطبيق سيعمل بشكل طبيعي
    }
  }

  void saveTokenToFirestore(String token) async {
    final currentUid = storeId; // جلب الـ UID الحالي
    if (currentUid != null) {
      try {
        await _db.collection("User").doc(currentUid).update({
          'fcmToken': token,
        });
      } catch (e) {
        // إذا لم يكن المستند موجوداً استخدم set مع merge
        await _db.collection("User").doc(currentUid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
      }
    }
  }

  void handleNotificationClick(RemoteMessage message) {
    if (message.data['type'] == 'REJECTION' ||
        message.data['type'] == 'order_update') {
      // كود الانتقال لصفحة تفاصيل الطلب
      // Get.toNamed('/order-details', arguments: message.data['orderId']);
    }
  }

  // --- جزء إدارة قائمة الإشعارات (Firestore UI) ---

  // جلب الإشعارات لحظياً
  Stream<QuerySnapshot> getNotifications() {
    return _db
        .collection("User")
        .doc(storeId)
        .collection('Notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // تحديث حالة الفتح لتمكين الحذف
  Future<void> markAsOpened(String docId) async {
    await _db
        .collection("User")
        .doc(storeId)
        .collection('Notifications')
        .doc(docId)
        .update({'isOpened': true, 'isRead': true});
  }

  // حذف الإشعار
  Future<void> deleteNotification(String docId, bool isOpened) async {
    if (!isOpened) {
      TLoaders.errorSnackBar(
        title: "تنبيه",
        message: "يجب فتح الإشعار أولاً قبل حذفه",
      );
      return;
    }
    await _db
        .collection("User")
        .doc(storeId)
        .collection('Notifications')
        .doc(docId)
        .delete();
  }

  Future<void> subscribeToUserTopics() async {
    try {
      // 1. الاشتراك في القناة العامة لجميع مستخدمي التطبيق (متاجر + زبائن)
      // نستخدمها للإعلانات الكبرى أو تحديثات النظام
      await FirebaseMessaging.instance.subscribeToTopic("all_app_users");

      // 2. الاشتراك في قناة الزبائن فقط
      // نستخدمها للعروض الترويجية والخصومات العامة للزبائن
      await FirebaseMessaging.instance.subscribeToTopic("customers");

      print("✅ تم الاشتراك في قنوات المستخدمين بنجاح");
    } catch (e) {
      print("❌ خطأ في الاشتراك في قنوات المستخدمين: $e");
    }
  }

  /*
  Future<void> requestPermissionAndGetToken() async {
    final user = AuthenticationRepository.instance.authUser;
    if (user == null) return;

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // طلب الإذن (سيظهر للمستخدم فقط إذا لم يسبق له الموافقة)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      try {
        String? token = await messaging.getToken();
        if (token != null) {
          saveTokenToFirestore(token);
        }
      } catch (e) {
        print(
          "📡 فشل الجلب الأولي (غالباً أوفلاين)، سيتكفل المراقب بالباقي: $e",
        );
      }
    }
  }
*/
}


/*
class NotificationController extends GetxController {
  static NotificationController get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      saveTokenToFirestore(newToken);
    });
  }

  Future<void> setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;

    // 1. طلب الإذن
    await fcm.requestPermission();

    // 2. جلب التوكن وتخزينه
    final token = await fcm.getToken();
    if (token != null) {
      saveTokenToFirestore(token);
    }

    // 3. التعامل مع الإشعار والتطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // هنا يمكنك إظهار Snack-bar مخصص أو تنبيه داخل التطبيق
      Get.snackbar(
        message.notification?.title ?? "طلب جديد",
        message.notification?.body ?? "",
        snackPosition: SnackPosition.TOP,
      );
    });

    // 4. التعامل مع الضغط على الإشعار وفتح التطبيق
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationClick(message);
    });
  }

  void saveTokenToFirestore(String token) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _db.collection("Stores").doc(userId).update({'fcmToken': token});
    }
  }

  void handleNotificationClick(RemoteMessage message) {
    // التحقق من نوع الإشعار والانتقال لصفحة الطلبات
    if (message.data['type'] == 'vendor_order') {
      // مثال: الانتقال لصفحة تفاصيل الطلب باستخدام الـ ID المرسل
      // Get.to(() => OrderDetailScreen(orderId: message.data['orderId']));
      print("Navigate to Order: ${message.data['orderId']}");
    }
  }

  // داخل الـ NotificationController
  void setupListeners() {
    // هذا المستمع يعمل تلقائياً عندما يقوم Firebase بجلب توكن جديد
    // (مثلاً عند عودة الإنترنت بعد انقطاع)
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      saveTokenToFirestore(newToken);
      print("🌐 تم تحديث التوكن تلقائياً بعد عودة الاتصال");
    });
  }

  Future<void> requestPermissionAndGetToken() async {
    final user = AuthenticationRepository.instance.authUser;
    if (user == null) return;

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // طلب الإذن (سيظهر للمستخدم فقط إذا لم يسبق له الموافقة)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      try {
        String? token = await messaging.getToken();
        if (token != null) {
          saveTokenToFirestore(token);
        }
      } catch (e) {
        print(
          "📡 فشل الجلب الأولي (غالباً أوفلاين)، سيتكفل المراقب بالباقي: $e",
        );
      }
    }
  }
}
*/

















/*
class NotificationController extends GetxController {
  static NotificationController get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    // مراقبة تحديث التوكن تلقائياً
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      saveTokenToFirestore(newToken);
    });
  }

  Future<void> setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();

    final token = await fcm.getToken();
    if (token != null) {
      saveTokenToFirestore(token);
    }

    // التعامل مع الإشعار والتطبيق مفتوح
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Get.snackbar(
        message.notification?.title ?? "تحديث الطلب",
        message.notification?.body ?? "",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    });

    // التعامل مع الضغط على الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationClick(message);
    });
  }

  void saveTokenToFirestore(String token) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      // ✅ تم التغيير إلى Users ليتناسب مع تطبيق الزبون
      await _db.collection("Users").doc(userId).update({'fcmToken': token});
    }
  }

  void handleNotificationClick(RemoteMessage message) {
    // الزبون يهتم بتحديثات الحالة (order_update)
    if (message.data['type'] == 'order_update') {
      String orderId = message.data['orderId'] ?? "";
      print("Navigate to My Order Details: $orderId");
      // هنا تضع كود الانتقال لصفحة تفاصيل طلب الزبون
      // Get.to(() => OrderDetailScreen(orderId: orderId));
    }
  }
}
*/