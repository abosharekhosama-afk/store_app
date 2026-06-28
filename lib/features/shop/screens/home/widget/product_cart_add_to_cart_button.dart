import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/cart_controller.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/features/shop/screens/product_details/product_details.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class ProductCartAddToCartButton extends StatelessWidget {
  const ProductCartAddToCartButton({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    final dark = THelperFunctions.isDarkMode(context);

    return InkWell(
      onTap: () {
        if (product.isSingleProduct) {
          final cartItem = controller.convertToCartItem(product, 1);
          controller.addOneToCart(cartItem);
        } else {
          Get.to(() => ProductDetails(product: product));
        }
      },
      child: Obx(() {
        final productQuantityInCart = controller.getProductQuantityInCart(
          product.id,
        );
        return Container(
          decoration: BoxDecoration(
            // استخدام الأسود الفحمي ليكون هو نقطة التركيز (Call to Action)
            color: dark ? TColors.secondary : TColors.primary,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(TSizes.cardRadiusMd),
              bottomLeft: Radius.circular(TSizes.productImageRadius),
            ),
          ),
          child: SizedBox(
            width: TSizes.iconLg * 1.2,
            height: TSizes.iconLg * 1.2,
            child: Center(
              child: productQuantityInCart > 0
                  ? Text(
                      productQuantityInCart.toString(),
                      style: Theme.of(context).textTheme.bodyLarge!.apply(
                        color: dark ? TColors.primary : TColors.white,
                      ),
                    )
                  : Icon(
                      Iconsax.add,
                      color: dark ? TColors.primary : TColors.white,
                    ),
            ),
          ),
        );
      }),
    );
  }
}
