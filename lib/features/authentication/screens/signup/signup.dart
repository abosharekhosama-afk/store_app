import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/styles/spacing_styles.dart';
import 'package:untitled2_ecom/common/widgets/widgets_login_signup/TFormDivider.dart';
import 'package:untitled2_ecom/common/widgets/widgets_login_signup/TSocialButtons.dart';
import 'package:untitled2_ecom/features/authentication/controllers/signup/signup_controllers.dart';
import 'package:untitled2_ecom/features/authentication/screens/signup/widgets/signUpForm.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    //final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(SignupControllers());
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingwithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TTexts.tSignUpTitle1,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              Signupform(),
              const SizedBox(height: TSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.signup(),
                  child: Text(TTexts.tCreateAccount),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),
              TFormDivider(dividerText: TTexts.tOrSignUpWith),
              const SizedBox(height: TSizes.spaceBtwSections),
              TSocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
