import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/images/rounded_image.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/device/device_utils.dart';

class ImagesController extends GetxController {
  static ImagesController get instance => Get.find();

  RxString selectedProductImage = "".obs;

  List<String> getAllProductImages(ProductModel product) {
    // final storage = TfirebaseStorageService.instance;
    Set<String> images = {};
    images.add(product.thumbnail);

    selectedProductImage.value = product.thumbnail;

    if (product.images != null) {
      images.addAll(product.images!);
    }

    if (product.productVariation != null ||
        product.productVariation!.isNotEmpty) {
      images.addAll(product.productVariation!.map((e) => e.image));
    }

    return images.toList();
  }

  void showEnlargeImage(String image, BuildContext context) {
    var height = TDeviceUtils.getScreenHeight();
    var width = TDeviceUtils.getScreenWidth(context);
    Get.to(
      fullscreenDialog: true,
      () => Dialog.fullscreen(
        child: Column(
          children: [
            TRoundedImage(
              imageUrl: image,
              height: height * 0.8,
              width: width,
              isNetworkImage: true,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: (width - 48),
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: Text("الغاء"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
