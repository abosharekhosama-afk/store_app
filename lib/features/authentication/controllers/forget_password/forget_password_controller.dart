import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:untitled2_ecom/features/authentication/screens/password_configration/reset_password.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/helpers/network_manager.dart';
import 'package:untitled2_ecom/utils/popups/exports.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  sendPasswordResetEmail() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "جارٍ معالجة طلبك...",
        TImages.docerAnimation,
      );

      if (!forgetPasswordFormKey.currentState!.validate()) {
        // نفس مبدا العمل
        TFullScreenLoader.stopLoading();
        return;
      }

      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance.sendPasswordResetEmail(
        email.text.trim(),
      );

      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
        title: "تم إرسال البريد الإلكتروني",
        message: "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.",
      );
      Get.to(() => ResetPassword(email: email.text.trim()));
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
    }
  }

  resendPasswordResetEmail(String email) async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "جارٍ معالجة طلبك...",
        TImages.docerAnimation,
      );

      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance.sendPasswordResetEmail(email);

      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
        title: "تم إرسال البريد الإلكتروني",
        message: "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.",
      );
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "يا للهول", message: e.toString());
    }
  }
}
