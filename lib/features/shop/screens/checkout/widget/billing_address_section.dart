import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/features/personalization/controllers/address_controller.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class TBillingAddressSection extends StatelessWidget {
  const TBillingAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final addressController = AddressController.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionHeading(
          labelText: "عنوان التوصيل الرئيسي",
          showButtton: true,
          labelButton: "تغيير",
          onPressed: () => addressController.selectNewAddressPopup(context),
          padding: EdgeInsets.zero,
        ),
        Obx(() {
          final selected = addressController.selctedAddress.value;
          return selected.id.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected.fullAddress,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems / 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_city,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: TSizes.sm),
                        Text(
                          "${selected.city}, ${selected.district}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                )
              : Text(
                  "يرجى اختيار عنوان لشحن الطلب",
                  style: TextStyle(color: Colors.red.shade400),
                );
        }),
      ],
    );
  }
}





/*
class TBillingAddressSection extends StatelessWidget {
  const TBillingAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final addressController = AddressController.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionHeading(
          labelText: "Shipping Address",
          showButtton: true,
          labelButton: "Change",
          onPressed: () => addressController.selectNewAddressPopup(context),
          padding: EdgeInsets.all(0),
        ),
        addressController.selctedAddress.value.id.isNotEmpty
            ? Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      addressController.selctedAddress.value.fullAddress,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.black, size: 16),
                        const SizedBox(width: TSizes.spaceBtwItems),
                        /*Text(
                          addressController.selctedAddress.value.phoneNumber,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),*/
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems / 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_history,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems),
                        Text(
                          addressController.selctedAddress.value.address,
                          style: Theme.of(context).textTheme.bodyMedium,
                          softWrap: true,
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Text(
                "Select Address",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

        //const SizedBox(height: TSizes.spaceBtwItems / 2),
      ],
    );
  }
}
*/