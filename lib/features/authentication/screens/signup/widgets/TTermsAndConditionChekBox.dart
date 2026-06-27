import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:untitled2_ecom/features/authentication/controllers/signup/signup_controllers.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class TTermsAndConditionChekBox extends StatelessWidget {
  const TTermsAndConditionChekBox({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = SignupControllers.instance;
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Obx(
            () => Checkbox(
              value: controller.privacyPolice.value,
              onChanged: (value) => controller.privacyPolice.value =
                  !controller.privacyPolice.value,
            ),
          ),
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${TTexts.iAgreeTo} ',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextSpan(
                text: '${TTexts.privacyPolicy} ',
                style: Theme.of(context).textTheme.bodyMedium!.apply(
                  decoration: TextDecoration.underline,
                  decorationColor: dark ? TColors.white : TColors.primary,
                ),
              ),
              TextSpan(
                text: '${TTexts.and} ',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextSpan(
                text: '${TTexts.termsOfUse} ',
                style: Theme.of(context).textTheme.bodyMedium!.apply(
                  decoration: TextDecoration.underline,
                  decorationColor: dark ? TColors.white : TColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
