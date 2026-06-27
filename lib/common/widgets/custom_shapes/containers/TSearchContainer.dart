import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/device/device_utils.dart';
import 'package:untitled2_ecom/utils/helpers/helper_functions.dart';

class TSearchContainer extends StatelessWidget {
  const TSearchContainer({
    super.key,
    required this.serarchLabel,
    this.icon = Iconsax.search_normal,
    this.showBorder = true,
    this.showBackground = true,
    this.padding = const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
    this.onChanged, // أضفنا هذا لالتقاط النص
  });

  final String serarchLabel;
  final bool showBackground;
  final IconData? icon;
  final bool? showBorder;
  final EdgeInsetsGeometry padding;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    return Padding(
      padding: padding,
      child: Container(
        width: TDeviceUtils.getScreenWidth(context),
        decoration: BoxDecoration(
          color: showBackground
              ? (dark ? TColors.dark : TColors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: showBorder == true ? Border.all(color: TColors.grey) : null,
        ),
        child: TextField(
          onChanged: onChanged, // ربط الدالة هنا
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: TColors.darkGrey),
            hintText: serarchLabel,
            hintStyle: Theme.of(context).textTheme.bodySmall,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
