import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/features/personalization/controllers/update_name_controller.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/utils/validators/validation.dart';

class ChangeName extends StatelessWidget {
  const ChangeName({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateNameController());
    return Scaffold(
      appBar: TAppbar(
        showBackArrow: true,
        title: Text(
          "تغيير الاسم",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            Text(
              "استخدم الاسم الحقيقي لتسهيل التحقق، سيظهر هذا الاسم في عدة صفحات.",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            Form(
              key: controller.updateUserNameFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.firstName,
                    validator: (value) =>
                        TValidator.validateEmptyText("First name", value),
                    //expands: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Iconsax.user),
                      labelText: TTexts.tFirstName,
                    ),
                  ),

                  SizedBox(height: TSizes.spaceBtwInputField),
                  TextFormField(
                    controller: controller.lastName,
                    validator: (value) =>
                        TValidator.validateEmptyText("Last name", value),

                    //expands: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Iconsax.personalcard),
                      labelText: TTexts.tLastName,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateUserName(),
                child: Text("حفظ"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
