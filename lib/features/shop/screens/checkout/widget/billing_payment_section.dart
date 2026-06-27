import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/contaniners/rounded_container.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/features/shop/controllers/checkout_controller.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/order_controller_new.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class TBillingPaymentSection extends StatelessWidget {
  const TBillingPaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(CheckoutController());

    // 1. جلب القيم الحالية من الـ Controllers لتبسيط قراءة الشرط
    final paymentMethod = controller.selectedPaymentMethod.value.name;
    final walletBalance = controller.userWalletBalance.value;
    final totalAmount = OrderController.instance.finalTotalAmount;
    // 2. صياغة الشرط بدقة:
    // يظهر الحقل إذا كان الرصيد لا يغطي (والمستخدم اختار PayPal أو اختار المحفظة وهي غير كافية)
    final bool isWalletInsufficient = walletBalance < totalAmount;
    final bool isPayPalSelected = paymentMethod == "PayPal";
    final bool isWalletSelected =
        paymentMethod == "Wallet" ||
        paymentMethod == "المحفظة"; // حسب التسمية لديك

    final bool shouldShowNameField =
        isWalletInsufficient && (isPayPalSelected || isWalletSelected);
    return Column(
      children: [
        sectionHeading(
          labelText: "Payment Method",
          showButtton: true,
          labelButton: "Change",
          onPressed: () => controller.selectPaymentMethod(context),
          padding: EdgeInsets.all(0),
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 2),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TRoundedContainer(
                    width: 60,
                    heigth: 35,
                    backgroundColor: dark ? TColors.light : TColors.white,
                    padding: const EdgeInsets.all(TSizes.sm),
                    child: Image(
                      image: AssetImage(
                        controller.selectedPaymentMethod.value.image,
                      ),
                      //fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems / 2),
                  Text(
                    controller.selectedPaymentMethod.value.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),

              // الشرط: إذا كانت وسيلة الدفع هي PayPal (أو المحفظة) اظهر حقل الاسم
              if (shouldShowNameField)
                Padding(
                  padding: const EdgeInsets.only(top: TSizes.spaceBtwItems),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "تحقق من الاسم الرباعي للتحويل الآلي:",
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: TColors.primary),
                      ),
                      const SizedBox(height: TSizes.xs),
                      TextFormField(
                        controller: controller.senderNameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.account_balance_wallet_outlined,
                          ),
                          hintText: "اسامه احمد يوسف ابوشرخ",
                          labelText: "اسمك في تطبيق المحفظة",
                          // تصميم عصري متناسق مع التطبيق
                          filled: true,
                          fillColor: dark
                              ? TColors.darkerGrey
                              : TColors.grey.withOpacity(0.1),
                          border: const OutlineInputBorder().copyWith(
                            borderRadius: BorderRadius.circular(
                              TSizes.cardRadiusLg,
                            ),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: TSizes.xs),
                      Text(
                        "* يجب أن يطابق اسمك في تطبيق البنك تماماً لضمان التفعيل.",
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
