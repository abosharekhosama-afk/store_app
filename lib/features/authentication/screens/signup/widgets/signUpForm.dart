import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/features/authentication/controllers/signup/signup_controllers.dart';
import 'package:untitled2_ecom/features/authentication/screens/signup/widgets/TTermsAndConditionChekBox.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/utils/validators/validation.dart';

class Signupform extends StatelessWidget {
  const Signupform({super.key});

  @override
  Widget build(BuildContext context) {
    //final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(SignupControllers());
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.firstName,
                  validator: (value) =>
                      TValidator.validateEmptyText("First name", value),
                  expands: false,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: TTexts.tFirstName,
                  ),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwInputField),
              Expanded(
                child: TextFormField(
                  controller: controller.lastName,
                  validator: (value) =>
                      TValidator.validateEmptyText("Last name", value),

                  expands: false,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Iconsax.personalcard),
                    labelText: TTexts.tLastName,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwInputField),
          TextFormField(
            controller: controller.userName,
            validator: (value) =>
                TValidator.validateEmptyText("Username", value),

            decoration: InputDecoration(
              prefixIcon: Icon(Iconsax.user_edit),
              labelText: TTexts.tUserName,
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputField),
          TextFormField(
            controller: controller.email,
            validator: (value) => TValidator.validateEmail(value),
            decoration: InputDecoration(
              prefixIcon: Icon(Iconsax.direct),
              labelText: TTexts.tEmail,
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputField),
          TextFormField(
            controller: controller.phoneNumber,
            validator: (value) => TValidator.validatePhoneNumber(value),
            decoration: InputDecoration(
              prefixIcon: Icon(Iconsax.call),
              labelText: TTexts.tPhoneNumber,
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
          const SizedBox(height: TSizes.spaceBtwSections),
          TTermsAndConditionChekBox(),
        ],
      ),
    );
  }
}
