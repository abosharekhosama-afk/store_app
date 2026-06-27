import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/device/device_utils.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';
import 'package:get/get.dart';
import '../../../../utils/helpers/helper_functions.dart';

class TAppbar extends StatelessWidget implements PreferredSizeWidget {
  const TAppbar({
    super.key,
    this.title,
    this.showBackArrow = true,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
    this.showBlur = true,
  });

  final Widget? title;
  final bool showBackArrow;
  final bool showBlur; // المتغير الجديد للتحكم في الضبابية

  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);

    return Padding(
      // قمت بإزالة الـ Padding الجانبي هنا لكي يمتد تأثير الزجاج على كامل العرض (أفضل بصرياً)
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ClipRRect(
        child: BackdropFilter(
          // إذا كان showBlur true نضع قوة 12، وإذا كان false نضع 0 (بدون ضبابية)
          filter: ImageFilter.blur(
            sigmaX: showBlur ? 12.0 : 0.0,
            sigmaY: showBlur ? 12.0 : 0.0,
          ),
          child: AppBar(
            // نجعل خلفية الـ AppBar شفافة لكي يظهر تأثير الضبابية أو ما خلفه
            backgroundColor: showBlur
                ? (dark
                      ? TColors.dark.withOpacity(0.7)
                      : TColors.softWhite.withOpacity(0.7))
                : Colors.transparent,
            elevation: 0,

            automaticallyImplyLeading: false,
            leading: showBackArrow
                ? IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons
                          .arrow_back, // تم تغيير السهم للاتجاه العالمي (اليسار) للرجوع
                      color: dark ? TColors.white : TColors.primary,
                    ),
                  )
                : leadingIcon != null
                ? IconButton(
                    onPressed: leadingOnPressed,
                    icon: Icon(
                      leadingIcon,
                      color: dark ? TColors.white : TColors.primary,
                    ),
                  )
                : null,
            title: title,
            actions: actions,
            centerTitle: false, // ليعطي طابع الميني ماليزم النظيف
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: dark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: dark ? Brightness.dark : Brightness.light,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight());
}
