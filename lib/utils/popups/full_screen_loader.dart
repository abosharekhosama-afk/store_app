import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/loaders/animation_loader.dart';
import 'package:untitled2_ecom/common/widgets/loaders/circular_loader.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';
import 'dart:ui';
import 'package:untitled2_ecom/utils/helpers/helper_functions.dart';

/// A utility class for managing a dynamic full-screen loading dialog.
class TFullScreenLoader {
  /// Open an elegant glassmorphic loading dialog with smooth blur effect.
  static void openLoadingDialog(String text, String animation) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false, // منع الرجوع بزر الخلف لإجبار العملية على الانتهاء بأمان
        child: BackdropFilter(
          // 🌟 إضافة تأثير ضبابي زجاجي (Blur) على الواجهة الخلفية للحفاظ على حيوية التطبيق
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
          child: Center(
            child: Container(
              // ضبط أبعاد الكارد لتكون متناسقة في منتصف الشاشة
              width: Get.width * 0.8,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                // 🌟 استخدام خلفية شفافة متكيفة مع وضع الجهاز (Dark/Light)
                color: THelperFunctions.isDarkMode(Get.context!)
                    ? TColors.darkContainer.withOpacity(0.85)
                    : TColors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: THelperFunctions.isDarkMode(Get.context!)
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // يجعل الكارد تتمدد بحسب المحتوى فقط دون ملء الشاشة
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الأنيميشن (Lottie الممرر عبر الدالة)
                  TAnimationLoaderWidget(text: text, animation: animation),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Pop-up circular loader dialog.
  static void popUpCircular() {
    if (Get.isDialogOpen == true) return; // حماية لمنع تكرار فتح الديالوج

    Get.defaultDialog(
      title: '',
      onWillPop: () async => false,
      content: const TCircularLoader(),
      backgroundColor: Colors.transparent,
    );
  }

  /// Stop the currently open loading dialog safely.
  static void stopLoading() {
    // 🌟 حماية أمنية: نتحقق أن هناك حوار مفتوح فعلياً لكي لا نقوم بـ pop للواجهة الأساسية بالخطأ
    if (Get.isDialogOpen == true ||
        Navigator.of(Get.overlayContext!).canPop()) {
      Navigator.of(Get.overlayContext!).pop();
    }
  }
}




/*
/// A utility class for managing a full-screen loading dialog.
class TFullScreenLoader {
  /// Open a full-screen loading dialog with a given text and animation.
  /// This method doesn't return anything.
  ///
  /// Parameters:
  ///   - text: The text to be displayed in the loading dialog.
  ///   - animation: The Lottie animation to be shown.
  static void openLoadingDialog(String text, String animation) {
    showDialog(
      context:
          Get.overlayContext!, // Use Get.overlayContext for overlay dialogs
      barrierDismissible:
          false, // The dialog can't be dismissed by tapping outside it
      builder: (_) => PopScope(
        canPop: false, // Disable popping with the back button
        child: Container(
          color: THelperFunctions.isDarkMode(Get.context!)
              ? TColors.darkContainer
              : TColors.white,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 250), // Adjust the spacing as needed
              TAnimationLoaderWidget(text: text, animation: animation),
            ],
          ),
        ),
      ),
    );
  }

  static void popUpCircular() {
    Get.defaultDialog(
      title: '',
      onWillPop: () async => false,
      content: const TCircularLoader(),
      backgroundColor: Colors.transparent,
    );
  }

  /// Stop the currently open loading dialog.
  /// This method doesn't return anything.
  static stopLoading() {
    Navigator.of(
      Get.overlayContext!,
    ).pop(); // Close the dialog using the Navigator
  }
}
*/