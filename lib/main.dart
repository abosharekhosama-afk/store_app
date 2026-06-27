import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:untitled2_ecom/app.dart';
import 'package:untitled2_ecom/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:untitled2_ecom/data/services/notification_controller.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/cart_controller.dart';
import 'package:untitled2_ecom/features/shop/models/brand_model.dart';
import 'package:untitled2_ecom/features/shop/models/product_attribute_model.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/features/shop/models/product_variation_model.dart';
import 'package:untitled2_ecom/firebase_options.dart';
import 'package:untitled2_ecom/utils/constants/enums.dart';

Future<void> main() async {
  // widgets binding
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  // GetX local Storage
  await GetStorage.init();
  // 2. تهيئة Hive للعمل مع Flutter
  await Hive.initFlutter();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // initalize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((FirebaseApp value) => Get.put(AuthenticationRepository()));

  // 2. وضع الـ Controller في الذاكرة (استدعاء)
  Get.put(NotificationController(), permanent: true);
  Get.put(
    CartController(),
    permanent: true,
  ); //RGet.put(ImageCacheController()); // متحكم إدارة الصور

  // 3. بدء تشغيل إعدادات الإشعارات
  // await notificationController.setupPushNotifications();

  // 3. تسجيل الـ Adapters
  // ملاحظة: الترتيب ليس مهماً جداً، المهم تسجيل كل الأنواع المستخدمة
  Hive.registerAdapter(ProductModelAdapter()); // typeId: 0
  Hive.registerAdapter(BrandModelAdapter()); // typeId: 1
  Hive.registerAdapter(ProductAttributeModelAdapter()); // typeId: 2
  Hive.registerAdapter(ProductVariationModelAdapter()); // typeId: 3
  Hive.registerAdapter(ProductVisibilityAdapter()); // typeId: 4 (الـ Enum)

  // 4. فتح الصندوق (Box) الخاص بالمنتجات
  // نفتح الصندوق هنا ليكون جاهزاً للاستخدام فور تشغيل التطبيق
  await Hive.openBox<ProductModel>('featured_products');
  await Hive.openBox<ProductModel>('store_products');
  runApp(const App());
}
