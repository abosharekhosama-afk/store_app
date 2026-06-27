import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/common/styles/TBarPixelPainter.dart';
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

/*
class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      // التعديل 1: تفعيل امتداد المحتوى خلف البار لتأثير الزجاج
      extendBody: true,

      // التعديل 2: إعادة تصميم شريط التنقل السفلي ليكون عائماً وزجاجياً
      bottomNavigationBar: Obx(
        () => Container(
          // ضبط الهوامش لجعله عائماً بشكل متناسق (Floating Container)
          margin: const EdgeInsets.only(right: 24.0, left: 24.0, bottom: 24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), // حواف دائرية مودرن وناعمة
            boxShadow: [
              BoxShadow(
                color: dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(
                  0,
                  10,
                ), // دفع الظل للأسفل ليعطي إيحاء بالعمق
              ),
            ],
            // حافة زجاجية خفيفة جداً لتحديد الشكل الإنسيابي للبار
            border: Border.all(
              color: dark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              30,
            ), // قص المحتوى والزجاج بنفس انحناء الحواف
            child: BackdropFilter(
              // التعديل الجوهري: إضافة فلتر ضبابي (BackdropFilter) لخلق تأثير الزجاج
              filter: ImageFilter.blur(
                sigmaX: 15,
                sigmaY: 15,
              ), // قوة الفلتر؛ كلما زادت، زادت ضبابية الخلفية
              child: Theme(
                // تصفير ألوان الـ NavigationBar الافتراضية ليعمل الزجاج بشكل مثالي
                data: Theme.of(context).copyWith(
                  navigationBarTheme: NavigationBarThemeData(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    // تخصيص الخطوط والألوان العامة للنصوص والأيقونات غير المحددة
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
                      60, // تقليص الارتفاع قليلاً ليتناسب مع التصميم الدائري العائم
                  elevation: 0,
                  // التعديل 3: ضبط لون الخلفية ليكون شفافاً جزئياً ويتيح للزجاج العمل
                  backgroundColor: dark
                      ? TColors.dark.withOpacity(
                          0.65,
                        ) // شفافية تتيح للزجاج فلترة الخلفية الغامقة
                      : Colors.white.withOpacity(
                          0.7,
                        ), // شفافية تتيح للزجاج فلترة الخلفية الفاتحة
                  // خلفية مؤشر الأيقونة المحددة
                  indicatorColor: dark
                      ? TColors.primary.withOpacity(0.15)
                      : TColors.primary.withOpacity(0.08),

                  selectedIndex: controller.selectedIndex.value,
                  onDestinationSelected: (value) =>
                      controller.selectedIndex.value = value,

                  // إخفاء العناوين غير المحددة وإظهار المحددة فقط يعطي طابعاً أكثر حداثة
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

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
                        Iconsax.user,
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
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}
*/
/*
class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      // يضمن امتداد المحتوى خلف البار ليعطي التأثير الزجاجي مع حركة السكرول
      extendBody: true,

      bottomNavigationBar: Obx(
        () => Container(
          // ضبط الهوامش لجعله عائماً (Floating) بشكل متناسق
          margin: const EdgeInsets.only(right: 24.0, left: 24.0, bottom: 24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), // حواف دائرية مودرن وناعمة
            boxShadow: [
              BoxShadow(
                color: dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(
                  0,
                  10,
                ), // دفع الظل للأسفل ليعطي إيحاء بالعمق
              ),
            ],
            // حافة زجاجية خفيفة جداً لتحديد الشكل الإنسيابي للبار
            border: Border.all(
              color: dark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              30,
            ), // قص المحتوى والزجاج بنفس انحناء الحواف
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 15,
                sigmaY: 15,
              ), // قوة الفلتر الزجاجي
              child: Theme(
                // 🛠️ التعديل الجوهري: تصفير ألوان الـ NavigationBar الافتراضية ليعمل الزجاج بشكل مثالي
                data: Theme.of(context).copyWith(
                  navigationBarTheme: NavigationBarThemeData(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    // تخصيص الخطوط والألوان العامة للنصوص والأيقونات غير المحددة
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
                      60, // تقليص الارتفاع قليلاً ليتناسب مع التصميم الدائري العائم
                  elevation: 0,
                  backgroundColor: dark
                      ? TColors.dark.withOpacity(
                          0.65,
                        ) // شفافية تتيح للزجاج فلترة الخلفية الغامقة
                      : Colors.white.withOpacity(
                          0.7,
                        ), // شفافية تتيح للزجاج فلترة الخلفية الفاتحة
                  // خلفية مؤشر الأيقونة المحددة
                  indicatorColor: dark
                      ? TColors.primary.withOpacity(0.15)
                      : TColors.primary.withOpacity(0.08),

                  selectedIndex: controller.selectedIndex.value,
                  onDestinationSelected: (value) =>
                      controller.selectedIndex.value = value,

                  // إخفاء العناوين غير المحددة وإظهار المحددة فقط يعطي طابعاً أكثر حداثة (Modern Minimalist)
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

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
                        Iconsax.user,
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
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}
*/
/*
class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      // لجعل المحتوى يمتد خلف شريط التنقل (ضروري لتأثير الزجاج)
      extendBody: true,

      bottomNavigationBar: Obx(
        () => Container(
          margin: EdgeInsets.only(
            right: TSizes.defaultSpace * 2,
            left: TSizes.defaultSpace * 2,
            bottom: TSizes.defaultSpace * 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            /*border: Border(
              top: BorderSide(
                color: dark ? TColors.borderDark : TColors.borderLight,
                width: 0.5,
              ),
            ),*/
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 15,
                sigmaY: 15,
              ), // قوة تأثير الزجاج
              child: NavigationBar(
                height: 75,
                elevation: 0,
                // استخدام ألوان شفافة للسماح للزجاج بالظهور
                backgroundColor: dark
                    ? TColors.dark.withOpacity(0.8)
                    : TColors.softWhite.withOpacity(0.8),

                // لون مؤشر التحديد (بيج ناعم في الفاتح / فحمي في الغامق)
                indicatorColor: dark
                    ? TColors.secondary.withOpacity(0.2)
                    : TColors.accent.withOpacity(0.3),

                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: (value) =>
                    controller.selectedIndex.value = value,

                // تخصيص شكل الأيقونات والنصوص لتكون "Minimalist"
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Iconsax.home),
                    selectedIcon: const Icon(
                      Iconsax.home5,
                      color: TColors.primary,
                    ),
                    label: TTexts.home,
                  ),
                  NavigationDestination(
                    icon: const Icon(Iconsax.shop),
                    selectedIcon: const Icon(
                      Iconsax.shop5,
                      color: TColors.primary,
                    ),
                    label: TTexts.store,
                  ),
                  NavigationDestination(
                    icon: const Icon(Iconsax.heart),
                    selectedIcon: const Icon(
                      Iconsax.heart5,
                      color: TColors.primary,
                    ),
                    label: TTexts.wishlist,
                  ),
                  NavigationDestination(
                    icon: const Icon(Iconsax.user),
                    selectedIcon: const Icon(
                      Iconsax.user,
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
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}
*/
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
