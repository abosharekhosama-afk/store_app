import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/cart_controller.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/order_controller_new.dart';

import 'package:get/get.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/helper_functions.dart';

class TBillingAmountSection extends StatelessWidget {
  const TBillingAmountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    final orderController = OrderController.instance;

    return Obx(() {
      double subTotal = cartController.totalCartPrice.value;
      double totalShipping = orderController.totalShippingCost.value;
      double total = orderController.finalTotalAmount;

      // جلب خريطة تفاصيل التجميع الفرعية من الـ Controller
      // تأكد من تعريف هذه الـ Map في OrderController ونقل البيانات إليها بعد عملية الحساب
      final Map<String, double> shippingBreakdown =
          orderController.shippingBreakdown;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. المجموع الجزئي للمنتجات
          _row("المجموع الجزئي", "₪ $subTotal"),
          const SizedBox(height: TSizes.spaceBtwItems / 2),

          // 2. إجمالي رسوم الشحن والتجميع
          _row(
            "إجمالي رسوم الشحن والتجميع",
            "₪ $totalShipping",
            valueColor: Colors.green,
          ),

          // 🌟 قائمة تفصيلية منسدلة خفيفة لعرض رسوم تجميع الشوارع/الأحياء
          if (shippingBreakdown.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(top: TSizes.sm, bottom: TSizes.sm),
              padding: const EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                color: THelperFunctions.isDarkMode(context)
                    ? TColors.darkerGrey.withOpacity(0.5)
                    : TColors.grey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              ),
              child: Column(
                children: shippingBreakdown.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "• ${entry.key}",
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(color: Colors.grey[600]),
                        ),
                        Text(
                          "₪ ${entry.value}",
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const Divider(),
          const SizedBox(height: TSizes.spaceBtwItems / 2),

          // 3. الإجمالي النهائي للطلب
          _row(
            "الإجمالي النهائي",
            "₪ $total",
            isBold: true,
            isTitleLarge: true,
          ),
        ],
      );
    });
  }

  // دالة بناء الأسطر المحدثة لتدعم مرونة التصميم الجديدة
  Widget _row(
    String title,
    String value, {
    bool isBold = false,
    Color? valueColor,
    bool isTitleLarge = false,
  }) {
    return Builder(
      builder: (context) {
        final defaultStyle = TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: isTitleLarge ? 16 : 14,
          color: isTitleLarge && !THelperFunctions.isDarkMode(context)
              ? TColors.primary
              : null,
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: defaultStyle),
            Text(
              value,
              style: defaultStyle.copyWith(
                color: valueColor ?? defaultStyle.color,
              ),
            ),
          ],
        );
      },
    );
  }
}









/*
class TBillingAmountSection extends StatelessWidget {
  const TBillingAmountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    final addressController = AddressController.instance;
    final orderController = OrderController.instance;

    // الحساب النهائي لرسوم الشحن (تجميع + توصيل للزبون)
    /*double totalShipping = ShippingCalculatorService.calculateTotalShipping(
      items: cartController.cartItems,
      userAddress: addressController.selctedAddress.value,
      storeAddresses: OrderController.instance.storeAddresses,
      addressDataMap: addressController.palestineAddressData,
    );*/

    return Obx(() {
      double subTotal = cartController.totalCartPrice.value;
      double totalShipping = orderController.totalShippingCost.value;
      double total = orderController.finalTotalAmount;
      return Column(
        children: [
          _row("المجموع الجزئي", "₪ $subTotal"),
          _row("إجمالي رسوم الشحن والتجميع", "₪ $totalShipping"),
          const Divider(),
          _row("الإجمالي النهائي", "₪ $total", isBold: true),
        ],
      );
    });
  }

  Widget _row(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
*/

/*
class TBillingAmountSection extends StatelessWidget {
  const TBillingAmountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    final subTotal = cartController.totalCartPrice.value;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "المجموع الجزئي",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text("\$$subTotal", style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("رسوم الشحن", style: Theme.of(context).textTheme.bodyMedium),
            Text(
              "\$${TPricingCalculator.calculateShippingCost(subTotal, "us")}",
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "الإجمالي النهائي",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "\$${TPricingCalculator.calculateTotalPrice(subTotal, "us")}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 2),
      ],
    );
  }
}
*/