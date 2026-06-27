import 'package:get/get.dart';
import 'package:untitled2_ecom/features/personalization/controllers/address_controller.dart';
import 'package:untitled2_ecom/features/personalization/controllers/user_controller.dart';
import 'package:untitled2_ecom/features/shop/controllers/checkout_controller.dart';
import 'package:untitled2_ecom/features/shop/controllers/home_controller.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/cart_controller.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/variation_controller.dart';

import '../utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    /// -- Core
    Get.put(NetworkManager());
    Get.put(
      CartController(),
      permanent: true,
    ); //RGet.put(ImageCacheController()); // متحكم إدارة الصور

    Get.put(HomeController()); // حقن الكنترولر في الذاكرة لتجهيز القائمة فوراً
    Get.put(AddressController());
    Get.put(CheckoutController());
    Get.put(UserController());

    /// -- Repository
    //Get.lazyPut(() => AuthenticationRepository(), fenix: true);
    Get.put(VariationController());
    //Get.put(CartController());
    //Get.put(ThemeController());
    //Get.put(ProductController());
    //Get.lazyPut(() => UserController());
    //Get.lazyPut(() => CheckoutController());
    //Get.lazyPut(() => AddressController());

    //Get.lazyPut(() => OnBoardingController(), fenix: true);

    //Get.lazyPut(() => LoginController(), fenix: true);
    //Get.lazyPut(() => SignUpController(), fenix: true);
    //Get.lazyPut(() => OTPController(), fenix: true);
    //Get.put(TNotificationService());
    //Get.lazyPut(() => NotificationController(), fenix: true);
  }
}
