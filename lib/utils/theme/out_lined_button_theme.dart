import 'package:flutter/material.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class TOutlinedButtonTheme {
  TOutlinedButtonTheme._();

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      // نص باللون الفحمي الهادئ بدلاً من الأسود الصرف
      foregroundColor: TColors.textPrimary,
      // حدود رقيقة جداً بلون البيج الداكن أو الرمادي المودرن
      side: const BorderSide(color: TColors.borderPrimary, width: 1),
      textStyle: const TextStyle(
        fontSize: 16,
        color: TColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontFamily: 'Urbanist',
        letterSpacing: 0.5,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: TSizes.buttonHeight,
      ),
      // حواف متناسقة مع الزر الرئيسي (14) لتوحيد لغة التصميم
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: TColors.textWhite,
      side: const BorderSide(color: TColors.borderDark, width: 1),
      textStyle: const TextStyle(
        fontSize: 16,
        color: TColors.textWhite,
        fontWeight: FontWeight.w600,
        fontFamily: 'Urbanist',
        letterSpacing: 0.5,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: TSizes.buttonHeight,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}








/*
class TOutLinedButtonTheme {
  TOutLinedButtonTheme._();

  static final lightOutLinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.black,
      side: BorderSide(color: TColors.primary),
      textStyle: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  static final darkOutLinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: BorderSide(color: TColors.primary),
      textStyle: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
*/