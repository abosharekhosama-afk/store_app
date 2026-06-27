import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/data/repositories/user/user_reposity.dart';
import 'package:untitled2_ecom/features/personalization/controllers/user_controller.dart';
import 'package:untitled2_ecom/features/personalization/screens/profile/profile.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/helpers/network_manager.dart';
import 'package:untitled2_ecom/utils/popups/exports.dart';

class UpdateNameController extends GetxController {
  static UpdateNameController get instance => Get.find();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final userController = UserController.instance;
  final userReposity = Get.put(UserReposity());
  GlobalKey<FormState> updateUserNameFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    // TODO: implement onInit
    initalizName();
    super.onInit();
  }

  Future<void> initalizName() async {
    firstName.text = userController.user.value.firstName;
    lastName.text = userController.user.value.lastName;
  }

  Future<void> updateUserName() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "We are updating your information...",
        TImages.docerAnimation,
      );

      if (!updateUserNameFormKey.currentState!.validate()) {
        // نفس مبدا العمل
        TFullScreenLoader.stopLoading();
        return;
      }
      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      Map<String, dynamic> name = {
        "FirstName": firstName.text.trim(),
        "LastName": lastName.text.trim(),
      };
      await userReposity.updateSingleField(name);
      userController.user.value.firstName = firstName.text.trim();
      userController.user.value.lastName = lastName.text.trim();
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
        title: "Congratulations",
        message: "Your Name has been updated.",
      );
      Get.off(() => const Profile());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(title: "Oh snap", message: e.toString());
    }
  }
}
