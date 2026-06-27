import 'package:get/get.dart';
import 'package:untitled2_ecom/features/authentication/controllers/controllers_onbarding/onboarding_controller.dart';
import 'package:untitled2_ecom/features/authentication/screens/onBoarding/widget/OnBoardingNextButton.dart';
import 'package:untitled2_ecom/features/authentication/screens/onBoarding/widget/OnBoardingSkip.dart';
import 'package:untitled2_ecom/features/authentication/screens/onBoarding/widget/OnBoradingDotNavigation.dart';
import 'package:untitled2_ecom/features/authentication/screens/onBoarding/widget/OnBordingPage.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    return Scaffold(
      body: Stack(
        children: [
          OnBoardingSkip(),
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              OnBordingPage(
                image: TImages.tOnBoardingImage1,
                title: TTexts.tOnBoardingTitle1,
                subTitle: TTexts.tOnBoardingSubTitle1,
              ),
              OnBordingPage(
                image: TImages.tOnBoardingImage2,
                title: TTexts.tOnBoardingTitle2,
                subTitle: TTexts.tOnBoardingSubTitle2,
              ),
              OnBordingPage(
                image: TImages.tOnBoardingImage3,
                title: TTexts.tOnBoardingTitle3,
                subTitle: TTexts.tOnBoardingSubTitle3,
              ),
            ],
          ),
          OnBoradingDotNavigation(),
          OnBoardingNextButton(),
        ],
      ),
    );
  }
}
