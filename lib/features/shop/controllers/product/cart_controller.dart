import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/enums.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/variation_controller.dart';
import 'package:untitled2_ecom/features/shop/models/cart_item_model.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/features/shop/models/product_variation_model.dart';
import 'package:untitled2_ecom/utils/local_storage/storage_utility.dart';
import 'package:untitled2_ecom/utils/popups/exports.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();

  RxInt noOfCartItem = 0.obs;
  RxDouble totalCartPrice = 0.0.obs;
  RxInt productQuantityInCart = 0.obs;
  RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final variationController = Get.put(VariationController());

  @override
  onInit() {
    super.onInit();
    loadCartItems();
  }

  void addToCart(ProductModel product) {
    if (productQuantityInCart.value < 1) {
      TLoaders.customToast(message: "الرجاء اختيار الكمية");
      return;
    }
    if (product.isVariableProduct &&
        variationController.selectedVariation.value.id.isEmpty) {
      TLoaders.customToast(message: "الرجاء اختيار الاختيار");
      return;
    }
    if (product.isVariableProduct) {
      if (variationController.selectedVariation.value.stock < 1) {
        TLoaders.warningSnackBar(
          title: "يا للهول",
          message: "الاختيار المحدد غير متوفر في المخزون.",
        );
        return;
      }
    } else {
      if (product.stock < 1) {
        TLoaders.warningSnackBar(
          title: "يا للهول",
          message: "المنتج المحدد غير متوفر في المخزون.",
        );
        return;
      }
    }

    final selectedCartItem = convertToCartItem(
      product,
      productQuantityInCart.value,
    );

    int index = cartItems.indexWhere(
      (element) =>
          element.productId == selectedCartItem.productId &&
          element.variationId == selectedCartItem.variationId,
    );

    if (index >= 0) {
      cartItems[index].quantity = selectedCartItem.quantity;
    } else {
      cartItems.add(selectedCartItem);
    }

    updateCart();
    TLoaders.customToast(message: "تمت إضافة المنتج إلى السلة.");
    variationController.resetSelectedAttributes();
  }

  CartItemModel convertToCartItem(ProductModel product, int quantity) {
    if (product.isSingleProduct) {
      variationController.resetSelectedAttributes();
    }

    final productId = product.id;
    final variation = variationController.selectedVariation.value;
    final isVariation = variation.id.isNotEmpty;
    final price = isVariation
        ? variation.salePrice > 0.0
              ? variation.salePrice
              : variation.price
        : product.salePrice > 0.0
        ? product.salePrice
        : product.price;

    return CartItemModel(
      productId: productId,
      quantity: quantity,
      price: price,
      title: product.title,
      variationId: variation.id,
      image: isVariation ? variation.image : product.thumbnail,
      selectedVariation: isVariation ? variation.attributeValues : null,
      storeId: product.storId,
      productSnapshot: product.toJson(),
      itemStatus: ItemStatus.pending,
    );
  }

  void updateCart() {
    updateCartTotals();
    saveCartItems();
    cartItems.refresh();
  }

  int getVariationQuantityInCart(String productId, String variationId) {
    // حماية: إذا كانت السلة فارغة أو المعرفات فارغة لا تبحث وتسبب خطأ
    if (cartItems.isEmpty || productId.isEmpty || variationId.isEmpty) return 0;

    try {
      final foundItem = cartItems.firstWhere(
        (item) =>
            item.productId == productId && item.variationId == variationId,
        orElse: () => CartItemModel.empty(),
      );
      return foundItem.quantity;
    } catch (e) {
      // لمنع أي Bad State ناتج عن التكرار غير المتوقع
      return 0;
    }
  }

  void clearCart() {
    productQuantityInCart.value = 0;
    cartItems.clear();
    updateCart();

    // 🔥 تصحيح جوهري: تصفير حالة المتغيرات المختارة حتى لا تبحث الواجهات الرئيسية عن فاريشن قديم تم ششراؤه
    if (Get.isRegistered<VariationController>()) {
      VariationController.instance.resetSelectedAttributes();
      VariationController.instance.selectedVariation.value =
          ProductVariationModel.empty(); // تأكد من اسم موديل الفاريشن الفارغ لديك
    }
  }

  void updateCartTotals() {
    double calculatedTotalPrice = 0.0;
    int calculattedNoOfItems = 0;
    for (var item in cartItems) {
      calculatedTotalPrice += (item.price) * item.quantity.toDouble();
      calculattedNoOfItems += item.quantity;
    }
    totalCartPrice.value = calculatedTotalPrice;
    noOfCartItem.value = calculattedNoOfItems;
  }

  void saveCartItems() {
    final cartItemString = cartItems
        .map((element) => element.toJson())
        .toList();

    TLocalStorage.instance().saveData(
      CartItemModel.getCartItemForLocalStorage,
      cartItemString,
    );
  }

  // 📂 دالة التحميل الذكي عند تشغيل التطبيق
  void loadCartItems() {
    try {
      final rawData = TLocalStorage.instance().readData(
        CartItemModel.getCartItemForLocalStorage,
      );

      if (rawData != null) {
        // تحويل آمن وديناميكي تماماً للمصفوفة القادمة من الـ Local Storage
        final List<dynamic> cartList = rawData is List ? rawData : [];

        final List<CartItemModel> loadedItems = cartList.map((element) {
          // تحويل كل عنصر داخلي إلى Map<String, dynamic> بشكل صارم
          final Map<String, dynamic> itemMap = Map<String, dynamic>.from(
            element as Map,
          );
          return CartItemModel.fromJson(itemMap);
        }).toList();

        cartItems.assignAll(loadedItems);
        updateCartTotals();
      }
    } catch (e) {
      // اطبع الخطأ في الـ Console لتعرف المشكلة بالتحديد دون مسح البيانات فوراً
      debugPrint("🎯 خطأ بنية البيانات أثناء تحميل السلة: $e");
      TLoaders.errorSnackBar(
        title: e.toString(),
        message:
            "حدث خطأ أثناء تحميل عناصر السلة. سيتم مسح البيانات لحماية التطبيق.",
      );
      // اختياري: قم بتفعيل الحذف فقط إذا كنت متأكداً أن البيانات تالفة تماماً
      // TLocalStorage.instance().removeData(CartItemModel.getCartItemForLocalStorage);
    }
  }

  /*
  void loadCartItems() {
    try {
      final cartItemsString = TLocalStorage.instance().readData<List<dynamic>>(
        CartItemModel.getCartItemForLocalStorage,
      );

      if (cartItemsString != null && cartItemsString.isNotEmpty) {
        // حماية البيانات: نقوم بتحويل البيانات بشكل آمن لمنع الـ Type Casting Exception
        final List<CartItemModel> loadedItems = cartItemsString.map((element) {
          return CartItemModel.fromJson(Map<String, dynamic>.from(element));
        }).toList();

        cartItems.assignAll(loadedItems);
        updateCartTotals();
      }
    } catch (e) {
      debugPrint("🎯 فشل تحميل عناصر السلة محلياً: $e");
      // في حالة حدوث خطأ بنيوي في الـ Json المخزن نقوم بتنظيفه لحماية التطبيق من الكراش
      TLocalStorage.instance().removeData(
        CartItemModel.getCartItemForLocalStorage,
      );
    }
  }
*/
  int getProductQuantityInCart(String productId) {
    final foudItem = cartItems
        .where((item) => item.productId == productId)
        .fold(0, (previousValue, element) => previousValue + element.quantity);
    return foudItem;
  }

  /*int getVariationQuantityInCart(String productId, String variationId) {
    final foudItem = cartItems.firstWhere(
      (item) => item.productId == productId && item.variationId == variationId,
      orElse: () => CartItemModel.empty(),
    );
    return foudItem.quantity;
  }
*/
  /*void clearCart() {
    productQuantityInCart.value = 0;
    cartItems.clear();
    updateCart();
  }*/

  void addOneToCart(CartItemModel item) {
    int index = cartItems.indexWhere(
      (element) =>
          element.productId == item.productId &&
          element.variationId == item.variationId,
    );
    if (index >= 0) {
      cartItems[index].quantity += 1;
    } else {
      cartItems.add(item);
    }
    updateCart();
  }

  void removeOneFromCart(CartItemModel item) {
    int index = cartItems.indexWhere(
      (element) =>
          element.productId == item.productId &&
          element.variationId == item.variationId,
    );
    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity -= 1;
      } else {
        cartItems[index].quantity == 1
            ? removeFromCartDialog(index)
            : cartItems.removeAt(index);
      }
    }

    updateCart();
  }

  void removeFromCartDialog(int index) {
    Get.defaultDialog(
      title: "حذف المنتج",
      middleText: "هل أنت متأكد أنك تريد إزالة هذا المنتج؟",
      onConfirm: () {
        cartItems.removeAt(index);
        updateCart();
        TLoaders.customToast(message: "تمت إزالة المنتج من السلة.");
        Get.back();
      },
      onCancel: () =>
          () => Get.back(),
    );
  }

  void updateAlreadyAddedProductCount(ProductModel product) {
    if (product.isSingleProduct) {
      productQuantityInCart.value = getProductQuantityInCart(product.id);
    } else {
      final variationId = variationController.selectedVariation.value.id;
      if (variationId.isNotEmpty) {
        productQuantityInCart.value = getVariationQuantityInCart(
          product.id,
          variationId,
        );
      } else {
        productQuantityInCart.value = 0;
      }
    }
  }
}
