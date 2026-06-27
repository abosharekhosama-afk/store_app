import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:untitled2_ecom/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:untitled2_ecom/features/personalization/controllers/user_controller.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/helpers/network_manager.dart';
import 'package:untitled2_ecom/utils/popups/full_screen_loader.dart';
import 'package:untitled2_ecom/utils/popups/loaders.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final userController = UserController.instance;

  @override
  void onInit() {
    // TODO: implement onInit
    email.text = localStorage.read("REMEMBER_ME_EMAIL") ?? "";
    password.text = localStorage.read("REMEMBER_ME_PASSWORD") ?? "";
    super.onInit();
  }

  Future<void> emailAndpasswordLoginin() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "جارٍ تسجيل الدخول...",
        TImages.docerAnimation,
      );

      if (!loginFormKey.currentState!.validate()) {
        // نفس مبدا العمل
        TFullScreenLoader.stopLoading();
        return;
      }

      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      if (rememberMe.value) {
        localStorage.write("REMEMBER_ME_EMAIL", email.text.trim());
        localStorage.write("REMEMBER_ME_PASSWORD", password.text.trim());
      }

      await AuthenticationRepository.instance.loginWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );
      TFullScreenLoader.stopLoading();
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
    }
  }

  Future<void> googleSignIn() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "جارٍ تسجيل الدخول...",
        TImages.docerAnimation,
      );

      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      final userCredentials = await AuthenticationRepository.instance
          .signInWithGoogle();
      //await userController.saveUserRecord(userCredentials);
      TFullScreenLoader.stopLoading();
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
    }
  }
}
