import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/shimmer.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class TSimilarProductShimmer extends StatelessWidget {
  const TSimilarProductShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 285, // نفس ارتفاع قائمة المنتجات المشابهة
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: itemCount,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) =>
            const SizedBox(width: TSizes.spaceBtwItems),
        itemBuilder: (_, __) => const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// الصورة
            TShimmerEffect(width: 160, height: 160),
            SizedBox(height: TSizes.spaceBtwItems),

            /// العنوان
            TShimmerEffect(width: 110, height: 15),
            SizedBox(height: TSizes.spaceBtwItems / 2),

            /// الماركة
            TShimmerEffect(width: 80, height: 12),
            SizedBox(height: TSizes.spaceBtwItems / 2),

            /// السعر
            Row(
              children: [
                TShimmerEffect(width: 50, height: 15),
                SizedBox(width: 70), // مساحة للزر
              ],
            ),
          ],
        ),
      ),
    );
  }
}
