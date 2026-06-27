import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/layouts/grid_layout.dart';
import 'package:untitled2_ecom/common/widgets/productes/produt_card_vertical.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/vertical_product_shimmer.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/features/shop/controllers/category_controller.dart';
import 'package:untitled2_ecom/features/shop/models/category_model.dart';
import 'package:untitled2_ecom/features/shop/screens/all_products/all_products.dart';
import 'package:untitled2_ecom/features/shop/screens/store/widget/category_brands.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/utils/helpers/cloud_helper_functions.dart';

class TCategoryTab extends StatelessWidget {
  const TCategoryTab({super.key, required this.category});
  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              CategoryBrands(category: category),
              sectionHeading(
                labelText: TTexts.youMightLike,
                showButtton: true,
                onPressed: () => Get.to(
                  AllProducts(
                    title: category.name,
                    futureMethod: controller.getCategoryProducts(
                      categoryId: category.id,
                      limit: -1,
                    ),
                  ),
                ),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              FutureBuilder(
                future: controller.getCategoryProducts(categoryId: category.id),
                builder: (context, asyncSnapshot) {
                  final widget = TCloudHelperFunctions.checkMultiRecordState(
                    snapshot: asyncSnapshot,
                    loader: VerticalProductShimmer(),
                  );
                  if (widget != null) return widget;

                  final products = asyncSnapshot.data!;

                  return TGridLayout(
                    itemCount: products.length,
                    itemBuilder: (p0, p1) =>
                        ProdutCardVertical(product: products[p1]),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
