import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/common/widgets/brands/brand_card.dart';
import 'package:untitled2_ecom/common/widgets/productes_cart/sort_products.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/vertical_product_shimmer.dart';
import 'package:untitled2_ecom/features/shop/controllers/brand_controller.dart';
import 'package:untitled2_ecom/features/shop/models/brand_model.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/cloud_helper_functions.dart';

class BrandProducts extends StatelessWidget {
  const BrandProducts({super.key, required this.brand});
  final BrandModel brand;

  @override
  Widget build(BuildContext context) {
    final controller = BrandController.instance;
    return Scaffold(
      appBar: TAppbar(title: Text(brand.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              TBrandCard(showBorder: true, brand: brand),
              const SizedBox(height: TSizes.spaceBtwSections),
              FutureBuilder(
                future: controller.getBrandProducts(brandId: brand.id),
                builder: (context, asyncSnapshot) {
                  const loader = VerticalProductShimmer();

                  final widget = TCloudHelperFunctions.checkMultiRecordState(
                    snapshot: asyncSnapshot,
                    loader: loader,
                  );
                  if (widget != null) return widget;

                  final brandProducts = asyncSnapshot.data!;
                  return TSortProducts();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
