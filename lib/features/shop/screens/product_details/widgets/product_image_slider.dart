import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart'; // تأكد من استيراد هذه المكتبة
import 'package:untitled2_ecom/common/widgets/images/rounded_image.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/shimmer.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/images_controller.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class TProductImageSlider extends StatelessWidget {
  const TProductImageSlider({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(ImagesController());
    final images = controller.getAllProductImages(product);

    return Container(
      color: dark ? TColors.darkerGrey : TColors.lightContainer,
      child: Stack(
        children: [
          // الصورة الرئيسية
          SizedBox(
            height: 480,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Center(
                child: Obx(() {
                  final image = controller.selectedProductImage.value;

                  return GestureDetector(
                    onTap: () => controller.showEnlargeImage(image, context),
                    child: CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      filterQuality: FilterQuality.high,
                      fadeInCurve: Curves.easeIn,
                      fadeInDuration: const Duration(milliseconds: 300),
                      fadeOutDuration: const Duration(milliseconds: 300),

                      // Shimmer effect راقي أثناء التحميل
                      placeholder: (context, url) {
                        return TShimmerEffect(
                          width: double.infinity,
                          height: 480,
                          //radius: TSizes.productImageRadius,
                          color: dark
                              ? TColors.darkerGrey
                              : TColors.lightContainer,
                        );
                      },

                      // عرض صورة الخطأ عند فشل التحميل
                      errorWidget: (context, url, error) => Container(
                        color: dark
                            ? TColors.darkerGrey
                            : TColors.lightContainer,
                        child: const Center(
                          child: Icon(
                            Icons.error,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      // إعدادات الكاش للعمل بدون إنترنت
                      cacheKey: image.replaceAll(RegExp(r'[^\w\-]'), '_'),
                      maxHeightDiskCache: 800,
                      maxWidthDiskCache: 800,
                      useOldImageOnUrlChange: true,
                    ),
                  );
                }),
              ),
            ),
          ),

          // شريط الصور المصغرة (Thumbnails)
          Positioned(
            bottom: 30,
            left: 0,
            right: TSizes.defaultSpace,
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) => Obx(() {
                  final imageSelected =
                      controller.selectedProductImage.value == images[index];
                  return TRoundedImage(
                    fit: BoxFit.cover,
                    imageUrl: images[index],
                    isNetworkImage: true, // تأكدنا هنا أنها صورة من الإنترنت
                    width: 80,
                    backgroundColor: dark ? TColors.dark : TColors.white,
                    border: Border.all(
                      color: imageSelected
                          ? TColors.primary
                          : Colors.transparent,
                    ),
                    onPressed: () =>
                        controller.selectedProductImage.value = images[index],
                    padding: EdgeInsets.zero,
                  );
                }),
                separatorBuilder: (context, index) =>
                    const SizedBox(width: TSizes.spaceBtwItems),
                itemCount: images.length,
              ),
            ),
          ),

          // شريط العنوان العلوي (أيقونة المفضلة والرجوع)
          /*TAppbar(
            showBackArrow: true,
            actions: [FavouriteIcon(productId: product.id)],
          ),*/
        ],
      ),
    );
  }
}














/*
class TProductImageSlider extends StatelessWidget {
  const TProductImageSlider({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(ImagesController());
    final images = controller.getAllProductImages(product);

    return TCuvedEdgeWidget(
      child: Container(
        color: dark ? TColors.darkerGrey : TColors.lightContainer,
        child: Stack(
          children: [
            SizedBox(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.all(TSizes.productImageRadius * 2),
                child: Center(
                  child: Obx(() {
                    final image = controller.selectedProductImage.value;
                    /*if (image.isNotEmpty) {
                      return GestureDetector(
                        onTap: () => controller.showEnlargeImage(image),
                        child: Image(image: AssetImage(image)),
                      );
                    }*/
                    /*return GestureDetector(
                      onTap: () => controller.showEnlargeImage(image),
                      child: Image(image: AssetImage(image)),
                    );*/
                     return CachedNetworkImage(
                      imageUrl: image,
                      progressIndicatorBuilder: (_, __, don) =>
                          CircularProgressIndicator(
                            value: don.progress,
                            color: TColors.primary,
                          ),
                    );
                  }),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              right: 0,
              left: TSizes.defaultSpace,
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) => Obx(() {
                    final imageSelected =
                        controller.selectedProductImage.value == images[index];
                    return TRoundedImage(
                      imageUrl: images[index],
                      isNetworkImage: true,
                      width: 80,
                      backgroundColor: dark ? TColors.dark : TColors.white,
                      border: Border.all(
                        color: imageSelected
                            ? TColors.primary
                            : Colors.transparent,
                      ),
                      onPressed: () =>
                          controller.selectedProductImage.value = images[index],
                      padding: EdgeInsets.zero,
                    );
                  }),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: TSizes.spaceBtwItems),
                  itemCount: images.length,
                ),
              ),
            ),

            TAppbar(
              showBackArrow: true,
              actions: [FavouriteIcon(productId: product.id)],
            ),
          ],
        ),
      ),
    );
  }
}
*/