import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/features/shop/screens/product_reviews_unused/widget/overallproduct_rating.dart';
import 'package:untitled2_ecom/features/shop/screens/product_reviews_unused/widget/review_comment.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';

class ProductReviews extends StatelessWidget {
  const ProductReviews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppbar(
        title: Text(TTexts.reviewsAndRatings),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(TTexts.changeYourPasswordSubTitle * 2),
              SizedBox(height: TSizes.spaceBtwItems),
              TOverallProductRating(),
              /*RatingBarIndicator(rating:3.5,
              itenmSize:20,unratedColor:context
              itemBuilder:(_,__)=? Icon
              )*/
              Text("12,612", style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: TSizes.spaceBtwItems),
              TReviewComment(
                userName: "osama",
                userImage: TImages.user,
                dateReviw: "2-nov-2026",
                appName: "shoping",
                reviewText: TTexts.tEmailVerificationSubTitle,
              ),
              TReviewComment(
                userName: "osama",
                userImage: TImages.user,
                dateReviw: "2-nov-2026",
                appName: "shoping",
                reviewText: TTexts.tEmailVerificationSubTitle,
              ),
              TReviewComment(
                userName: "osama",
                userImage: TImages.user,
                dateReviw: "2-nov-2026",
                appName: "shoping",
                reviewText: TTexts.tEmailVerificationSubTitle,
              ),
              TReviewComment(
                userName: "osama",
                userImage: TImages.user,
                dateReviw: "2-nov-2026",
                appName: "shoping",
                reviewText: TTexts.tEmailVerificationSubTitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
