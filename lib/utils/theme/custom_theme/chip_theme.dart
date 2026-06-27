import 'package:flutter/material.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

import 'package:flutter/material.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class TChipTheme {
  TChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: TColors.grey.withOpacity(0.4),
    // نص أسود فحمي هادئ للحالة العادية
    labelStyle: const TextStyle(
      color: TColors.textPrimary,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    // لون التحديد هو الأسود الفحمي ليعطي تبايناً قوياً ونظيفاً
    selectedColor: TColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    checkmarkColor: TColors.white,
    showCheckmark: false, // للحفاظ على المظهر المودرن النظيف
    brightness: Brightness.light,
    // زوايا دائرية بالكامل (Pill Shape) تعطي انطباعاً أحدث بكثير
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
      side: const BorderSide(
        color: TColors.borderLight,
      ), // حدود خفيفة جداً للحالة غير المختارة
    ),
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: TColors.darkerGrey,
    labelStyle: const TextStyle(
      color: TColors.textWhite,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    // في الوضع الداكن نستخدم اللون البيج/اللاتيه للتحديد لكسر حدة السواد
    selectedColor: TColors.secondary,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    checkmarkColor: TColors.primary,
    showCheckmark: false,
    brightness: Brightness.dark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
      side: BorderSide(color: TColors.darkerGrey),
    ),
  );
}









/*
class TChipTheme {
  TChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: Colors.white,
    labelStyle: TextStyle(color: Colors.black),
    selectedColor: TColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    checkmarkColor: Colors.white,
    showCheckmark: false,
    brightness: Brightness.light,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TSizes.sm),
    ),
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: TColors.darkerGrey,
    labelStyle: TextStyle(color: Colors.white),
    selectedColor: TColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    checkmarkColor: Colors.white,
    showCheckmark: false,
    brightness: Brightness.dark,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );
}
*/