import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/contaniners/rounded_container.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/shimmer.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/helper_functions.dart';

class TOrderShimmer extends StatelessWidget {
  const TOrderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);

    return ListView.separated(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // لمنع تعارض التمرير مع الأب
      itemCount: 4, // عرض 4 بطاقات وهمية
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (_, __) => TRoundedContainer(
        width: double.infinity,
        showBorder: false,
        padding: const EdgeInsets.all(TSizes.md),
        backgroundColor: dark ? TColors.darkerGrey : TColors.white,
        child: Column(
          children: [
            /// 1. الرأس (الحالة والتاريخ والسهم)
            Row(
              children: [
                // الدائرة الوهمية للأيقونة (radius = 50 لجعله دائرياً بالكامل)
                const TShimmerEffect(width: 36, height: 36, radius: 50),
                const SizedBox(width: TSizes.spaceBtwItems),

                // نصوص الحالة والتاريخ الوهمية
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TShimmerEffect(width: 110, height: 14, radius: 4),
                      const SizedBox(height: 6),
                      const TShimmerEffect(width: 75, height: 10, radius: 4),
                    ],
                  ),
                ),

                // سهم الانتقال الجانبي الوهمي
                const TShimmerEffect(width: 18, height: 18, radius: 4),
              ],
            ),

            const SizedBox(height: TSizes.spaceBtwItems),
            const Divider(),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// 2. المعرف وكود التسليم الوهمي
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TShimmerEffect(width: 60, height: 10, radius: 3),
                      const SizedBox(height: 6),
                      const TShimmerEffect(width: 90, height: 12, radius: 4),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TShimmerEffect(width: 60, height: 10, radius: 3),
                      const SizedBox(height: 6),
                      const TShimmerEffect(width: 90, height: 12, radius: 4),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            /// 3. شريط صور المنتجات وإجمالي المبلغ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // عرض 3 مربعات تمثل صور المنتجات المتراصة (radius = 8 مطابق للواجهة)
                SizedBox(
                  height: 45,
                  child: Row(
                    children: const [
                      TShimmerEffect(width: 45, height: 45, radius: 8),
                      SizedBox(width: 8),
                      TShimmerEffect(width: 45, height: 45, radius: 8),
                      SizedBox(width: 8),
                      TShimmerEffect(width: 45, height: 45, radius: 8),
                    ],
                  ),
                ),

                // السعر الإجمالي في الجهة المقابلة
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const TShimmerEffect(width: 65, height: 10, radius: 3),
                    const SizedBox(height: 6),
                    const TShimmerEffect(width: 50, height: 16, radius: 4),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
