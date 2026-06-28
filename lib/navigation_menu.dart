import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/common/styles/t_bar_pixel_painter.dart';
import 'package:untitled2_ecom/data/services/notification_controller.dart';
import 'package:untitled2_ecom/features/personalization/screens/settings/settings.dart';
import 'package:untitled2_ecom/features/shop/screens/home/home.dart';
import 'package:untitled2_ecom/features/shop/screens/stores/store_guide_screen.dart';
import 'package:untitled2_ecom/features/shop/screens/wishList/wishList.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';
import 'dart:ui'; // ضروري لتأثير الزجاج (BackdropFilter)
import 'package:untitled2_ecom/utils/helpers/helper_functions.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Obx(
        () => Container(
          margin: const EdgeInsets.only(right: 24.0, left: 24.0, bottom: 24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: dark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: CustomPaint(
                // 🌟 التعديل الجوهري: حقن رسام البكسلات المخصص ليظهر كخلفية داخل البار الزجاجي
                painter: TBarPixelPainter(isDark: dark),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    navigationBarTheme: NavigationBarThemeData(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      labelTextStyle: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: dark ? Colors.white : TColors.primary,
                          );
                        }
                        return TextStyle(
                          fontSize: 11,
                          color: dark ? Colors.white60 : Colors.black54,
                        );
                      }),
                    ),
                  ),
                  child: NavigationBar(
                    height:
                        65, // رفع الارتفاع يسيراً ليعطي مساحة تنفس مريحة للبكسلات والأيقونات
                    elevation: 0,
                    backgroundColor: dark
                        ? TColors.dark.withOpacity(
                            0.45,
                          ) // تقليل الشفافية قليلاً لتبرز تدرجات البكسل
                        : Colors.white.withOpacity(0.5),
                    indicatorColor: dark
                        ? TColors.primary.withOpacity(0.2)
                        : TColors.primary.withOpacity(0.12),
                    selectedIndex: controller.selectedIndex.value,
                    onDestinationSelected: (value) =>
                        controller.selectedIndex.value = value,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                    destinations: [
                      NavigationDestination(
                        icon: Icon(
                          Iconsax.home,
                          color: dark ? Colors.white70 : Colors.black87,
                        ),
                        selectedIcon: const Icon(
                          Iconsax.home5,
                          color: TColors.primary,
                        ),
                        label: TTexts.home,
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Iconsax.shop,
                          color: dark ? Colors.white70 : Colors.black87,
                        ),
                        selectedIcon: const Icon(
                          Iconsax.shop5,
                          color: TColors.primary,
                        ),
                        label: TTexts.store,
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Iconsax.heart,
                          color: dark ? Colors.white70 : Colors.black87,
                        ),
                        selectedIcon: const Icon(
                          Iconsax.heart5,
                          color: TColors.primary,
                        ),
                        label: TTexts.wishlist,
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Iconsax.user,
                          color: dark ? Colors.white70 : Colors.black87,
                        ),
                        selectedIcon: const Icon(
                          Iconsax.user5,
                          color: TColors.primary,
                        ),
                        label: TTexts.profile,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();

  final Rx<int> selectedIndex = 0.obs;
  final screens = [Home(), StoreGuideScreen(), Wishlist(), Settings()];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    NotificationController.instance.requestPermissionAndGetToken();
  }
}
