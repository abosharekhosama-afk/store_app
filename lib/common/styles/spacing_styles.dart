import 'package:flutter/material.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class TSpacingStyle {
  static const EdgeInsetsGeometry paddingwithAppBarHeight =
      EdgeInsetsGeometry.only(
        top: TSizes.appBarHeight,
        bottom: TSizes.defaultSpace,
        left: TSizes.defaultSpace,
        right: TSizes.defaultSpace,
      );
}
