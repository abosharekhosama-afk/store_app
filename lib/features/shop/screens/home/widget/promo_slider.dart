import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:untitled2_ecom/common/widgets/custom_shapes/containers/cirular_container.dart';
import 'package:untitled2_ecom/common/widgets/images/rounded_image.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/shimmer.dart';
import 'package:untitled2_ecom/features/shop/controllers/banner_controller.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class TPromoSlider extends StatelessWidget {
  const TPromoSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BannerController());
    return Obx(() {
      if (controller.isLoading.value) {
        return const TShimmerEffect(width: double.infinity, height: 190);
      }
      if (controller.allbanner.isEmpty) {
        return const Center(child: Text("لم يتم العثور على بيانات!"));
      } else {
        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 1,
                onPageChanged: (index, reason) =>
                    controller.updatePageIndicator(index),
              ),

              items: controller.allbanner
                  .map(
                    (e) => TRoundedImage(
                      imageUrl: e.imageUrl,
                      fit: BoxFit.cover,
                      isNetworkImage:
                          e.imageUrl.startsWith('http://') ||
                          e.imageUrl.startsWith('https://'),
                      onPressed: () => Get.toNamed(e.targetScreen),
                      height: double.infinity,
                      width: double.infinity,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < controller.allbanner.length; i++)
                    TCircularContainer(
                      width: 20,
                      heigth: 4,
                      margin: EdgeInsets.only(right: 5),
                      backgroundColor:
                          controller.caroursalCurrentIndex.value == i
                          ? TColors.primary
                          : TColors.grey,
                    ),
                ],
              ),
            ),
          ],
        );
      }
    });
  }
}
