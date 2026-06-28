import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/features/personalization/controllers/address_controller.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/validators/validation.dart';

class AddressFormWidget extends StatelessWidget {
  const AddressFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AddressController.instance; // استخدام الكنترولر الموحد

    return Scaffold(
      appBar: TAppbar(title: const Text("اضافة عنوان")),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: ElevatedButton(
          onPressed: () => controller.addNewAddresses(),
          child: Text("اضافة عنوان"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                // 1. المحافظة
                DropdownSearch<String>(
                  items: (filter, loadProps) =>
                      controller.palestineAddressData.keys.toList(),
                  decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: "المحافظة",
                      prefixIcon: Icon(Iconsax.location),
                    ),
                  ),
                  onChanged: (value) => controller.onCityChanged(value),
                  validator: (value) =>
                      TValidator.validateEmptyText("المحافظة", value),
                  selectedItem: controller.selectedCity.value.isEmpty
                      ? null
                      : controller.selectedCity.value,
                ),

                const SizedBox(height: TSizes.spaceBtwInputField),

                // 2. المنطقة (تحتاج Obx لأن القائمة تتغير)
                Obx(
                  () => DropdownSearch<String>(
                    items: (filter, loadProps) => controller.districtsList,
                    enabled: controller.selectedCity.isNotEmpty,
                    selectedItem: controller.selectedDistrict.value.isEmpty
                        ? null
                        : controller.selectedDistrict.value,
                    onChanged: (value) => controller.onDistrictChanged(value),
                    validator: (value) =>
                        TValidator.validateEmptyText("المنطقة/الحي", value),
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: "المنطقة/الحي",
                        hintText: controller.selectedCity.isEmpty
                            ? "اختر المحافظة أولاً"
                            : "اختر المنطقة",
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwInputField),

                // 3. الشارع
                Obx(
                  () => DropdownSearch<String>(
                    items: (filter, loadProps) => controller.streetsList,
                    enabled: controller.selectedDistrict.isNotEmpty,
                    selectedItem: controller.selectedStreet.value.isEmpty
                        ? null
                        : controller.selectedStreet.value,
                    onChanged: (value) => controller.onStreetChanged(value),
                    validator: (value) => TValidator.validateEmptyText(
                      "الشارع/الحي الفرعي",
                      value,
                    ),
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: "الشارع/الحي الفرعي",
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwInputField),

                // 3. المعالم
                Obx(
                  () => DropdownSearch<String>(
                    items: (filter, loadProps) => controller.landmarksList,
                    enabled: controller.selectedDistrict.isNotEmpty,
                    selectedItem: controller.selectedMarks.value.isEmpty
                        ? null
                        : controller.selectedMarks.value,
                    onChanged: (value) => controller.onMarksChanged(value),
                    validator: (value) =>
                        TValidator.validateEmptyText("اقرب معلم", value),
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(labelText: "اقرب معلم"),
                    ),
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwInputField),

                // 4. رقم المبنى
                TextFormField(
                  controller: controller.buildingNumberController,
                  decoration: const InputDecoration(
                    labelText: "رقم المبنى",
                    prefixIcon: Icon(Iconsax.building),
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwInputField),

                // 5. الرمز البريدي
                TextFormField(
                  controller: controller.postalCodeController,
                  decoration: const InputDecoration(
                    labelText: "الرمز البريدي",
                    prefixIcon: Icon(Iconsax.code),
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwInputField),

                // 6. العنوان التفصيلي
                TextFormField(
                  controller: controller.addressDetailsController,
                  validator: (value) =>
                      TValidator.validateEmptyText("العنوان التفصيلي", value),
                  decoration: const InputDecoration(
                    labelText: "العنوان التفصيلي",
                    prefixIcon: Icon(Iconsax.info_circle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
