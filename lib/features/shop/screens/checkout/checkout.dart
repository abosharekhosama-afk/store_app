import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/common/widgets/contaniners/rounded_container.dart';
import 'package:untitled2_ecom/features/personalization/models/address_model_new.dart';
import 'package:untitled2_ecom/features/shop/controllers/checkout_controller.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/cart_controller.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/order_controller_new.dart';
import 'package:untitled2_ecom/features/shop/models/cart_item_model.dart';
import 'package:untitled2_ecom/features/shop/screens/cart/widget/item_cart_hedar.dart';
import 'package:untitled2_ecom/features/shop/screens/checkout/widget/billing_address_section.dart';
import 'package:untitled2_ecom/features/shop/screens/checkout/widget/billing_amont_section.dart';
import 'package:untitled2_ecom/features/shop/screens/checkout/widget/billing_payment_section.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class Checkout extends StatelessWidget {
  const Checkout({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final cartController = CartController.instance;
    final orderController = Get.put(OrderController());
    final checkoutController = Get.put(CheckoutController());

    return Scaffold(
      appBar: TAppbar(
        title: Text(
          "مراجعة الطلب",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBlur: true,
      ),
      bottomNavigationBar: _buildBottomCheckoutBar(
        context,
        cartController,
        orderController,
      ),
      body: Obx(() {
        final storeAddresses = orderController.storeAddresses;
        final groupedItems = checkoutController.groupItemsByLocation(
          cartController.cartItems,
          storeAddresses,
        );

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. تنبيه ذكي بتصميم عصري
                if (groupedItems.length > 1)
                  _buildWarningBanner(
                    "تنبيه الشحن: سلتك تحتوي على متاجر من مناطق مختلفة، سيتم تجميعها لضمان وصولها بأمان.",
                  ),

                const SizedBox(height: TSizes.spaceBtwItems),

                // 2. قائمة المنتجات المجمعة داخل بطاقات أنيقة
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupedItems.length,
                  itemBuilder: (context, index) {
                    String location = groupedItems.keys.elementAt(index);
                    List<CartItemModel> items = groupedItems[location] ?? [];

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: TSizes.spaceBtwSections,
                      ),
                      decoration: BoxDecoration(
                        color: dark
                            ? TColors.darkerGrey
                            : TColors.lightContainer,
                        borderRadius: BorderRadius.circular(
                          TSizes.cardRadiusLg,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildLocationHeader(context, location, dark),
                          Padding(
                            padding: const EdgeInsets.all(TSizes.md),
                            child: Column(
                              children: items.map((item) {
                                final bool isClosed = orderController
                                    .isProductStoreClosed(item.storeId);
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: TSizes.spaceBtwItems,
                                  ),
                                  child: ItemCartHedar(
                                    imageUrl: item.image ?? "",
                                    subTitle: item.title,
                                    title: '',
                                    color: '',
                                    size: '',
                                    isClosed: isClosed,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          _buildLocationFooter(
                            location,
                            items,
                            storeAddresses,
                            dark,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: TSizes.spaceBtwItems),

                // 3. قسم الفاتورة والعنوان بتصميم Card
                TRoundedContainer(
                  showBorder: true,
                  padding: const EdgeInsets.all(TSizes.md),
                  backgroundColor: dark ? TColors.black : TColors.white,
                  child: Column(
                    children: [
                      const TBillingAmountSection(),
                      const Divider(),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      const TBillingAddressSection(),
                      const Divider(),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      if (!checkoutController.useWallet.value) ...const [
                        TBillingPaymentSection(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // رأس المجموعة بتصميم عصري (أيقونة الموقع + اسم المدينة)
  Widget _buildLocationHeader(
    BuildContext context,
    String location,
    bool dark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.md,
        vertical: TSizes.sm,
      ),
      decoration: BoxDecoration(
        color: TColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(TSizes.cardRadiusLg),
          topRight: Radius.circular(TSizes.cardRadiusLg),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded, color: TColors.primary, size: 18),
          const SizedBox(width: TSizes.sm),
          Text(
            "تجميع من حي: $location",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: TColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFooter(
    String location,
    List<CartItemModel> items,
    Map<String, AddressModelNew> storeAddresses,
    bool dark,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    final orderController = OrderController.instance;

    return Obx(() {
      // 1. نبحث داخل خريطة التفاصيل المحدثة ديناميكياً عن القيمة الخاصة بهذا الحي
      // نبحث عن مفتاح يحتوي على اسم الحي (مثلاً: "الرمال" أو "تجميع: الرمال")
      double areaFee = 0.0;

      for (var entry in orderController.shippingBreakdown.entries) {
        if (entry.key.contains(location.trim())) {
          areaFee = entry.value;
          break;
        }
      }

      // إذا كانت التكلفة صفر (مثلاً المندوب في نفس الشارع تماماً ولا يوجد بدل تجميع)، يمكنك كتابة "مجاني" أو إخفاء التذييل
      final String feeText = areaFee == 0.0 ? "مجاني" : "₪ $areaFee";

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md,
          vertical: TSizes.sm,
        ),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: dark ? TColors.darkGrey : TColors.grey.withOpacity(0.3),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "تكلفة شحن وتجميع المنطقة",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              feeText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: areaFee == 0.0
                    ? Colors.green
                    : (dark ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      );
    });
  }

  // شريط الدفع السفلي الثابت
  Widget _buildBottomCheckoutBar(
    BuildContext context,
    CartController cart,
    OrderController order,
  ) {
    final checkoutController = CheckoutController.instance;

    return Container(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      decoration: BoxDecoration(
        color: THelperFunctions.isDarkMode(context)
            ? TColors.dark
            : TColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Obx(() {
        final double totalAmount = order.finalTotalAmount;
        final double walletBalance = checkoutController.userWalletBalance.value;
        final bool isWalletChecked = checkoutController.useWallet.value;

        double walletDeduction = 0.0;
        double remainingBankAmount = totalAmount;

        // حساب التقسيم المالي التجريبي أمام العميل في الـ UI
        if (isWalletChecked && walletBalance > 0) {
          if (walletBalance >= totalAmount) {
            walletDeduction = totalAmount;
            remainingBankAmount = 0.0;
          } else {
            walletDeduction = walletBalance;
            remainingBankAmount = totalAmount - walletBalance;
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 💳 واجهة اختيار الدفع من المحفظة داخل الشريط
            CheckboxListTile(
              title: Text("الدفع باستخدام المحفظة (رصيدك: ₪ $walletBalance)"),
              value: isWalletChecked,
              activeColor: TColors.primary,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) =>
                  checkoutController.useWallet.value = value ?? false,
            ),

            // عرض تفصيلي للمبالغ المقسمة إذا كان الدفع هجين/مختلط
            if (isWalletChecked && walletDeduction > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "سيخصم من المحفظة:",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "₪ $walletDeduction",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "المتبقي للدفع البنكي:",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "₪ $remainingBankAmount",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: TColors.primary,
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],

            const SizedBox(height: TSizes.spaceBtwItems),

            // زر التثبيت النهائي للطلب
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
              ),
              onPressed: () => order.processOrder(totalAmount),
              child: Text(
                remainingBankAmount == 0
                    ? "تأكيد الطلب والدفع الكامل من المحفظة"
                    : "تأكيد الطلب بمبلغ ₪ $remainingBankAmount بنكياً",
              ),
            ),
          ],
        );
      }),
    );
  }

  /// دالة بناء التنبيه الذكي بتصميم عصري
  Widget _buildWarningBanner(String message) {
    return Container(
      width: double.infinity,
      // مسافة سفلية لفصل التنبيه عن قائمة المنتجات
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        // لون برتقالي شفاف ليعطي انطباع التحذير الهادئ
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة التنبيه
          const Icon(Icons.info_outline, color: Colors.orange, size: 20),
          const SizedBox(width: TSizes.spaceBtwItems),

          // نص التنبيه مع دعم السطور المتعددة
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                height: 1.4, // تباعد أسطر مريح للقراءة
              ),
            ),
          ),
        ],
      ),
    );
  }
}
