import 'package:flutter/material.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';

import 'package:flutter/material.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class TElevatedButtonTheme {
  TElevatedButtonTheme._();

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      // النص أبيض ناصع فوق الخلفية السوداء الفحمية
      foregroundColor: TColors.textWhite,
      backgroundColor: TColors.primary, // الأسود الفحمي الهادئ
      disabledForegroundColor: TColors.grey,
      disabledBackgroundColor: TColors.softGrey,
      side: const BorderSide(color: TColors.primary),
      padding: const EdgeInsets.symmetric(vertical: TSizes.buttonHeight),
      textStyle: const TextStyle(
        fontSize: 16,
        color: TColors.textWhite,
        fontWeight: FontWeight.w600,
        fontFamily: 'Urbanist', // خط مودرن
        letterSpacing: 0.5,
      ),
      // حواف دائرية أكثر حداثة (14-16 تعطي طابعاً أفخم من 12)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: TColors.primary, // في الوضع الداكن النص أسود
      backgroundColor:
          TColors.secondary, // والخلفية هي اللون البيج/اللاتيه للتباين
      disabledForegroundColor: TColors.grey,
      disabledBackgroundColor: TColors.darkerGrey,
      side: const BorderSide(color: TColors.secondary),
      padding: const EdgeInsets.symmetric(vertical: TSizes.buttonHeight),
      textStyle: const TextStyle(
        fontSize: 16,
        color: TColors.primary,
        fontWeight: FontWeight.w600,
        fontFamily: 'Urbanist',
        letterSpacing: 0.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}









/*
class TElevatedButtonTheme {
  TElevatedButtonTheme._();

  static final lighetElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: TColors.dark,
      backgroundColor: TColors.primary,
      disabledForegroundColor: TColors.grey,
      disabledBackgroundColor: TColors.grey,
      side: BorderSide(color: TColors.primary),
      padding: EdgeInsets.symmetric(vertical: 18),
      textStyle: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: TColors.primary,
      disabledForegroundColor: TColors.grey,
      disabledBackgroundColor: TColors.grey,
      side: BorderSide(color: TColors.primary),
      padding: EdgeInsets.symmetric(vertical: 18),
      textStyle: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
*/