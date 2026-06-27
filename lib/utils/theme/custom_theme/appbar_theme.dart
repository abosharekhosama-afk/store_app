import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';

class TAppBarTheme {
  TAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    // نستخدم اللون الشفاف للسماح بتأثير الزجاج (BackdropFilter) في الـ Widget نفسه
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,

    // التحكم في شريط الحالة (Status Bar) ليكون نظيفاً
    systemOverlayStyle: SystemUiOverlayStyle.dark,

    // الأيقونات باللون الفحمي الهادئ بدلاً من الأسود الصارخ
    iconTheme: IconThemeData(color: TColors.textPrimary, size: 24),
    actionsIconTheme: IconThemeData(color: TColors.textPrimary, size: 24),

    // الخطوط بطابع مودرن وهادئ
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: TColors.textPrimary,
      fontFamily: 'Urbanist', // أو Cairo للعربية
      letterSpacing: -0.5, // لمسة مودرن لتقليل تباعد الحروف
    ),
  );

  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,

    systemOverlayStyle: SystemUiOverlayStyle.light,

    iconTheme: IconThemeData(color: TColors.textWhite, size: 24),
    actionsIconTheme: IconThemeData(color: TColors.textWhite, size: 24),

    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: TColors.textWhite,
      fontFamily: 'Urbanist',
      letterSpacing: -0.5,
    ),
  );
}









/*
class TAppBarTheme {
  TAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.black, size: 24),
    actionsIconTheme: IconThemeData(color: Colors.black, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  );
  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.black, size: 24),
    actionsIconTheme: IconThemeData(color: Colors.white, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );
}
*/