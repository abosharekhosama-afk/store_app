import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/payment/payment_tile.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:untitled2_ecom/features/personalization/models/address_model_new.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/cart_controller.dart';
import 'package:untitled2_ecom/features/shop/models/cart_item_model.dart';
import 'package:untitled2_ecom/features/shop/models/payment_method_model.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class CheckoutController extends GetxController {
  static CheckoutController get instance => Get.find();

  final Rx<PaymentMethodModel> selectedPaymentMethod =
      PaymentMethodModel.emoty().obs;
  final controller = CartController.instance;
  final senderNameController = TextEditingController();

  // متغير مراقب لتكلفة الشحن الإجمالية
  RxDouble totalShippingCost = 0.0.obs;
  RxBool isShippingLoading = false.obs; // لمعرفة حالة جلب أسعار الشحن بالخلفية

  // 🌟 حقول المحفظة الجديدة
  var useWallet = false.obs; // تتبع هل وضع العميل علامة الدفع من المحفظة
  var userWalletBalance =
      0.0.obs; // رصيد المحفظة الفعلي القادم من حساب المستخدم الحالي

  @override
  void onInit() {
    // TODO: implement onInit
    selectedPaymentMethod.value = PaymentMethodModel(
      image: TImages.paypal,
      name: "PayPal",
    );
    _fetchUserWalletBalance(); // جلب رصيد محفظة العميل عند فتح صفحة الدفع
    super.onInit();
  }

  @override
  void onClose() {
    senderNameController.dispose();
    super.onClose();
  }

  Future<void> _fetchUserWalletBalance() async {
    try {
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          userWalletBalance.value = (userDoc.data()?['walletBalance'] ?? 0.0)
              .toDouble();
        }
      }
    } catch (e) {
      print("Error fetching wallet balance: $e");
    }
  }

  Future<dynamic> selectPaymentMethod(BuildContext contex) {
    return showModalBottomSheet(
      context: contex,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(TSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeading(
                labelText: "اختر طريقة الدفع",
                showButtton: false,
                padding: EdgeInsets.all(0),
              ),
              SizedBox(height: TSizes.spaceBtwSections),
              TPaymentTile(
                paymentMethod: PaymentMethodModel(
                  name: "PayPal",
                  image: TImages.paypal,
                ),
              ),
              SizedBox(height: TSizes.spaceBtwItems / 2),
              TPaymentTile(
                paymentMethod: PaymentMethodModel(
                  name: "Google pay",
                  image: TImages.googlePay,
                ),
              ),
              SizedBox(height: TSizes.spaceBtwItems / 2),
              TPaymentTile(
                paymentMethod: PaymentMethodModel(
                  name: "VISA",
                  image: TImages.visa,
                ),
              ),
              SizedBox(height: TSizes.spaceBtwItems / 2),
              TPaymentTile(
                paymentMethod: PaymentMethodModel(
                  name: "Master Card",
                  image: TImages.masterCard,
                ),
              ),
              SizedBox(height: TSizes.spaceBtwItems / 2),
              TPaymentTile(
                paymentMethod: PaymentMethodModel(
                  name: "Credit Card",
                  image: TImages.creditCard,
                ),
              ),
              SizedBox(height: TSizes.spaceBtwItems / 2),
              SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لتجميع المنتجات حسب الحي والشارع
  // تجميع المنتجات حسب الموقع (حي + شارع)
  Map<String, List<CartItemModel>> groupItemsByLocation(
    List<CartItemModel> items,
    Map<String, AddressModelNew> storeAddresses,
  ) {
    Map<String, List<CartItemModel>> groups = {};
    for (var item in items) {
      final addr = storeAddresses[item.storeId];
      String locationKey =
          "${addr?.district ?? 'غير محدد'} - ${addr?.street ?? ''}";

      if (!groups.containsKey(locationKey)) {
        groups[locationKey] = [];
      }
      groups[locationKey]?.add(item);
    }
    return groups;
  }
}
