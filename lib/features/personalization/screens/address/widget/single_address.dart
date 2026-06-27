import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/common/widgets/contaniners/rounded_container.dart';
import 'package:untitled2_ecom/features/personalization/controllers/address_controller.dart';
import 'package:untitled2_ecom/features/personalization/models/address_model_new.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class SingleAddress extends StatelessWidget {
  const SingleAddress({super.key, required this.address, required this.otTap});
  final AddressModelNew address;
  final VoidCallback otTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = AddressController.instance;

    return Obx(() {
      final selectedAddressId = controller.selctedAddress.value.id;
      final isSelected = selectedAddressId == address.id;

      return Padding(
        padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
        child: TRoundedContainer(
          width: double.infinity,
          showBorder: false,
          // اجعل لون الخلفية خفيفاً جداً عند الاختيار ليعطي طابعاً حديثاً
          backgroundColor: isSelected
              ? TColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderColor: isSelected
              ? TColors.primary
              : dark
              ? TColors.darkerGrey
              : TColors.grey,
          child: InkWell(
            onTap: otTap,
            // هذا السطر هو الحل لمشكلة الـ Border Radius في الهوفر
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            child: Padding(
              padding: const EdgeInsets.all(TSizes.md),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Icon(
                      isSelected ? Iconsax.tick_circle5 : null,
                      color:
                          TColors.primary, // استخدم لون التطبيق الأساسي للعلامة
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.fullAddress,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: isSelected
                              ? TColors.primary
                              : (dark ? TColors.white : TColors.black),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems / 2),

                      // تفاصيل العنوان بتصميم أنظف
                      /* Row(
                        children: [
                          Icon(
                            Iconsax.building_3,
                            size: 16,
                            color: dark ? TColors.lightGrey : TColors.darkGrey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Building: ${address.buildingNumber}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),*/
                      Row(
                        children: [
                          Icon(
                            Iconsax.info_circle,
                            size: 16,
                            color: dark ? TColors.lightGrey : TColors.darkGrey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              address.address,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}












/*
class SingleAddress extends StatelessWidget {
  const SingleAddress({super.key, required this.address, required this.otTap});
  final AddressModelNew address;
  final VoidCallback otTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = AddressController.instance;
    return Obx(() {
      final selectedAddressId = controller.selctedAddress.value.id;
      final selectedAddress = selectedAddressId == address.id;
      return InkWell(
        onTap: otTap,
        child: TRoundedContainer(
          width: double.infinity,
          showBorder: true,
          backgroundColor: selectedAddress
              ? TColors.primary.withValues(alpha: 0.6)
              : Colors.transparent,
          borderColor: selectedAddress
              ? Colors.transparent
              : dark
              ? TColors.darkerGrey
              : TColors.grey,
          margin: EdgeInsets.only(bottom: TSizes.spaceBtwItems),
          padding: EdgeInsets.all(TSizes.md),
          child: Stack(
            children: [
              Positioned(
                right: 10,
                top: 0,
                child: Icon(
                  selectedAddress ? Iconsax.tick_circle5 : null,
                  color: dark ? TColors.white : TColors.dark.withOpacity(0.7),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.fullAddress,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: TSizes.spaceBtwItems / 2),
                  /*Text(
                    address.formattedPhoneNo,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: TSizes.spaceBtwItems / 2),*/
                  Text(
                    address.address,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
*/