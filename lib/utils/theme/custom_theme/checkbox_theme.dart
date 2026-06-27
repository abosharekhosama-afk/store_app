import 'package:flutter/material.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';

import 'package:flutter/material.dart';
import '../../../../utils/constants/colors.dart';

class TCheckboxTheme {
  TCheckboxTheme._();

  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    // زيادة انحناء الزوايا قليلاً ليعطي ملمساً أنعم (Modern Soft Look)
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),

    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.white; // استخدام أبيض ناصع لعلامة الصح عند التحديد
      }
      return null;
    }),

    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.primary; // الأسود الفحمي الهادئ عند الاختيار
      } else {
        return Colors.transparent;
      }
    }),

    // لون الحدود في الحالة العادية
    side: const BorderSide(color: TColors.borderDark),
  );

  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),

    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.white;
      }
      return TColors.black;
    }),

    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors
            .secondary; // استخدام اللون البيج/اللاتيه في الوضع الداكن للتباين
      } else {
        return Colors.transparent;
      }
    }),

    side: const BorderSide(color: TColors.borderLight),
  );
}










/*
class TCheckboxTheme {
  TCheckboxTheme._();

  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      } else {
        return Colors.black;
      }
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.primary;
      } else {
        return Colors.transparent;
      }
    }),
  );

  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      } else {
        return Colors.black;
      }
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.primary;
      } else {
        return Colors.transparent;
      }
    }),
  );
}
*/