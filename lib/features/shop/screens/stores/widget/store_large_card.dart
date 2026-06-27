import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/common/widgets/images/rounded_image.dart';
import 'package:untitled2_ecom/features/personalization/models/user_stor_model.dart';
import 'package:untitled2_ecom/features/shop/screens/stores/widget/store_details_screen.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class TStoreCard extends StatelessWidget {
  final StoreModel store;
  const TStoreCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: () => Get.to(() => StoreDetailsScreen(), arguments: store),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TSizes.sm),
        margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          color: isDark ? TColors.darkerGrey : TColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. لوجو المتجر
            TRoundedImage(
              width: 80,
              height: 80,
              imageUrl: store.storeLogo,
              fit: BoxFit.cover,
              isNetworkImage: true,
            ),

            const SizedBox(width: TSizes.spaceBtwItems),

            // 2. تفاصيل المتجر
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        store.storName,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (store.isVerified) ...[
                        const SizedBox(width: 5),
                        const Icon(
                          Iconsax.verify5,
                          color: TColors.primary,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // وصف المتجر
                  Text(
                    store.storeDescription,
                    style: Theme.of(context).textTheme.labelMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // العنوان التفصيلي (أيقونة + نص)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: TColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          store.addressModel.fullAddress,
                          style: Theme.of(context).textTheme.labelSmall!.apply(
                            color: TColors.darkGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // زر الانتقال
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: TColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}




/*
class StoreLargeCard extends StatelessWidget {
  final StoreModel store;
  const StoreLargeCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => StoreDetailsScreen(store: store)),
      child: Container(
        margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            // صورة الغلاف
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                store.storeBanner,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(store.storeLogo),
              ),
              title: Text(
                store.storName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${store.city} - ${store.neighborhood}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
*/