import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/shimmer.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class HorizantalProductShimmer extends StatelessWidget {
  const HorizantalProductShimmer({super.key, this.itemCount = 4});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: TSizes.spaceBtwSections),
      height: 129,
      child: ListView.separated(
        itemCount: itemCount,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) =>
            SizedBox(width: TSizes.spaceBtwItems),
        itemBuilder: (context, index) => Row(
          children: [
            TShimmerEffect(width: 120, height: 120),
            SizedBox(width: TSizes.spaceBtwItems),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: TSizes.spaceBtwItems / 2),
                TShimmerEffect(width: 160, height: 15),
                SizedBox(height: TSizes.spaceBtwItems / 2),
                TShimmerEffect(width: 110, height: 15),
                SizedBox(height: TSizes.spaceBtwItems / 2),
                TShimmerEffect(width: 80, height: 15),
                Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
