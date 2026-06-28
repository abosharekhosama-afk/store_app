import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/images/rounded_image.dart';
import 'package:untitled2_ecom/common/widgets/texts/t_products_titleText.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class ItemCartHedar extends StatelessWidget {
  const ItemCartHedar({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subTitle,
    required this.color,
    required this.size,
    required this.isClosed,
  });

  final String imageUrl;
  final String title;
  final String subTitle;
  final String color;
  final String size;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);

    return Row(
      children: [
        TRoundedImage(
          isNetworkImage: true,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          imageUrl: imageUrl,
          backgroundColor: dark ? TColors.darkerGrey : TColors.lightContainer,
        ),
        const SizedBox(width: TSizes.spaceBtwItems),

        // الـ Expanded هنا ممتازة وصحيحة لحساب المساحة الأفقية المتبقية في الـ Row
        Expanded(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👈 تم حذف Flexible من هنا لأنها تسبب الخطأ داخل الـ Column المعلق
                  TproductText(title: subTitle, maxLine: 1),
                ],
              ),
            ],
          ),
        ),

        if (isClosed) ...[
          const SizedBox(
            width: TSizes.spaceBtwItems / 2,
          ), // مسافة صغيرة قبل شارة الإغلاق
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TSizes.sm,
              vertical: TSizes.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: const Text(
              "متجر مغلق",
              style: TextStyle(
                fontSize: 10,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
