import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/common/widgets/brands/brand_card.dart';
import 'package:untitled2_ecom/common/widgets/layouts/grid_layout.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/brand_shimmer.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/features/shop/controllers/brand_controller.dart';
import 'package:untitled2_ecom/features/shop/screens/brands/brand_products.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class Brands extends StatelessWidget {
  const Brands({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = BrandController.instance;
    return Scaffold(
      appBar: TAppbar(title: Text("الماركات"), showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              sectionHeading(
                labelText: "الماركات",
                showButtton: false,
                padding: EdgeInsets.all(0),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Obx(() {
                if (controller.isLoding.value) {
                  return TBrandShimmer();
                }

                if (controller.allBrands.isEmpty) {
                  return Center(
                    child: Text(
                      "لم يتم العثور على بيانات!",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.apply(color: Colors.white),
                    ),
                  );
                }
                return TGridLayout(
                  itemCount: controller.allBrands.length,
                  mainAxisExtent: 88,
                  itemBuilder: (p0, p1) {
                    final brand = controller.allBrands[p1];
                    return TBrandCard(
                      showBorder: true,
                      brand: brand,
                      onTap: () => Get.to(() => BrandProducts(brand: brand)),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
