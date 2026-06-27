import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/shimmer.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class TCategoryShimmers extends StatelessWidget {
  const TCategoryShimmers({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: TSizes.defaultSpace),
      child: SizedBox(
        height: 88,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: itemCount,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, index) =>
              SizedBox(width: TSizes.spaceBtwItems),
          itemBuilder: (context, index) {
            return const Column(
              children: [
                TShimmerEffect(width: 55, height: 55, radius: 55),
                SizedBox(height: TSizes.spaceBtwItems / 2),
                TShimmerEffect(width: 55, height: 8),
              ],
            );
          },
        ),
      ),
    );
  }
}
