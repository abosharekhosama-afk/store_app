import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/images/circular_image.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/helper_functions.dart';

class TCategrieWidget extends StatelessWidget {
  const TCategrieWidget({
    super.key,
    required this.icon,
    required this.leabel,
    this.OnTap,
  });

  final String icon;
  final String leabel;
  final VoidCallback? OnTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: OnTap,
      child: Padding(
        padding: const EdgeInsets.only(right: TSizes.spaceBtwItems),
        child: Column(
          children: [
            Container(
              //padding: EdgeInsets.all(8),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: dark ? TColors.dark : TColors.white,
              ),
              child: Center(
                child: TCircularImage(
                  padding: 0.0,
                  margin: 6,
                  image: icon,
                  isNetworkImage: true,
                  fit: BoxFit.cover,
                  backgroundColor: dark ? TColors.black : TColors.white,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              leabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium!.apply(
                color: dark ? TColors.dark : TColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
