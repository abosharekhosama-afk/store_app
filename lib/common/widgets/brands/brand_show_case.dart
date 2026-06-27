import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/brands/brand_card.dart';
import 'package:untitled2_ecom/common/widgets/contaniners/rounded_container.dart';
import 'package:untitled2_ecom/features/shop/models/brand_model.dart';
import 'package:untitled2_ecom/features/shop/screens/brands/brand_products.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/helper_functions.dart';

class TBrandShowcase extends StatelessWidget {
  const TBrandShowcase({super.key, required this.images, required this.brand});
  final List<String> images;
  final BrandModel brand;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => BrandProducts(brand: brand)),
      child: TRoundedContainer(
        showBorder: true,
        borderColor: TColors.darkGrey,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.only(bottom: TSizes.spaceBtwItems),
        padding: EdgeInsets.all(TSizes.md),
        child: Column(
          children: [
            TBrandCard(showBorder: false, brand: brand),
            Row(
              children: images
                  .map((e) => TBrandTopProductImageWidget(image: e))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class TBrandTopProductImageWidget extends StatelessWidget {
  const TBrandTopProductImageWidget({super.key, required this.image});
  final String image;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    return Expanded(
      child: TRoundedContainer(
        heigth: 100,
        margin: EdgeInsets.only(right: TSizes.sm),
        padding: EdgeInsets.all(TSizes.md),
        backgroundColor: dark ? TColors.darkerGrey : TColors.white,
        child: Image(fit: BoxFit.contain, image: AssetImage(image)),
      ),
    );
  }
}
