import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/theme/custom_theme/appbar_theme.dart';
import 'package:untitled2_ecom/utils/theme/custom_theme/bottom_sheet_theme.dart';
import 'package:untitled2_ecom/utils/theme/custom_theme/checkbox_theme.dart';
import 'package:untitled2_ecom/utils/theme/custom_theme/chip_theme.dart';
import 'package:untitled2_ecom/utils/theme/custom_theme/elevated_button_theme.dart';
import 'package:untitled2_ecom/utils/theme/custom_theme/text_form_field_theme.dart';
import 'package:untitled2_ecom/utils/theme/custom_theme/text_theme.dart';
import 'package:untitled2_ecom/utils/theme/out_lined_button_theme.dart';
import 'package:flutter/material.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: TColors.primary,
    textTheme: TTextTheme.lightTextTheme,
    chipTheme: TChipTheme.lightChipTheme,
    scaffoldBackgroundColor: TColors.softWhite,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    checkboxTheme: TCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: TBottomSheetTheme.lightAppBarTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: TColors.primary,
    textTheme: TTextTheme.darkTextTheme,
    chipTheme: TChipTheme.darkChipTheme,
    scaffoldBackgroundColor: TColors.dark,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    checkboxTheme: TCheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: TBottomSheetTheme.darkAppBarTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
  );
}
