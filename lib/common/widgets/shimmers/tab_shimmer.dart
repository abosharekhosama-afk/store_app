import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/shimmer.dart'; // مسار ملف الـ TShimmerEffect الخاص بك
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class TTabShimmer extends StatelessWidget {
  const TTabShimmer({
    super.key,
    this.itemCount = 4, // عدد العناصر الوهمية التي ستظهر
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50, // نفس ارتفاع الحاوية في التصميم الأساسي
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
        itemCount: itemCount,
        separatorBuilder: (_, __) =>
            const SizedBox(width: TSizes.spaceBtwItems),
        itemBuilder: (_, __) => const TShimmerEffect(
          width: 100, // عرض تقريبي للتبويب
          height: 35, // ارتفاع قريب من حجم الـ ChoiceChip
          radius: 20, // زيادة الانحناء ليطابق شكل الـ Chip
        ),
      ),
    );
  }
}
