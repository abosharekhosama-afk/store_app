
/*
class OrderController extends GetxController {
  static OrderController get instans => Get.find();

  final cartController = CartController.instance;
  final addressController = AddressController.instance;
  final checkoutController = CheckoutController.instance;
  final orderReposity = Get.put(OrderReposity());

  Future<List<OrderModel>> fetchUserOrder() async {
    try {
      final userOrder = await orderReposity.fetchUserOrders();
      return userOrder;
    } catch (e) {
      TLoaders.warningSnackBar(title: "يا للهول", message: e.toString());
      return [];
    }
  }

  void processOrder(double totalAmount) async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "جارٍ معالجة طلبك",
        TImages.pencilAnimation,
      );

      final userId = AuthenticationRepository.instance.authUser!.uid;
      if (userId.isEmpty) return;

      final order = OrderModel(
        id: UniqueKey().toString(),
        userId: userId,
        status: OrderStatus.pending,
        totalAmount: totalAmount,

        orderDate: DateTime.now(),
        paymentMethod: checkoutController.selectedPaymentMethod.value.name,
        address: addressController.selctedAddress.value,
        deliveryDate: DateTime.now(),
        items: cartController.cartItems.toList(),
      );

      await orderReposity.saveOrder(order, userId);
      cartController.clearCart();
      Get.off(
        () => SuccessScreen(
          image: TImages.paymentSuccessfulAnimation,
          title: "تمت عملية الدفع بنجاح",
          subTitle: "سيتم شحن طلبك قريباً!",
          onPressed: () => Get.offAll(() => const NavigationMenu()),
        ),
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
    }
  }
}
*/