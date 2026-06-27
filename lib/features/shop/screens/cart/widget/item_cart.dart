import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/productes_cart/add_and_removed_button_for_qountity.dart';
import 'package:untitled2_ecom/common/widgets/texts/text_price.dart';
import 'package:untitled2_ecom/features/shop/screens/cart/widget/item_cart_hedar.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class ItemCart extends StatelessWidget {
  const ItemCart({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subTitle,
    required this.color,
    required this.size,
    required this.quantity,
    this.add,
    this.remove,
    required this.price,
    required this.isClosed,
  });
  final String imageUrl, title, subTitle, color, size;
  final int quantity;
  final VoidCallback? add, remove;
  final double price;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    //final bool dark = THelperFunctions.isDarkMode(context);
    //final controller = CartController.instance;

    return Column(
      children: [
        ItemCartHedar(
          imageUrl: imageUrl,
          title: title,
          subTitle: subTitle,
          color: color,
          size: size,
          isClosed: isClosed,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TAddAndRemovedButtonForCountity(
              quantity: quantity,
              add: add,
              remove: remove,
            ),
            TTextPrice(price: (price * quantity).toStringAsFixed(1)),
          ],
        ),
      ],
    );
  }
}
