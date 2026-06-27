import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/common/widgets/icons/circular_icon.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class TAddAndRemovedButtonForCountity extends StatelessWidget {
  const TAddAndRemovedButtonForCountity({
    super.key,
    required this.quantity,
    this.add,
    this.remove,
  });

  final int quantity;
  final VoidCallback? add, remove;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 70),
        TCircularIcon(
          width: 32,
          heigt: 32,
          size: TSizes.md,
          color: TColors.white,
          icon: Iconsax.add,
          backgroundColor: TColors.primary,
          onPressed: add,
        ),

        const SizedBox(width: TSizes.spaceBtwItems),
        Text(
          quantity.toString(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        TCircularIcon(
          width: 32,
          heigt: 32,
          size: TSizes.md,
          color: dark ? TColors.white : TColors.dark,
          icon: Iconsax.minus,
          backgroundColor: dark ? TColors.darkerGrey : TColors.lightContainer,
          onPressed: remove,
        ),
      ],
    );
  }
}
