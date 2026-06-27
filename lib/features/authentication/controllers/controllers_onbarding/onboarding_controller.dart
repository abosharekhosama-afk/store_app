import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:untitled2_ecom/features/authentication/screens/login/logine.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  void updatePageIndicator(index) => currentPageIndex.value = index;

  void doNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  void nextPage(BuildContext context) {
    if (currentPageIndex.value == 2) {
      Get.offAll(const LogineScreen());
      final storage = GetStorage();
      storage.write("isFirstTime", false);
      //THelperFunctions.navigateToScreen(context, LogineScreen());
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  void skipPage() {
    currentPageIndex.value = 2;
    pageController.jumpTo(2);
  }
}
