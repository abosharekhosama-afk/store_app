import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/styles/spacing_styles.dart';
import 'package:untitled2_ecom/common/widgets/widgets_login_signup/TFormDivider.dart';
import 'package:untitled2_ecom/features/authentication/screens/login/widget/TLoginForm.dart';
import 'package:untitled2_ecom/features/authentication/screens/login/widget/TLoginHeader.dart';
import 'package:untitled2_ecom/common/widgets/widgets_login_signup/TSocialButtons.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class LogineScreen extends StatelessWidget {
  const LogineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingwithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TLoginHeader(dark: dark),
              const SizedBox(height: TSizes.spaceBtwSections),
              TLoginForm(),
              const SizedBox(height: TSizes.spaceBtwSections),
              TFormDivider(dividerText: TTexts.tOrSignInWith),
              const SizedBox(height: TSizes.spaceBtwSections),
              TSocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
