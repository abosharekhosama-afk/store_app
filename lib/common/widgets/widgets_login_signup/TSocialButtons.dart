import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:untitled2_ecom/features/authentication/controllers/login/login_controller.dart';
import 'package:untitled2_ecom/navigation_menu.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class TSocialButtons extends StatelessWidget {
  const TSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: TColors.grey),
          ),
          child: IconButton(
            onPressed: () => controller.googleSignIn(),
            icon: Image(
              height: TSizes.iconMd,
              width: TSizes.iconMd,
              image: AssetImage(TImages.tGoogleLogo),
            ),
          ),
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: TColors.grey),
          ),
          child: IconButton(
            onPressed: () => Get.to(NavigationMenu()),
            icon: Image(
              height: TSizes.iconMd,
              width: TSizes.iconMd,
              image: AssetImage(TImages.tFacebookLogo),
            ),
          ),
        ),
      ],
    );
  }
}
