import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:untitled2_ecom/common/widgets/contaniners/rounded_container.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class TReviewComment extends StatelessWidget {
  const TReviewComment({
    super.key,
    required this.userName,
    required this.userImage,
    this.onPressed,
    required this.dateReviw,
    required this.appName,
    required this.reviewText,
  });
  final String userName;
  final String userImage;
  final String dateReviw;
  final String appName;
  final String reviewText;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: AssetImage(userImage)),
                const SizedBox(width: TSizes.sm),
                Text(userName, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            IconButton(onPressed: onPressed, icon: Icon(Icons.more_vert)),
          ],
        ),
        SizedBox(height: TSizes.spaceBtwItems),
        Row(
          children: [
            // TCircularImage(image: userImage),
            Text(dateReviw, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        SizedBox(height: TSizes.spaceBtwItems / 2),

        TRoundedContainer(
          padding: EdgeInsets.all(TSizes.md),
          margin: EdgeInsets.only(bottom: TSizes.defaultSpace),
          backgroundColor: dark ? TColors.darkerGrey : TColors.grey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(appName, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    dateReviw,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              SizedBox(height: TSizes.spaceBtwItems),
              ReadMoreText(
                TTexts.confirmEmailSubTitle * 2,
                trimLines: 2,
                trimMode: TrimMode.Line,
                trimCollapsedText: "عرض المزيد",
                trimExpandedText: "Less",
                moreStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: TColors.accent,
                ),
                lessStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: TColors.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
