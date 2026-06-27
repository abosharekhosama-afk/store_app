import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/common/widgets/icons/circular_icon.dart';
import 'package:untitled2_ecom/common/widgets/layouts/grid_layout.dart';
import 'package:untitled2_ecom/common/widgets/loaders/animation_loader.dart';
import 'package:untitled2_ecom/common/widgets/productes/produt_card_vertical.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/vertical_product_shimmer.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/favourites_controller.dart';
import 'package:untitled2_ecom/navigation_menu.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/utils/device/device_utils.dart';

class Wishlist extends StatelessWidget {
  const Wishlist({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FavouritesController.instance;

    return Scaffold(
      appBar: TAppbar(
        showBackArrow: false,
        title: Text(
          TTexts.wishlist,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          TCircularIcon(
            icon: Iconsax.add,
            onPressed: () =>
                NavigationController.instance.selectedIndex.value = 0,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              Obx(
                () {
                  if (controller.isLoading.value) {
                    return const VerticalProductShimmer(itemCount: 6);
                  }

                  // 2. حالة عدم وجود بيانات (Empty State)
                  if (controller.favoriteProductsList.isEmpty) {
                    return TAnimationLoaderWidget(
                      text: "اوه! قائمة المفضلات فارغة...",
                      animation: TImages.pencilAnimation,
                      showAction: true,
                      actionText: "دعنا نضيف بعض المنتجات",
                      onActionPressed: () {
                        if (Get.isRegistered<NavigationController>()) {
                          NavigationController.instance.selectedIndex.value = 0;
                        } else {
                          Get.offAll(() => const NavigationMenu());
                        }
                      },
                    );
                  }

                  // 3. حالة ظهور البيانات بنجاح (Data State)
                  return TGridLayout(
                    itemCount: controller.favoriteProductsList.length,
                    itemBuilder: (context, index) => ProdutCardVertical(
                      product: controller.favoriteProductsList[index],
                    ),
                  );
                },
                /*  () => FutureBuilder(
                  future: controller.favoritesProducts(),
                  builder: (context, asyncSnapshot) {
                    const loader = VerticalProductShimmer(itemCount: 6);
                    final emptyWidget = return TAnimationLoaderWidget(
                      text: "اوه! قائمة المفضلات فارغة...",
                      animation: TImages.pencilAnimation,
                      showAction: true,
                      actionText: "دعنا نضيف بعض المنتجات",
                      onActionPressed: () {
                        if (Get.isRegistered<NavigationController>()) {
                          NavigationController.instance.selectedIndex.value = 0;
                        } else {
                          Get.offAll(() => const NavigationMenu());
                        }
                      },
                    );
                    final widgt = TCloudHelperFunctions.checkMultiRecordState(
                      snapshot: asyncSnapshot,
                      loader: loader,
                      nothingFound: emptyWidget,
                    );
                    if (widgt != null) return widgt;

                    final products = asyncSnapshot.data!;
                    return TGridLayout(
                      itemCount: products.length,
                      itemBuilder: (p0, p1) =>
                          ProdutCardVertical(product: products[p1]),
                    );
                  },
                ),*/
              ),
              SizedBox(
                height:
                    TDeviceUtils.getBottomNavigationBarHeight() +
                    TSizes.spaceBtwSections * 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
