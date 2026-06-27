import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:untitled2_ecom/data/repositories/user/user_reposity.dart';
import 'package:untitled2_ecom/features/personalization/models/user_model.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/helpers/network_manager.dart';
import 'package:untitled2_ecom/utils/popups/exports.dart';

class SignupControllers extends GetxController {
  static SignupControllers get instance => Get.find();

  final hidePassword = true.obs;
  final privacyPolice = true.obs;
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final lastName = TextEditingController();
  final userName = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();
  final phoneNumber = TextEditingController();

  Future<void> signup() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "جارٍ معالجة معلوماتك...",
        TImages.docerAnimation,
      );

      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      if (!privacyPolice.value) {
        TFullScreenLoader.stopLoading(); // 🔥 يجب إغلاق اللودر هنا لمنع تعليق الشاشة
        TLoaders.warningSnackBar(
          title: "يرجى قبول سياسة الخصوصية",
          message:
              "لإنشاء حساب يجب قراءة وقبول سياسة الخصوصية وشروط الاستخدام.",
        );
        return;
      }

      if (!signupFormKey.currentState!.validate()) {
        // نفس مبدا العمل
        TFullScreenLoader.stopLoading();
        return;
      }

      final userCardentil = await AuthenticationRepository.instance
          .regesterWithEmailAndPassword(
            email.text.trim(),
            password.text.trim(),
          );

      final newUser = UserModel(
        id: userCardentil.user!.uid,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        username: userName.text.trim(),
        email: email.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        profilePicture: "",
        bankName: "",
        bankNoumber: "",
      );

      if (!Get.isRegistered<UserReposity>()) Get.put(UserReposity());
      await UserReposity.instance.saveUserRecord(newUser);
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
        title: "تهانينا",
        message:
            "تم إنشاء حسابك بنجاح! يرجى التحقق من بريدك الإلكتروني للمتابعة.",
      );
      AuthenticationRepository.instance.screenRedirect();
      //Get.to(() => VenifyEmailScreen(email: email.text.trim()));
    } catch (e) {
      print('Error in SignupControllers.signup(): $e'); // اطبع الخطأ مباشرة
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
    } finally {
      TFullScreenLoader.stopLoading();
    }
  }
}
