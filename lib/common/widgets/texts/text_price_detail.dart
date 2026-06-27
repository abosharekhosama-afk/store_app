import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/texts/text_price.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class TTextPriceDetail extends StatelessWidget {
  const TTextPriceDetail({
    super.key,
    required this.labele,
    required this.oldPrice,
    required this.newPrice,
  });

  final String labele, oldPrice, newPrice;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("$labele: ", style: Theme.of(context).textTheme.labelLarge),

        Text(
          oldPrice,
          style: Theme.of(
            context,
          ).textTheme.titleSmall!.apply(decoration: TextDecoration.lineThrough),
        ),
        const SizedBox(width: TSizes.spaceBtwItems / 2),
        TTextPrice(price: newPrice),
      ],
    );
  }
}
