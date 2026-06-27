import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/cart_controller.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';

class TCartCountIcon extends StatelessWidget {
  const TCartCountIcon({
    super.key,
    required this.iconColor,
    required this.onPressed,
  });
  final Color iconColor;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    return Stack(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(Iconsax.shopping_bag),
          color: iconColor,
        ),
        Positioned(
          right: 0,
          child: Container(
            height: 18,
            width: 18,
            decoration: BoxDecoration(
              color: TColors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Obx(
                () => Text(
                  controller.noOfCartItem.value.toString(),
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.apply(color: TColors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
