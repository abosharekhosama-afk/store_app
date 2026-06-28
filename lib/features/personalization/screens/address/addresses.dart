import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/features/personalization/controllers/address_controller.dart';
import 'package:untitled2_ecom/features/personalization/screens/address/widget/address_form_view.dart';
import 'package:untitled2_ecom/features/personalization/screens/address/widget/single_address.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class UserAddressesScreen extends StatelessWidget {
  const UserAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(AddressController());

    return Scaffold(
      appBar: TAppbar(
        title: Text(
          "عناويني",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
        showBlur: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TColors.primary,
        onPressed: () => Get.to(() => const AddressFormWidget()),
        child: const Icon(Iconsax.add, color: TColors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Obx(() {
          // جلب الحالة من الكونترولر
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.addressList.isEmpty) {
            return const Center(child: Text("لا توجد عناوين مسجلة حالياً"));
          }

          return ListView.builder(
            itemCount: controller.addressList.length,
            itemBuilder: (context, index) {
              // نستخدم .value لضمان الحصول على أحدث حالة
              final address = controller.addressList[index];
              return SingleAddress(
                address: address,
                otTap: () => controller.selectAddress(address),
              );
            },
          );
        }),
      ),
    );
  }
}
