import 'package:flutter/material.dart';
import 'package:untitled2_ecom/features/authentication/controllers/controllers_onbarding/onboarding_controller.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/utils/device/device_utils.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;
    return Positioned(
      top: TDeviceUtils.getAppBarHeight(),
      right: TSizes.defaultSpace,
      child: TextButton(
        child: Text(TTexts.skip),
        onPressed: () {
          print("-----------------");
          controller.skipPage();
        },
      ),
    );
  }
}
