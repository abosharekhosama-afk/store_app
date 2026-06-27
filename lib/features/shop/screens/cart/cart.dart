import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/common/widgets/loaders/animation_loader.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/cart_controller.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/order_controller_new.dart';
import 'package:untitled2_ecom/features/shop/screens/cart/widget/item_cart.dart';
import 'package:untitled2_ecom/features/shop/screens/checkout/checkout.dart';
import 'package:untitled2_ecom/navigation_menu.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    final orderController = Get.put(OrderController());
    return Scaffold(
      appBar: TAppbar(
        showBackArrow: true,
        title: Text("السلة"),
        showBlur: true,
      ),
      bottomNavigationBar: controller.cartItems.isEmpty
          ? const SizedBox()
          : Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: ElevatedButton(
                onPressed: () => Get.to(() => Checkout()),
                child: Obx(
                  () => Text("الدفع \$${controller.totalCartPrice.value}"),
                ),
              ),
            ),

      body: Obx(() {
        final emptyWidget = TAnimationLoaderWidget(
          text: "عفواً! السلة فارغة.",
          animation: TImages.cartAnimation,
          showAction: true,
          actionText: "لنملؤها",
          onActionPressed: () => Get.off(() => NavigationMenu()),
        );

        return controller.cartItems.isEmpty
            ? emptyWidget
            : Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),

                child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: TSizes.spaceBtwSections),
                  itemCount: controller.cartItems.length,
                  itemBuilder: (context, index) {
                    final carItem = controller.cartItems[index];
                    var color = "";
                    var size = "";
                    (carItem.selectedVariation ?? {}).entries.map((e) {
                      color = e.key;
                      size = e.value;
                    });
                    final bool isClosed = orderController.isProductStoreClosed(
                      carItem.storeId,
                    );
                    return ItemCart(
                      imageUrl: carItem.image ?? "",
                      title: "",
                      //title: carItem.brandName ?? "",
                      subTitle: carItem.title,
                      color: color,
                      size: size,
                      quantity: carItem.quantity,
                      price: carItem.price,
                      add: () => controller.addOneToCart(carItem),
                      remove: () => controller.removeOneFromCart(carItem),
                      isClosed: isClosed,
                    );
                  },
                ),
              );
      }),
    );
  }
}
