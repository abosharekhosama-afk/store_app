import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/contaniners/rounded_container.dart';
import 'package:untitled2_ecom/common/widgets/texts/t_products_titleText.dart';
import 'package:untitled2_ecom/common/widgets/texts/text_price.dart';
import 'package:untitled2_ecom/common/widgets/texts/text_product_detail.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/product_controller.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class TProductmetadata extends StatelessWidget {
  const TProductmetadata({super.key, required this.product});
  final ProductModel product;
  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = ProductController.instance;
    final salePercentage = controller.calculateSalePercentage(
      product.price,
      product.salePrice,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (product.isSingleProduct && product.salePrice > 0)
              Text(
                "\$${product.price}",
                style: Theme.of(context).textTheme.titleSmall!.apply(
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            const SizedBox(width: TSizes.spaceBtwItems / 1.5),
            TTextPrice(
              price: controller.getProductPrice(product),
              isLarge: false,
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            if (salePercentage != null) ...[
              TRoundedContainer(
                radius: TSizes.sm,
                backgroundColor: TColors.primary.withOpacity(0.8),
                padding: EdgeInsets.symmetric(
                  horizontal: TSizes.sm,
                  vertical: TSizes.xs,
                ),
                child: Text(
                  "$salePercentage%",
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.apply(color: TColors.black),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        TproductText(title: product.title),
        const SizedBox(width: TSizes.spaceBtwItems / 1.5),
        TTextProductDetail(
          title: "الحالة",
          subTitle: controller.getProductStockStatus(product.stock),
        ),
        const SizedBox(width: TSizes.spaceBtwItems / 1.5),
        /* Row(
          children: [
            TCircularImage(
              image: product.brande != null ? product.brande!.image : "",
              //isNetworkImage: true,
              width: 32,
              height: 32,
              overlayColor: dark ? TColors.white : TColors.black,
            ),
            TBrandTitleWithVerifiedIcon(
              title: product.brande != null ? product.brande!.name : "",
              brandTextSize: TextSizes.medium,
            ),
          ],
        ),*/
      ],
    );
  }
}
