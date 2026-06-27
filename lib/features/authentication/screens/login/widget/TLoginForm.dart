import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/features/authentication/controllers/login/login_controller.dart';
import 'package:untitled2_ecom/features/authentication/screens/password_configration/forget_password.dart';
import 'package:untitled2_ecom/features/authentication/screens/signup/signup.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/utils/validators/validation.dart';

class TLoginForm extends StatelessWidget {
  const TLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.email,
            validator: (value) {
              return TValidator.validateEmail(value);
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Iconsax.direct_right),
              labelText: TTexts.email,
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputField),
          Obx(
            () => TextFormField(
              validator: (value) => TValidator.validatePassword(value),
              controller: controller.password,
              obscureText: controller.hidePassword.value,
              decoration: InputDecoration(
                prefixIcon: Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () => controller.hidePassword.value =
                      !controller.hidePassword.value,
                  icon: Icon(
                    controller.hidePassword.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                  ),
                ),
                labelText: TTexts.tPassword,
              ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputField / 2),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Obx(
                    () => Checkbox(
                      value: controller.rememberMe.value,
                      onChanged: (value) {
                        controller.rememberMe.value =
                            !controller.rememberMe.value;
                      },
                    ),
                  ),
                  const Text(TTexts.tRememberMe),
                ],
              ),
              TextButton(
                onPressed: () => Get.to(() => ForgetPassword()),
                child: Text(TTexts.tForgetPassword),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwInputField / 2),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.emailAndpasswordLoginin(),
              child: const Text(TTexts.tSignIn),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Get.to(() => Signup()),
              child: const Text(TTexts.tCreateAccount),
            ),
          ),
        ],
      ),
    );
  }
}
