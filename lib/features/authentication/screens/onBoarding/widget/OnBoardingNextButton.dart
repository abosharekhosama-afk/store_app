import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/features/authentication/controllers/controllers_onbarding/onboarding_controller.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/device/device_utils.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;
    return Positioned(
      bottom: TDeviceUtils.getBottomNavigationBarHeight(),
      right: TSizes.defaultSpace,
      child: ElevatedButton(
        onPressed: () => controller.nextPage(context),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          //backgroundColor: dark ? TColors.primary : TColors.black,
        ),
        child: Icon(Iconsax.arrow_right_3),
      ),
    );
  }
}
