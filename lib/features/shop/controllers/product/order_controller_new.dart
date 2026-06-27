import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled2_ecom/common/widgets/success_screen/success_screen.dart';
import 'package:untitled2_ecom/data/repositories/order/order_repository_new.dart';
import 'package:untitled2_ecom/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:untitled2_ecom/enums.dart';
import 'package:untitled2_ecom/features/personalization/controllers/address_controller.dart';
import 'package:untitled2_ecom/features/personalization/models/address_model_new.dart';
import 'package:untitled2_ecom/features/personalization/models/user_stor_model.dart';
import 'package:untitled2_ecom/features/shop/controllers/checkout_controller.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/cart_controller.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/product_controller.dart';
import 'package:untitled2_ecom/features/shop/models/order_model.dart';
import 'package:untitled2_ecom/features/shop/models/cart_item_model.dart';
import 'package:untitled2_ecom/features/shop/models/shipping_calculator_service.dart';
import 'package:untitled2_ecom/navigation_menu.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/helpers/network_manager.dart';
import 'package:untitled2_ecom/utils/logging/logger.dart';
import 'package:untitled2_ecom/utils/popups/full_screen_loader.dart';
import 'package:untitled2_ecom/utils/popups/loaders.dart';
import 'package:cloud_functions/cloud_functions.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  // Variables
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final cartController = CartController.instance;
  final addressController = AddressController.instance; // لإدارة عنوان الزبون
  final orderRepository = Get.put(OrderRepository());
  final RxList<OrderModel> userOrders = <OrderModel>[].obs;
  final isLoading = false.obs;
  var isCancelLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;

  // متغير مراقب لتكلفة الشحن الإجمالية
  RxDouble totalShippingCost = 0.0.obs;
  RxBool isShippingLoading = false.obs; // لمعرفة حالة جلب أسعار الشحن بالخلفية

  // قائمة لتخزين طلبات المستخدم
  var isOrdersLoading = false.obs;
  RxMap<String, AddressModelNew> storeAddresses =
      <String, AddressModelNew>{}.obs;
  // 🔥 [السر البرمجي]: خريطة لتخزين المتاجر كاملة في الذاكرة لمنع إعادة الجلب من الفايربيز
  final RxMap<String, StoreModel> fetchedStoresCache =
      <String, StoreModel>{}.obs;

  var shippingBreakdown = <String, double>{}.obs;

  final ScrollController scrollController = ScrollController();
  DocumentSnapshot? _lastDocument;
  final int _initialLimit = 15;
  final int _nextLimit = 10;

  @override
  void onInit() {
    super.onInit();
    getStoreAddresses(cartController.cartItems);
    fetchUserOrders(); // الجلب الأول عند تشغيل الكنترولر

    // الاستماع لحدث التمرير
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        fetchMoreUserOrders(); // جلب المزيد قبل الوصول للقاع بـ 200 بكسل لتجربة مستخدم سلسة
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  /// دالة معالجة الطلب (Checkout)
  Future<void> processOrder(double totalAmount) async {
    try {
      final checkoutController = CheckoutController.instance;

      // 1️⃣ أولاً: التحققات الأمنية وصلاحية البيانات (قَبْل فتح الـ Loader تماماً)
      if (!verifyStoresBeforeCheckout()) return;
      // أ) التحقق من تسجيل الدخول
      final authUser = AuthenticationRepository.instance.authUser;
      if (authUser == null) {
        TLoaders.warningSnackBar(
          title: 'يرجى تسجيل الدخول',
          message: 'يجب تسجيل الدخول لإتمام الطلب.',
        );
        return; // نخرج فوراً دون استدعاء stopLoading
      }

      // ب) التحقق من أن السلة ليست فارغة
      if (cartController.cartItems.isEmpty) {
        TLoaders.warningSnackBar(
          title: 'عذراً',
          message: 'يجب ان تحتوي السلة على عنصر واحد على الاقل لاتمام الطلب.',
        );
        return;
      }

      // ج) التحقق من وجود عنوان شحن مختار
      final selectedAddress = addressController.selctedAddress.value;
      if (selectedAddress.id.isEmpty) {
        TLoaders.warningSnackBar(
          title: 'العنوان مفقود',
          message: 'يرجى اختيار عنوان الشحن أولاً.',
        );
        return;
      }

      // 3. التحقق الأمني من المدخلات بناءً على الفرز المالي المتوقع (قبل استدعاء السيرفر)
      final double walletBalance = checkoutController.userWalletBalance.value;
      final bool isWalletChecked = checkoutController.useWallet.value;
      // هل رصيد المحفظة يغطي الفاتورة بالكامل؟
      final bool isWalletCoverAll =
          isWalletChecked && walletBalance >= totalAmount;

      // إذا كان هناك مبلغ سيتبقى للبنك (سواء دفع بنكي كامل أو دفع جزئي)، يجب كتابة اسم المحول
      if (!isWalletCoverAll &&
          checkoutController.senderNameController.text.trim().isEmpty) {
        TLoaders.warningSnackBar(
          title: 'الاسم مطلوب',
          message:
              'الرصيد لا يغطي كامل المبلغ، يرجى كتابة اسمك في الحساب البنكي للتفعيل الآلي عند التحويل.',
        );
        return; // اخرج بأمان، والـ SnackBar ستظهر فوق واجهة الـ Checkout مباشرة
      }

      // 4. بدء مؤشر التحميل الشامل لمنع المستخدم من ضغط الزر مرتين
      TFullScreenLoader.openLoadingDialog(
        'جاري معالجة طلبك وتأمين الحسابات المادية...',
        TImages.docerAnimation,
      );

      // 5. جلب بيانات عناوين المتاجر (تستخدم للسيرفر أو الحسابات اللوجستية إذا لزم)
      /*Map<String, AddressModelNew> storeAddresses = await getStoreAddresses(
        cartController.cartItems,
      );*/

      // 6. توليد المعرفات العشوائية ورموز التوصيل السرية (نرسلها جاهزة لتخزينها متطابقة)
      final String generatedId = (100000000 + Random().nextInt(900000000))
          .toString();
      final String generatedDeliveryCode = (100000 + Random().nextInt(900000))
          .toString();

      // 7. تحويل المنتجات الحالية في السلة إلى صيغة JSON ليتمكن السيرفر من قراءتها وتفكيكها للمتاجر
      final List<Map<String, dynamic>>
      itemsJson = cartController.cartItems.map((item) {
        final json = item.toJson();
        // نضمن إرسال السعر الإجمالي للشحن والمنتج الفرعي داخل كل عنصر للتوثيق في الـ StoreOrders
        return json;
      }).toList();

      // اذهب للخطوة رقم 8 في دالة processOrder وقم بتعديل سطر العنوان ليصبح هكذا:
      final Map<String, dynamic> addressData = selectedAddress.toJson();
      addressData[AddressModelNew.getDateTime] = DateTime.now()
          .toIso8601String(); // تحويل الوقت لنص متوافق مع الـ JSON

      // 8. استدعاء دالة الكلاود (Cloud Function) لإجراء الـ Transaction والفرز المالي
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'createNewOrderWithSmartPayment',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 45)),
      );
      // تنظيف قائمة المنتجات وحل مشكلة DateTime الصادر من كوليكشن الـ items
      final List<dynamic> cleanItemsJson = jsonDecode(
        jsonEncode(
          itemsJson,
          toEncodable: (item) {
            if (item is DateTime) return item.toIso8601String();
            return item.toString();
          },
        ),
      );
      final response = await callable.call(<String, dynamic>{
        'orderId': generatedId,
        'totalAmount': totalAmount,
        'itemsAmount': cartController.totalCartPrice.value,
        'shippingAmount': totalShippingCost.value,
        'useWallet': isWalletChecked,
        'deliveryCode': generatedDeliveryCode,
        'senderName': checkoutController.senderNameController.text.trim(),
        'userAddress': addressData,
        'items': cleanItemsJson,
      });

      // 9. معالجة استجابة السيرفر وتفريغ السلة عند النجاح
      if (response.data != null && response.data['success'] == true) {
        final String finalStatus = response.data['status'];
        final double bankRequired = (response.data['bankRequiredAmount'] ?? 0.0)
            .toDouble();

        // تفريغ السلة محلياً بعد التأكد من نجاح حفظها وسحب رصيد المحفظة في السيرفر
        cartController.clearCart();
        // تصفير العداد العام في السلة يدوياً لضمان تحديث الـ UI فوراً
        cartController.noOfCartItem.value = 0;
        cartController.totalCartPrice.value = 0.0;
        // 🔥 [إصلاح جوهري]: إعادة تعيين قيم الـ Scroll والـ Collapse لشاشة Home حتى لا تنهار عند العودة
        // إعادة تعيين قيم الـ Scroll والـ Collapse لشاشة Home حتى لا تنهار عند العودة
        final productController = Get.put(ProductController());
        productController.scrollOffset.value = 0.0;
        productController.isCollapsedPersisted.value = false;
        if (productController.scrollController.hasClients) {
          productController.scrollController.jumpTo(0.0);
        }
        TFullScreenLoader.stopLoading();

        // تخصيص رسالة النجاح للمستخدم بناءً على نوع الدفع المكتمل في السيرفر
        String successSubTitle = '';
        if (finalStatus == "pending") {
          successSubTitle =
              'تم خصم كامل المبلغ من محفظتك بنجاح! وتم تفعيل الطلب للمتاجر للبدء في التجهيز فوراً.';
        } else if (bankRequired > 0 && isWalletChecked) {
          successSubTitle =
              'تم حجز رصيد المحفظة بنجاح، يرجى تحويل المبلغ المتبقي (\$$bankRequired) عبر الحساب البنكي لتفعيل الطلب آلياً.';
        } else {
          successSubTitle =
              'تم تسجيل طلبك بنجاح، بانتظار تحويل مبلغ الفاتورة كاملاً (\$$bankRequired) عبر البنك لبدء التجهيز.';
        }

        // توجيه العميل لشاشة النجاح
        // توجيه العميل لشاشة النجاح
        Get.off(
          () => SuccessScreen(
            onPressed: () {
              // لتجنب خطأ التكرار، نقوم بتهيئة وعمل فحص آمن لـ NavigationController
              final navigationController = Get.put(NavigationController());
              navigationController.selectedIndex.value =
                  0; // إرجاعه لتبويب الهوم

              // مسح كل الـ Stack وبدء التطبيق نظيف خالي من أي بقايا بيانات ميتة في الذاكرة
              Get.offAll(() => const NavigationMenu());
            },
            image: TImages.tWelcomeScreenImage,
            title: 'تم تقديم الطلب بنجاح! 🎉',
            subTitle: successSubTitle,
          ),
        );
      } else {
        throw 'استجابة غير صالحة من خادم قاعدة البيانات.';
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      // إظهار رسالة الخطأ الصادرة من الـ HttpsError المكتوبة في السيرفر لتنبيه العميل بدقة
      print('Error occurred: $e');
      TLoaders.errorSnackBar(
        title: 'خطأ في معالجة الدفع والطلب',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // الدالة التي تحسب الشحن ديناميكياً وتقوم بتحديث الواجهة فوراً (المحدثة)
  Future<void> calculateShippingCost() async {
    // تحقق أولاً من وجود عنوان زبون وعناوين متاجر لتجنب الأخطاء
    if (addressController.selctedAddress.value.id.isEmpty ||
        storeAddresses.isEmpty) {
      totalShippingCost.value = 0.0;
      shippingBreakdown.clear(); // تصفير التفاصيل أيضاً
      return;
    }

    try {
      isShippingLoading.value = true;

      // 🌟 استدعاء دالة الحساب المطورة التي ترجع الخريطة الثنائية (الإجمالي + التفاصيل)
      final Map<String, dynamic> shippingResult =
          await ShippingCalculatorService.calculateDetailedShipping(
            items: cartController.cartItems,
            userAddress: addressController.selctedAddress.value,
            storeAddresses: storeAddresses,
            addressDataMap: addressController.palestineAddressData,
          );

      // 1️⃣ تحديث التكلفة الكلية (التي تقرأها الواجهة حالياً)
      totalShippingCost.value = shippingResult['total'] ?? 0.0;

      // 2️⃣ تحديث خريطة التفاصيل الفرعية ليتم رسمها في واجهة الفاتورة تحت السعر مباشرة
      final Map<String, double> breakdownData = Map<String, double>.from(
        shippingResult['breakdown'] ?? {},
      );
      shippingBreakdown.assignAll(breakdownData);
    } catch (e) {
      debugPrint("❌ Error updating shipping cost: $e");
      totalShippingCost.value = 0.0;
      shippingBreakdown.clear();
    } finally {
      isShippingLoading.value = false;
    }
  }

  /*
  // الدالة التي تحسب الشحن ديناميكياً وتقوم بتحديث الواجهة فوراً
  Future<void> calculateShippingCost() async {
    // تحقق أولاً من وجود عنوان زبون وعناوين متاجر لتجنب الأخطاء
    if (addressController.selctedAddress.value.id.isEmpty ||
        storeAddresses.isEmpty) {
      totalShippingCost.value = 0.0;
      return;
    }

    try {
      isShippingLoading.value = true;

      // استدعاء دالة الحساب المحدثة مع تفعيل الـ await
      double
      calculatedFee = await ShippingCalculatorService.calculateTotalShipping(
        items: cartController.cartItems,
        userAddress: addressController.selctedAddress.value,
        storeAddresses:
            storeAddresses, // تأكد أن هذه الخريطة تحتوي على موديلات عناوين المتاجر متكاملة
        addressDataMap: addressController.palestineAddressData,
      );

      totalShippingCost.value = calculatedFee;
    } catch (e) {
      totalShippingCost.value = 0.0;
    } finally {
      isShippingLoading.value = false;
    }
  }
*/
  /*
  Future<void> processOrder(double totalAmount) async {
    try {
      final checkoutController = CheckoutController.instance;
      if (!verifyStoresBeforeCheckout()) return;

      final authUser = AuthenticationRepository.instance.authUser;

      if (cartController.cartItems.isEmpty) {
        TLoaders.warningSnackBar(
          title: 'عذراً',
          message: 'يجب أن تحتوي السلة على عنصر واحد على الأقل لإتمام الطلب.',
        );
        return;
      }

      if (authUser == null) {
        TLoaders.warningSnackBar(
          title: 'يرجى تسجيل الدخول',
          message: 'يجب تسجيل الدخول لإتمام الطلب.',
        );
        return;
      }

      // 1. بدء مؤشر التحميل الشامل
      TFullScreenLoader.openLoadingDialog(
        'جاري معالجة المعاملة المالية وتثبيت الطلب...',
        TImages.docerAnimation,
      );

      final selectedAddress = addressController.selctedAddress.value;
      if (selectedAddress.id.isEmpty) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'العنوان مفقود',
          message: 'يرجى اختيار عنوان الشحن أولاً.',
        );
        return;
      }

      // تحقق: إذا كان متبقي مبلغ للبنك، يجب كتابة اسم المحفظة/الحساب للتفعيل الآلي
      double balance = checkoutController.userWalletBalance.value;
      bool isWalletCoverAll =
          checkoutController.useWallet.value && balance >= totalAmount;

      if (!isWalletCoverAll &&
          checkoutController.senderNameController.text.trim().isEmpty) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'الاسم مطلوب',
          message:
              'الرصيد لا يغطي كامل المبلغ، يرجى كتابة اسم المرسل في البنك للتفعيل الآلي عند وصول التحويل.',
        );
        return;
      }

      Map<String, AddressModelNew> storeAddresses = await getStoreAddresses(
        cartController.cartItems,
      );
      final generatedId = (100000000 + Random().nextInt(900000000)).toString();

      // 2. تجهيز مصفوفة العناصر بصيغة Json المناسبة للإرسال إلى الكلاود دالة
      final List<Map<String, dynamic>> itemsJson = cartController.cartItems
          .map((item) => item.toJson())
          .toList();

      // 3. استدعاء السيرفر (Cloud Function) لتأمين واحتساب المعاملة المالية
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'createNewOrderWithSmartPayment',
      );

      final response = await callable.call(<String, dynamic>{
        'orderId': generatedId,
        'totalAmount': totalAmount,
        'useWallet': checkoutController.useWallet.value,
        'items': itemsJson,
        // البيانات الإضافية للتوثيق في الطلب الرئيسي
        'senderName': checkoutController.senderNameController.text.trim(),
        'selectedAddress': selectedAddress.toJson(),
      });

      // 4. فحص استجابة السيرفر وتوجيه العميل بناءً على النتيجة المالية المفرزة
      if (response.data != null && response.data['success'] == true) {
        String finalStatus = response.data['status'];
        double bankRequired = (response.data['bankRequiredAmount'] ?? 0.0)
            .toDouble();

        cartController.clearCart();
        TFullScreenLoader.stopLoading();

        // صياغة الرسالة المناسبة للمستخدم حسب الحالة المفرزة
        String successSubTitle = '';
        if (finalStatus == "pending") {
          successSubTitle =
              'تم خصم كامل المبلغ من محفظتك وتفعيل الطلب فوراً للمتاجر وجاري التجهيز!';
        } else if (bankRequired > 0 && checkoutController.useWallet.value) {
          successSubTitle =
              'تم حجز رصيد المحفظة، يرجى تحويل المبلغ المتبكي (\$$bankRequired) عبر البنك لتفعيل الطلب آلياً.';
        } else {
          successSubTitle =
              'تم تسجيل طلبك بنجاح، بانتظار تحويل مبلغ الفاتورة كاملاً عبر البنك لبدء العمل.';
        }

        Get.off(
          () => SuccessScreen(
            onPressed: () => Get.offAll(() => NavigationMenu()),
            image: TImages.tWelcomeScreenImage,
            title: 'تم تقديم الطلب بنجاح! 🎉',
            subTitle: successSubTitle,
          ),
        );
      } else {
        throw 'فشل السيرفر في تأمين رصيد الفاتورة الحالية.';
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'خطأ في معالجة الدفع',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
*/
  /*
  Future<void> processOrder(double totalAmount) async {
    try {
      final checkoutController = CheckoutController.instance;
      if (!verifyStoresBeforeCheckout()) return;
      // التحقق من تسجيل الدخول
      final authUser = AuthenticationRepository.instance.authUser;

      if (cartController.cartItems.isEmpty) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'عذرا',
          message: 'يجب ان تحتوي السلة على عنصر واحد على الاقل لا تمام الطلب.',
        );
        return;
      }

      if (authUser == null) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'يرجى تسجيل الدخول',
          message: 'يجب تسجيل الدخول لإتمام الطلب.',
        );
        return;
      }

      // تحقق: إذا كانت الطريقة المختارة هي PayPal، يجب أن لا يكون الاسم فارغاً
      if (checkoutController.selectedPaymentMethod.value.name == "PayPal" &&
          checkoutController.senderNameController.text.trim().isEmpty) {
        TLoaders.warningSnackBar(
          title: 'الاسم مطلوب',
          message: 'يرجى كتابة اسمك في المحفظة للتفعيل الآلي.',
        );
        return;
      }

      // 1. بدء مؤشر التحميل
      TFullScreenLoader.openLoadingDialog(
        'جاري معالجة طلبك...',
        TImages.docerAnimation,
      );

      // 2. التحقق من وجود عنوان شحن مختار
      final selectedAddress = addressController.selctedAddress.value;
      if (selectedAddress.id.isEmpty) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'العنوان مفقود',
          message: 'يرجى اختيار عنوان الشحن أولاً.',
        );
        return;
      }

      // 3. جلب بيانات المتاجر المشاركة في الطلب لحساب الشحن
      // ملاحظة: نحتاج Map تحتوي على (storeId مقابل AddressModel الخاص بالمتجر)
      Map<String, AddressModelNew> storeAddresses = await getStoreAddresses(
        cartController.cartItems,
      );

      // 4. إنشاء كائن الطلب باستخدام الدالة التي صممناها سابقاً
      final generatedId = (100000000 + Random().nextInt(900000000)).toString();
      final currentTime = DateTime.now();
      final order = OrderModel.createNewOrder(
        id: generatedId.toString(), // معرف فريد بسيط
        userId: authUser.uid,
        items: List.from(cartController.cartItems),
        userAddress: selectedAddress,
        storeAddresses: storeAddresses,
        senderName: checkoutController.senderNameController.text.trim().trim(),
        shippingTotal: totalShippingCost,
        itemsTotal: cartController.totalCartPrice.value,
        finalTotalAmount: finalTotalAmount,
        orderDate: currentTime,
        // وقت انتهاء الصلاحية بعد ساعة بالضبط
        expiresAt: currentTime.add(const Duration(hours: 1)), // تمرير الاسم هنا
      );

      // 5. حفظ الطلب في Firestore (التقسيم يحدث داخل Repository)
      await orderRepository.saveOrder(order);

      // 6. تحديث السلة (تفريغها)
      cartController.clearCart();

      // 7. إغلاق اللودر والانتقال لصفحة النجاح
      TFullScreenLoader.stopLoading();
      Get.off(
        () => SuccessScreen(
          onPressed: () => Get.offAll(() => NavigationMenu()),
          image: TImages.tWelcomeScreenImage,
          title: 'تم تقديم الطلب بنجاح!',
          subTitle: 'سيتم مراجعة طلبك من قبل المتاجر وشحنه قريباً.',
        ),
      );
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'خطأ في الطلب', message: e.toString());
    }
  }
*/
  /// دالة مساعدة لجلب عناوين المتاجر من قاعدة البيانات
  Future<Map<String, AddressModelNew>> getStoreAddresses(
    List<CartItemModel> items,
  ) async {
    Map<String, AddressModelNew> addresses = {};
    Map<String, StoreModel> stores = {};
    final storeIds = items.map((item) => item.storeId).toSet().toList();

    for (var id in storeIds) {
      // هنا نقوم بجلب مستند المتجر من Firestore
      // يمكنك استدعاء StoreRepository لجلب الـ StoreModel ومن ثم الـ addressModel منه
      TLoggerHelper.debug("id---------$id");
      final storeData = await orderRepository.getStoreById(id);
      // 🔥 [دمج المنطق] الفحص الفوري لحالة المتجر
      // افترضت هنا أن حقل isOpen موجود داخل الـ StoreModel الخاص بك
      stores[id] = storeData;
      addresses[id] = storeData.addressModel;
    }
    fetchedStoresCache.assignAll(stores);
    storeAddresses.assignAll(addresses);
    return addresses;
  }

  /// 🔍 1. دالة ذكية تستخدمها الواجهة (UI) لتحديد إن كان منتج معين يتبع لمتجر مغلق
  bool isProductStoreClosed(String storeId) {
    // تقرأ من كاش الذاكرة فوراً بصفر تكلفة 0 Reads
    final store = fetchedStoresCache[storeId];
    if (store != null) {
      return store.isOpen == false;
    }
    return false;
  }

  /// 🚫 2. دالة الفحص الحاسم عند ضغط زر الشراء (بصفر تكلفة أيضاً!)
  bool verifyStoresBeforeCheckout() {
    // نمر على المنتجات الموجودة في السلة حالياً ونفحص حالتها من الكاش المحلي
    for (var item in cartController.cartItems) {
      final store = fetchedStoresCache[item.storeId];
      if (store != null && store.isOpen == false) {
        TLoaders.warningSnackBar(
          title: 'تنبيه السلة',
          message:
              'يوجد منتجات لشركات مغلقة حالياً في سلتك (موضحة باللون الأحمر)، يرجى إزالتها للاستمرار.',
        );
        return false; // توقف، توجد مشكلة
      }
    }
    return true; // كل شيء ممتاز
  }

  /// دالة للمتجر: تحديث حالة عنصر (قبول/رفض)
  Future<void> updateItemStatus(
    String storeOrderId,
    String mainOrderId,
    String productId,
    ItemStatus status,
  ) async {
    try {
      await orderRepository.updateStoreItemStatus(
        storeOrderId,
        mainOrderId,
        productId,
        status,
      );
      TLoaders.successSnackBar(
        title: 'تم التحديث',
        message: 'تم تغيير حالة المنتج بنجاح.',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'فشل التحديث', message: e.toString());
    }
  }

  /// الجلب الأول أو عند السحب للتحديث (Refresh)
  Future<void> fetchUserOrders() async {
    try {
      isLoading.value = true;
      hasMoreData.value = true;
      _lastDocument = null; // إعادة تصفير المؤشر

      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null) return;

      final result = await OrderRepository.instance.fetchUserOrdersPaginated(
        userId: userId,
        limit: _initialLimit,
        lastDocument: _lastDocument,
      );

      final List<OrderModel> fetchedOrders = result['orders'];
      _lastDocument = result['lastDocument'];

      userOrders.assignAll(fetchedOrders);
      print("nomb ${userOrders.length}");
      print("nomb ${fetchedOrders.length}");

      // إذا كانت البيانات العائدة أقل من الـ limit المطلوبة، يعني لا توجد بيانات أخرى في السيرفر
      if (fetchedOrders.length < _initialLimit) {
        hasMoreData.value = false;
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isSnackbarOpen == false) {
          // لمنع تكرار فتح السناك بار أكثر من مرة
          // TLoaders.errorSnackBar(title: 'خطأ', message: e.toString());
        }
      });
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب الدفعات الإضافية (10 طلبات في كل مرة)
  Future<void> fetchMoreUserOrders() async {
    // التحقق من الشروط لعدم تكرار الطلب بدون داعي
    if (isLoadingMore.value || !hasMoreData.value || isLoading.value) return;

    try {
      isLoadingMore.value = true;

      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null) return;

      final result = await OrderRepository.instance.fetchUserOrdersPaginated(
        userId: userId,
        limit: _nextLimit,
        lastDocument: _lastDocument,
      );

      final List<OrderModel> fetchedOrders = result['orders'];
      _lastDocument = result['lastDocument'];

      if (fetchedOrders.isEmpty) {
        hasMoreData.value = false;
      } else {
        userOrders.addAll(fetchedOrders);
        if (fetchedOrders.length < _nextLimit) {
          hasMoreData.value = false;
        }
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'خطأ', message: e.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }

  /*
  /// دالة جلب الطلبات وربطها بالواجهة
  void fetchUserOrders() {
    try {
      isLoading.value = true;

      // الحصول على ID المستخدم (افترضنا أنك تستخدم AuthenticationRepository)
      final userId = AuthenticationRepository.instance.authUser?.uid;

      if (userId != null) {
        // الاستماع للـ Stream القادم من المستودع
        OrderRepository.instance.fetchUserOrders(userId).listen((
          fetchedOrders,
        ) {
          // تحديث القائمة فور وصول أي بيانات جديدة
          userOrders.assignAll(fetchedOrders);
          isLoading.value = false;
        });
      }
    } catch (e) {
      isLoading.value = false;
      TLoaders.errorSnackBar(title: 'خطأ', message: e.toString());
    }
  }
*/
  // الدالة التي تحسب الشحن ديناميكياً في أي وقت
  /*double get totalShippingCost {
    // تحقق أولاً من وجود عنوان زبون وعناوين متاجر لتجنب الأخطاء
    if (addressController.selctedAddress.value.id.isEmpty ||
        storeAddresses.isEmpty) {
      return 0.0;
    }

    return ShippingCalculatorService.calculateTotalShipping(
      items: cartController.cartItems,
      userAddress: addressController.selctedAddress.value,
      storeAddresses: storeAddresses,
      addressDataMap: addressController.palestineAddressData,
    );
  }*/

  // إجمالي المبلغ النهائي (المنتجات + الشحن)
  double get finalTotalAmount {
    return cartController.totalCartPrice.value + totalShippingCost.value;
  }

  // ---------------------------------------------------------------------------
  // 1. إلغاء الطلب بالكامل (باستخدام الميزة التلقائية لـ Get.showOverlay)
  // ---------------------------------------------------------------------------
  Future<void> handleCancelOrderLogic(
    BuildContext context,
    OrderModel orderModel,
  ) async {
    // 1. فحص الاتصال بالإنترنت
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
      return;
    }

    // 2. التحقق المسبق من حالة الطلب محلياً
    if (orderModel.status != OrderStatus.pending &&
        orderModel.status != OrderStatus.pendingPayment) {
      _showWarningSnackBarByStatus(orderModel.status);
      return;
    }

    try {
      isCancelLoading.value = true;

      // تنفيذ عملية السيرفر بالكامل داخل شاشة التحميل الذكية لـ GetX
      final results = await Get.showOverlay<HttpsCallableResult>(
        opacity: 0.5,
        opacityColor: Colors.black,
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        // هنا نمرر الدالة المطلوبة وسيتم إغلاق اللودر تلقائياً فور انتهائها
        asyncFunction: () async {
          final HttpsCallable callable = FirebaseFunctions.instance
              .httpsCallable(
                'cancelOrderAndRefund',
                options: HttpsCallableOptions(
                  timeout: const Duration(seconds: 15),
                ),
              );
          return await callable.call(<String, dynamic>{
            'orderId': orderModel.id,
          });
        },
      );

      // هنا اللودر اختفى تلقائياً، نبدأ بمعالجة البيانات وعرض الرسائل بأمان
      if (results != null && results.data != null) {
        final resData = Map<String, dynamic>.from(results.data);
        final String status = resData['status'] ?? resData['Status'] ?? '';

        if (status == 'success') {
          // 🔥 [التحديث الفوري]: ابحث عن الطلب في القائمة واستبدله بالنسخة المعدلة
          final index = userOrders.indexWhere((o) => o.id == orderModel.id);
          if (index != -1) {
            userOrders[index] = orderModel.copyWith(
              status: OrderStatus.cancelled,
            );
          }

          // تحديث مستمعي GetBuilder (إذا كنت تستخدمه)
          update();

          final refundedAmount =
              resData['refundedAmount'] ?? resData['refunded_amount'] ?? '0';
          TLoaders.successSnackBar(
            title: "تم إلغاء الطلب بنجاح",
            message:
                "تم إلغاء طلبك بنجاح واسترداد مبلغ ($refundedAmount ILS) إلى محفظتك فوراً.",
          );
        } else {
          TLoaders.errorSnackBar(
            title: "فشلت العملية",
            message:
                resData['message'] ??
                "لم نتمكن من إلغاء الطلب، يرجى مراجعة الدعم.",
          );
        }
      }
    } on FirebaseFunctionsException catch (e) {
      TLoaders.errorSnackBar(
        title: "فشلت عملية الإلغاء",
        message: _getFriendlyErrorMessage(e),
      );
    } catch (e) {
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
    } finally {
      isCancelLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. إلغاء منتجات معينة من الطلب
  // ---------------------------------------------------------------------------
  Future<void> handleCancelSpecificItemsLogic({
    required BuildContext context,
    required OrderModel orderModel,
    required List<Map<String, dynamic>> itemsToCancel,
  }) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
      return;
    }

    if (itemsToCancel.isEmpty) {
      TLoaders.errorSnackBar(
        title: "عملية غير مكتملة",
        message: "يرجى تحديد منتج واحد على الأقل لتتمكن من تقديم الطلب.",
      );
      return;
    }

    try {
      isCancelLoading.value = true;

      final results = await Get.showOverlay<HttpsCallableResult>(
        opacity: 0.5,
        opacityColor: Colors.black,
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        asyncFunction: () async {
          final HttpsCallable callable = FirebaseFunctions.instance
              .httpsCallable(
                'cancelSpecificItems',
                options: HttpsCallableOptions(
                  timeout: const Duration(seconds: 20),
                ),
              );
          return await callable.call(<String, dynamic>{
            'orderId': orderModel.id,
            'itemsToCancel': itemsToCancel,
          });
        },
      );

      if (results != null && results.data != null) {
        final data = Map<String, dynamic>.from(results.data);
        final String status = data['status'] ?? data['Status'] ?? '';

        if (status == 'success') {
          final double refundedAmount =
              double.tryParse(data['refundedAmount'].toString()) ?? 0.0;
          final int cancelledCount = data['cancelledCount'] ?? 0;
          final int reviewCount = data['reviewCount'] ?? 0;

          // 🔥 [التحديث الفوري للمنتجات]:
          // نقوم بتحديث حالة العناصر محلياً بناءً على ما تم إرساله للسيرفر
          final index = userOrders.indexWhere((o) => o.id == orderModel.id);
          if (index != -1) {
            // نقوم بإنشاء قائمة عناصر جديدة ومحدثة
            final updatedItems = userOrders[index].items.map((item) {
              // فحص إذا كان هذا المنتج هو الذي تم إلغاؤه/إرجاعه
              final isTarget = itemsToCancel.any(
                (target) =>
                    target['productId'] == item.productId &&
                    target['variationId'] == item.variationId,
              );

              if (isTarget) {
                // تحديد الحالة الجديدة بناءً على الحالة السابقة (إذا كان معلقاً يلغى فوراً، وإلا فهو طلب معلق عند الإدارة)
                ItemStatus newStatus = item.itemStatus == ItemStatus.pending
                    ? ItemStatus.cancelled
                    : (item.itemStatus == ItemStatus.shipped ||
                          item.itemStatus == ItemStatus.delivered)
                    ? ItemStatus.returnRequested
                    : ItemStatus.cancellationRequested;

                return item.copyWith(
                  itemStatus: newStatus,
                ); // تأكد من امتلاك CartItemModel لدالة copyWith
              }
              return item;
            }).toList();

            // حفظ الطلب كاملاً بالعناصر المحدثة داخل الـ RxList
            userOrders[index] = userOrders[index].copyWith(items: updatedItems);
          }

          update();

          String successMessage = _buildCustomSuccessMessage(
            cancelledCount,
            reviewCount,
            refundedAmount,
          );
          TLoaders.successSnackBar(
            title: "تمت العملية بنجاح 🎉",
            message: successMessage,
          );
        }
      }

      /*
        if (status == 'success') {
          final double refundedAmount =
              double.tryParse(data['refundedAmount'].toString()) ?? 0.0;
          final int cancelledCount = data['cancelledCount'] ?? 0;
          final int reviewCount = data['reviewCount'] ?? 0;

          String successMessage = _buildCustomSuccessMessage(
            cancelledCount,
            reviewCount,
            refundedAmount,
          );

          TLoaders.successSnackBar(
            title: "تمت العملية بنجاح 🎉",
            message: successMessage,
          );
          update();
        }
        */
      //}
    } on FirebaseFunctionsException catch (e) {
      TLoaders.errorSnackBar(
        title: "فشلت عملية المعالجة",
        message: _getFriendlyErrorMessage(e),
      );
    } catch (e) {
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال 🌐",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت وتحديث الصفحة ثم المحاولة.",
      );
    } finally {
      isCancelLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. رفع إيصال الدفع اليدوي
  // ---------------------------------------------------------------------------
  Future<void> uploadPaymentReceipt(
    BuildContext context,
    String orderId,
    String userId,
  ) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) {
      TLoaders.warningSnackBar(
        title: "تم إلغاء العملية",
        message: "لم يتم اختيار أي صورة للإيصال.",
      );
      return;
    }

    try {
      isCancelLoading.value = true;

      // تشغيل اللودر المطور أثناء عمليات الرفع والكتابة في قاعدة البيانات
      await Get.showOverlay<void>(
        opacity: 0.5,
        opacityColor: Colors.black,
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        asyncFunction: () async {
          final File file = File(image.path);
          final String timestamp = DateTime.now().millisecondsSinceEpoch
              .toString();
          final String storagePath =
              'Users/$userId/Orders/$orderId/receipt_$timestamp.jpg';

          // 1. الرفع إلى الاستورج
          final Reference ref = _storage.ref().child(storagePath);
          final UploadTask uploadTask = ref.putFile(file);
          final TaskSnapshot snapshot = await uploadTask;
          final String downloadUrl = await snapshot.ref.getDownloadURL();

          // 2. الكتابة في الفايرستور (Batch)
          final WriteBatch batch = _db.batch();
          final DocumentReference orderRef = _db
              .collection('Orders')
              .doc(orderId);
          final DocumentReference paymentRequestRef = _db
              .collection('PaymentRequests')
              .doc(orderId);

          batch.update(orderRef, {
            'PaymentStatus': OrderStatus.pendingPaymentApproval.name,
          });
          batch.set(paymentRequestRef, {
            'requestId': orderId,
            'orderId': orderId,
            'userId': userId,
            'receiptUrl': downloadUrl,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
            'note': 'طلب تفعيل يدوي بموجب حوالة بنكية مرفقة.',
          });

          await batch.commit();
        },
      );

      // يظهر السناك بار فوراً بعد اختفاء اللودر تلقائياً
      TLoaders.successSnackBar(
        title: "تم رفع الإثبات بنجاح",
        message:
            "تم إرسال إيصال الدفع بنجاح، جاري مراجعته الآن لتفعيل طلبك من قبل الإدارة.",
      );
    } catch (e) {
      TLoaders.errorSnackBar(
        title: "فشلت العملية",
        message: "حدث خطأ غير متوقع أثناء معالجة الطلب: ${e.toString()}",
      );
    } finally {
      isCancelLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 🛠️ دوال مساعدة خاصة بالرسائل والأخطاء
  // ---------------------------------------------------------------------------
  String _getFriendlyErrorMessage(FirebaseFunctionsException e) {
    switch (e.code) {
      case "deadline-exceeded":
        return "انتهت مهلة الاتصال بالسيرفر بسبب ضعف الإنترنت، لم يتم تعديل أي بيانات في حسابك. يرجى إعادة المحاولة.";
      case "unauthenticated":
        return "انتهت جلسة تسجيل الدخول، يرجى إعادة تسجيل الدخول والمحاولة مرة أخرى.";
      case "invalid-argument":
        return "البيانات المرسلة غير صالحة، يرجى تحديث الصفحة.";
      case "not-found":
        return "لم يتم العثور على الطلب أو الحساب في سجلات النظام.";
      case "permission-denied":
        return "أنت لا تملك الصلاحية لإجراء هذه العملية.";
      case "failed-precondition":
        return e.message ??
            "تغيرت حالة الطلب على السيرفر ولم يعد قابلاً للتعديل.";
      case "internal":
        return "حدث خطأ داخلي في الخادم المالي، يرجى المحاولة لاحقاً.";
      default:
        return e.message ?? "حدث خطأ غير متوقع أثناء معالجة طلبك.";
    }
  }

  String _buildCustomSuccessMessage(
    int cancelledCount,
    int reviewCount,
    double refundedAmount,
  ) {
    if (cancelledCount > 0 && reviewCount > 0) {
      return refundedAmount > 0
          ? "تم إلغاء $cancelledCount منتج فوراً وإعادة ($refundedAmount) شيكل لمحفظتك، وتحويل $reviewCount منتج آخر للإدارة للمراجعة."
          : "تم إلغاء $cancelledCount منتج فوراً وتحديث الفاتورة، وتحويل $reviewCount منتج آخر للإدارة للمراجعة.";
    } else if (cancelledCount > 0) {
      return refundedAmount > 0
          ? "تم إلغاء المنتج بنجاح، وتم رد مبلغ ($refundedAmount) شيكل إلى محفظتك فوراً."
          : "تم إلغاء المنتج بنجاح وتحديث قيمة الفاتورة الإجمالية للطلب.";
    } else if (reviewCount > 0) {
      return "تم تقديم طلب الإلغاء لعدد $reviewCount منتج بنجاح، وهو قيد المراجعة حالياً من قِبل الإدارة.";
    }
    return "تمت معالجة تحديثات حالة المنتجات بنجاح.";
  }

  void _showWarningSnackBarByStatus(OrderStatus status) {
    String message = "هذا الطلب لم يعد في مرحلة الانتظار.";
    switch (status) {
      case OrderStatus.cancelled:
        message = "هذا الطلب ملغي بالفعل.";
        break;
      case OrderStatus.timeExpired:
        message = "هذا الطلب منتهي الصلاحية بسبب عدم سداد ثمنه.";
        break;
      case OrderStatus.processing:
        message =
            "هذا الطلب لم يعد في مرحلة الانتظار، لقد انتقل بالفعل إلى التجهيز.";
        break;
      case OrderStatus.accepted:
        message =
            "هذا الطلب لم يعد في مرحلة الانتظار، لقد تم بالفعل قبوله من المتاجر.";
        break;
      case OrderStatus.shipped:
        message =
            "هذا الطلب لم يعد في مرحلة الانتظار، لقد تم بالفعل شحنه من المتاجر.";
        break;
      case OrderStatus.delivered:
        message =
            "هذا الطلب لم يعد في مرحلة الانتظار، لقد تم بالفعل توصيله إليك.";
        break;
      case OrderStatus.refunded:
        message = "هذا الطلب ملغى من قبل المتاجر وتم إعادة ثمنه إلى المحفظة.";
        break;
      case OrderStatus.pendingPaymentApproval:
        message = "هذا الطلب بانتظار تأكيد الدفع من قبل الإدارة.";
        break;
      default:
        break;
    }
    TLoaders.warningSnackBar(title: "تعذر تقديم الطلب", message: message);
  }

  /*
  // ---------------------------------------------------------------------------
  // 1. دالة إلغاء الطلب بالكامل
  // ---------------------------------------------------------------------------
  Future<void> handleCancelOrderLogic(
    BuildContext context,
    OrderModel orderModel,
  ) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
      return;
    }

    if (orderModel.status != OrderStatus.pending &&
        orderModel.status != OrderStatus.pendingPayment) {
      String message =
          "هذا الطلب لم يعد في مرحلة الانتظار، لقد انتقل بالفعل إلى التجهيز أو الشحن.";
      switch (orderModel.status) {
        case OrderStatus.cancelled:
          message = "هذا الطلب ملغي بالفعل.";
          break;
        case OrderStatus.pendingPayment:
          message =
              "هذا الطلب سوف يتم إلغاؤه دون إعادة أي مبلغ لأنه لم يتم دفع ثمنه.";
          break;
        case OrderStatus.timeExpired:
          message = "هذا الطلب منتهي الصلاحية بسبب عدم سداد ثمنه.";
          break;
        case OrderStatus.pending:
          message = "هذا الطلب سوف يتم إلغاؤه وإعادة ثمنه إلى المحفظة.";
          break;
        case OrderStatus.processing:
          message =
              "هذا الطلب لم يعد في مرحلة الانتظار، لقد انتقل بالفعل إلى التجهيز.";
          break;
        case OrderStatus.accepted:
          message =
              "هذا الطلب لم يعد في مرحلة الانتظار، لقد تم بالفعل قبوله من المتاجر.";
          break;
        case OrderStatus.shipped:
          message =
              "هذا الطلب لم يعد في مرحلة الانتظار، لقد تم بالفعل شحنه من المتاجر.";
          break;
        case OrderStatus.delivered:
          message =
              "هذا الطلب لم يعد في مرحلة الانتظار، لقد تم بالفعل توصيله إليك.";
          break;
        case OrderStatus.refunded:
          message = "هذا الطلب ملغى من قبل المتاجر وتم إعادة ثمنه إلى المحفظة.";
          break;
        case OrderStatus.pendingPaymentApproval:
          message = "هذا الطلب بانتظار تأكيد الدفع من قبل الإدارة.";
          break;
      }
      TLoaders.warningSnackBar(title: "تعذر تقديم الطلب", message: message);
      return;
    }

    bool isDialogOpened = false;
    try {
      isCancelLoading.value = true;

      // إظهار الديلوج أولاً قبل بدء طلب الشبكة
      _showLoadingDialog(context);
      isDialogOpened = true;

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'cancelOrderAndRefund',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
      );

      final results = await callable.call(<String, dynamic>{
        'orderId': orderModel.id,
      });

      // إغلاق الديلوج فور انتهاء الطلب بنجاح وقبل تحديث البيانات
      if (isDialogOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogOpened = false;
      }

      if (results.data != null) {
        final resData = Map<String, dynamic>.from(results.data);
        final String status = resData['status'] ?? resData['Status'] ?? '';

        if (status == 'success') {
          orderModel = orderModel.copyWith(status: OrderStatus.cancelled);
          update();

          final refundedAmount =
              resData['refundedAmount'] ?? resData['refunded_amount'] ?? '0';

          TLoaders.successSnackBar(
            title: "تم إلغاء الطلب بنجاح",
            message:
                "تم إلغاء طلبك بنجاح واسترداد مبلغ ($refundedAmount .ILS) إلى محفظتك فوراً.",
          );
        }
      }
    } on FirebaseFunctionsException catch (e) {
      if (isDialogOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogOpened = false;
      }

      String friendlyMessage = "حدث خطأ غير متوقع أثناء معالجة طلبك.";
      switch (e.code) {
        case "unauthenticated":
          friendlyMessage =
              "انتهت جلسة تسجيل الدخول، يرجى إعادة تسجيل الدخول والمحاولة مرة أخرى.";
          break;
        case "invalid-argument":
          friendlyMessage = "البيانات المرسلة غير صالحة، يرجى تحديث الصفحة.";
          break;
        case "not-found":
          friendlyMessage =
              "لم يتم العثور على الطلب أو الحساب في سجلات النظام.";
          break;
        case "permission-denied":
          friendlyMessage = "أنت لا تملك الصلاحية لإلغاء هذا الطلب.";
          break;
        case "failed-precondition":
          friendlyMessage =
              e.message ??
              "تغيرت حالة الطلب على السيرفر ولم يعد قابلاً للإلغاء المباشر.";
          break;
        case "internal":
          friendlyMessage =
              "حدث خطأ داخلي في الخادم المالي، يرجى المحاولة لاحقاً.";
          break;
        default:
          friendlyMessage = e.message ?? friendlyMessage;
      }

      TLoaders.errorSnackBar(
        title: "فشلت عملية الإلغاء",
        message: friendlyMessage,
      );
    } catch (e) {
      if (isDialogOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogOpened = false;
      }
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
    } finally {
      isCancelLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. دالة إلغاء منتجات معينة من الطلب
  // ---------------------------------------------------------------------------
  Future<void> handleCancelSpecificItemsLogic({
    required BuildContext context,
    required OrderModel orderModel,
    required List<Map<String, dynamic>> itemsToCancel,
  }) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
      return;
    }

    if (itemsToCancel.isEmpty) {
      TLoaders.errorSnackBar(
        title: "عملية غير مكتملة",
        message: "يرجى تحديد منتج واحد على الأقل لتتمكن من تقديم الطلب.",
      );
      return;
    }

    bool isDialogOpened = false;
    try {
      isCancelLoading.value = true;

      _showLoadingDialog(context);
      isDialogOpened = true;

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'cancelSpecificItems',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 20)),
      );

      final results = await callable.call(<String, dynamic>{
        'orderId': orderModel.id,
        'itemsToCancel': itemsToCancel,
      });

      if (isDialogOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogOpened = false;
      }

      if (results.data != null) {
        final data = Map<String, dynamic>.from(results.data);
        final String status = data['status'] ?? data['Status'] ?? '';

        if (status == 'success') {
          final double refundedAmount =
              double.tryParse(data['refundedAmount'].toString()) ?? 0.0;
          final int cancelledCount = data['cancelledCount'] ?? 0;
          final int reviewCount = data['reviewCount'] ?? 0;

          String successMessage = "";
          if (cancelledCount > 0 && reviewCount > 0) {
            successMessage = refundedAmount > 0
                ? "تم إلغاء $cancelledCount منتج فوراً وإعادة ($refundedAmount) شيكل لمحفظتك، وتحويل $reviewCount منتج آخر للإدارة للمراجعة."
                : "تم إلغاء $cancelledCount منتج فوراً وتحديث الفاتورة، وتحويل $reviewCount منتج آخر للإدارة للمراجعة.";
          } else if (cancelledCount > 0) {
            successMessage = refundedAmount > 0
                ? "تم إلغاء المنتج بنجاح، وتم رد مبلغ ($refundedAmount) شيكل إلى محفظتك فوراً."
                : "تم إلغاء المنتج بنجاح وتحديث قيمة الفاتورة الإجمالية للطلب.";
          } else if (reviewCount > 0) {
            successMessage =
                "تم تقديم طلب الإلغاء/الإرجاع لعدد $reviewCount منتج بنجاح، وهو قيد المراجعة حالياً من قِبل الإدارة.";
          } else {
            successMessage = "تمت معالجة تحديثات حالة المنتجات بنجاح.";
          }

          TLoaders.successSnackBar(
            title: "تمت العملية بنجاح 🎉",
            message: successMessage,
          );
          update();
        }
      }
    } on FirebaseFunctionsException catch (e) {
      if (isDialogOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogOpened = false;
      }

      String friendlyMessage = "حدث خطأ غير متوقع أثناء معالجة طلبك.";
      switch (e.code) {
        case "unauthenticated":
          friendlyMessage =
              "انتهت جلسة تسجيل الدخول الخاصة بك، يرجى إعادة تسجيل الدخول والمحاولة مرة أخرى.";
          break;
        case "invalid-argument":
          friendlyMessage =
              "البيانات المرسلة غير صالحة، يرجى تحديث الصفحة والمحاولة مجدداً.";
          break;
        case "not-found":
          friendlyMessage =
              "تعذر العثور على مستندات الطلب أو الحساب المرتبط به في النظام.";
          break;
        case "permission-denied":
          friendlyMessage =
              "أنت لا تملك الصلاحية الأمنية الكافية لإجراء هذا التعديل على الطلب.";
          break;
        case "failed-precondition":
          friendlyMessage =
              e.message ??
              "تغيرت حالة المنتج على الخادم ولم يعد قابلاً للتعديل حالياً.";
          break;
        case "internal":
          friendlyMessage =
              "حدث خطأ داخلي في الخادم المالي، يرجى مراجعة الدعم الفني إن تكرر الخطأ.";
          break;
        default:
          friendlyMessage = e.message ?? friendlyMessage;
      }

      TLoaders.errorSnackBar(
        title: "فشلت عملية المعالجة",
        message: friendlyMessage,
      );
    } catch (e) {
      if (isDialogOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogOpened = false;
      }
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال 🌐",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت وتحديث الصفحة ثم المحاولة.",
      );
    } finally {
      isCancelLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. دالة رفع إيصال الدفع اليدوي
  // ---------------------------------------------------------------------------
  Future<void> uploadPaymentReceipt(
    BuildContext context,
    String orderId,
    String userId,
  ) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) {
      TLoaders.warningSnackBar(
        title: "تم إلغاء العملية",
        message: "لم يتم اختيار أي صورة للإيصال.",
      );
      return;
    }

    if (!context.mounted) return;

    bool isDialogOpened = false;
    try {
      isCancelLoading.value = true;

      _showLoadingDialog(context);
      isDialogOpened = true;

      final File file = File(image.path);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String storagePath =
          'Users/$userId/Orders/$orderId/receipt_$timestamp.jpg';

      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      final WriteBatch batch = _db.batch();
      final DocumentReference orderRef = _db.collection('Orders').doc(orderId);
      final DocumentReference paymentRequestRef = _db
          .collection('PaymentRequests')
          .doc(orderId);

      batch.update(orderRef, {
        'Status': OrderStatus.pendingPaymentApproval.name,
      });

      batch.set(paymentRequestRef, {
        'requestId': orderId,
        'orderId': orderId,
        'userId': userId,
        'receiptUrl': downloadUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'note': 'طلب تفعيل يدوي بموجب حوالة بنكية مرفقة.',
      });

      await batch.commit();

      if (isDialogOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogOpened = false;
      }

      TLoaders.successSnackBar(
        title: "تم رفع الإثبات بنجاح",
        message:
            "تم إرسال إيصال الدفع بنجاح، جاري مراجعته الآن لتفعيل طلبك من قبل الإدارة.",
      );
    } catch (e) {
      if (isDialogOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogOpened = false;
      }

      TLoaders.errorSnackBar(
        title: "فشلت العملية",
        message: "حدث خطأ غير متوقع أثناء معالجة الطلب: ${e.toString()}",
      );
    } finally {
      isCancelLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 4. الدالة المحسنة لإنشاء الديلوج المنفصل بدون تداخل مرجعي
  // ---------------------------------------------------------------------------
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator:
          true, // يضمن أن يفتح الديلوج على مستوى التطبيق بالكامل ولا يغلق بالخلفية
      builder: (BuildContext dialogContext) {
        return const PopScope(
          canPop: false, // يمنع إغلاق الديلوج عن طريق زر العودة في أندرويد
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      },
    );
  }

*/

  /*
  Future<void> handleCancelOrderLogic(
    BuildContext context,
    OrderModel orderModel,
  ) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
      return;
    }

    if (orderModel.status != OrderStatus.pending &&
        orderModel.status != OrderStatus.pendingPayment) {
      String message =
          "هذا الطلب لم يعد في مرحلة الانتظار، لقد انتقل بالفعل إلى التجهيز أو الشحن.";

      switch (orderModel.status) {
        case OrderStatus.cancelled:
          message = "هذا الطلب ملغي بالفعل.";
          break;
        case OrderStatus.pendingPayment:
          message =
              "هذا الطلب سوف يتم الغائه دون اعادة اي مبلغ لانه لم يتم دفع ثمنه.";
          break;
        case OrderStatus.timeExpired:
          message = "هذا الطلب منتهي الصلاحية وبسبب عدم سداد ثمنه.";
          break;
        case OrderStatus.pending:
          message = "هذا الطلب سوف يتم الغائه واعادة ثمنه الى المحفظة.";
          break;
        case OrderStatus.processing:
          message =
              "هذا الطلب لم يعد في مرحلة الانتظار، لقد انتقل بالفعل إلى التجهيز .";
          break;
        case OrderStatus.accepted:
          message =
              "هذا الطلب لم يعد في مرحلة الانتظار، لقد تم بالفعل قبوله من المتاجر .";
          break;
        case OrderStatus.shipped:
          message =
              "هذا الطلب لم يعد في مرحلة الانتظار، لقد تم بالفعل شحنه من المتاجر .";
          break;
        case OrderStatus.delivered:
          message =
              "هذا الطلب لم يعد في مرحلة الانتظار، لقد تم بالفعل توصيله اليك .";
          break;
        case OrderStatus.refunded:
          message =
              "هذا الطلب لم يعد في مرحلة الانتظار الطلب ملغى من قبل المتاجر وتم اعادة ثمنه الى المحفظة .";
          break;
        case OrderStatus.pendingPaymentApproval:
          message = "هذا الطلب بانتظار تاكيد الدفع من قبل الادارة.";
          break;
      }
      TLoaders.warningSnackBar(title: "تعذر تقديم الطلب", message: message);
      return;
    }

    BuildContext? dialogContext;
    try {
      isCancelLoading.value = true;
      _showLoadingDialog(context, onOpened: (ctx) => dialogContext = ctx);

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'cancelOrderAndRefund',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
      );

      final results = await callable.call(<String, dynamic>{
        'orderId': orderModel.id,
      });

      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }

      if (results.data != null) {
        final resData = Map<String, dynamic>.from(results.data);
        final String status = resData['status'] ?? resData['Status'] ?? '';

        if (status == 'success') {
          orderModel = orderModel.copyWith(status: OrderStatus.cancelled);
          update();

          final refundedAmount =
              resData['refundedAmount'] ?? resData['refunded_amount'] ?? '0';

          _showSuccessSnackbar(
            title: "تم إلغاء الطلب بنجاح",
            message:
                "تم إلغاء طلبك بنجاح واسترداد مبلغ ($refundedAmount .ILS) إلى محفظتك فوراً.",
          );
        }
      }
    } on FirebaseFunctionsException catch (e) {
      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }

      String friendlyMessage = "حدث خطأ غير متوقع أثناء معالجة طلبك.";
      switch (e.code) {
        case "unauthenticated":
          friendlyMessage =
              "انتهت جلسة تسجيل الدخول، يرجى إعادة تسجيل الدخول والمحاولة مرة أخرى.";
          break;
        case "invalid-argument":
          friendlyMessage = "البيانات المرسلة غير صالحة، يرجى تحديث الصفحة.";
          break;
        case "not-found":
          friendlyMessage =
              "لم يتم العثور على الطلب أو الحساب في سجلات النظام.";
          break;
        case "permission-denied":
          friendlyMessage =
              "أنت لا تملك الصلاحية لإلغاء هذا الطلب (الطلب لا يخص حسابك).";
          break;
        case "failed-precondition":
          friendlyMessage =
              e.message ??
              "تغيرت حالة الطلب على السيرفر ولم يعد قابلاً للإلغاء المباشر.";
          break;
        case "internal":
          friendlyMessage =
              "حدث خطأ داخلي في الخادم المالي، يرجى المحاولة لاحقاً.";
          break;
        default:
          friendlyMessage = e.message ?? friendlyMessage;
      }

      TLoaders.errorSnackBar(
        title: "فشلت عملية الإلغاء",
        message: friendlyMessage,
      );
    } catch (e) {
      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
    } finally {
      isCancelLoading.value = false;
    }
  }

  Future<void> handleCancelSpecificItemsLogic({
    required BuildContext context,
    required OrderModel orderModel,
    required List<Map<String, dynamic>> itemsToCancel,
  }) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
      return;
    }

    if (itemsToCancel.isEmpty) {
      TLoaders.errorSnackBar(
        title: "عملية غير مكتملة",
        message: "يرجى تحديد منتج واحد على الأقل لتتمكن من تقديم الطلب.",
      );
      return;
    }

    BuildContext? dialogContext;
    try {
      isCancelLoading.value = true;
      _showLoadingDialog(context, onOpened: (ctx) => dialogContext = ctx);

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'cancelSpecificItems',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 20)),
      );

      final results = await callable.call(<String, dynamic>{
        'orderId': orderModel.id,
        'itemsToCancel': itemsToCancel,
      });

      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }

      if (results.data != null) {
        final data = Map<String, dynamic>.from(results.data);
        final String status = data['status'] ?? data['Status'] ?? '';

        if (status == 'success') {
          final double refundedAmount =
              double.tryParse(data['refundedAmount'].toString()) ?? 0.0;
          final int cancelledCount = data['cancelledCount'] ?? 0;
          final int reviewCount = data['reviewCount'] ?? 0;

          String successMessage = "";

          if (cancelledCount > 0 && reviewCount > 0) {
            successMessage = refundedAmount > 0
                ? "تم إلغاء $cancelledCount منتج فوراً وإعادة ($refundedAmount) شيكل لمحفظتك، وتحويل $reviewCount منتج آخر للإدارة للمراجعة."
                : "تم إلغاء $cancelledCount منتج فوراً وتحديث الفاتورة، وتحويل $reviewCount منتج آخر للإدارة للمراجعة.";
          } else if (cancelledCount > 0) {
            successMessage = refundedAmount > 0
                ? "تم إلغاء المنتج بنجاح، وتم رد مبلغ ($refundedAmount) شيكل إلى محفظتك فوراً."
                : "تم إلغاء المنتج بنجاح وتحديث قيمة الفاتورة الإجمالية للطلب.";
          } else if (reviewCount > 0) {
            successMessage =
                "تم تقديم طلب الإلغاء/الإرجاع لعدد $reviewCount منتج بنجاح، وهو قيد المراجعة حالياً من قِبل الإدارة.";
          } else {
            successMessage = "تمت معالجة تحديثات حالة المنتجات بنجاح.";
          }

          _showSuccessSnackbar(
            title: "تمت العملية بنجاح 🎉",
            message: successMessage,
          );
          update();
        }
      }
    } on FirebaseFunctionsException catch (e) {
      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }

      String friendlyMessage = "حدث خطأ غير متوقع أثناء معالجة طلبك.";
      switch (e.code) {
        case "unauthenticated":
          friendlyMessage =
              "انتهت جلسة تسجيل الدخول الخاصة بك، يرجى إعادة تسجيل الدخول والمحاولة مرة أخرى.";
          break;
        case "invalid-argument":
          friendlyMessage =
              "البيانات المرسلة غير صالحة، يرجى تحديث الصفحة والمحاولة مجدداً.";
          break;
        case "not-found":
          friendlyMessage =
              "تعذر العثور على مستندات الطلب أو الحساب المرتبط به في النظام.";
          break;
        case "permission-denied":
          friendlyMessage =
              "أنت لا تملك الصلاحية الأمنية الكافية لإجراء هذا التعديل على الطلب.";
          break;
        case "failed-precondition":
          friendlyMessage =
              e.message ??
              "تغيرت حالة المنتج على الخادم ولم يعد قابلاً للتعديل حالياً.";
          break;
        case "internal":
          friendlyMessage =
              "حدث خطأ داخلي في الخادم المالي، يرجى مراجعة الدعم الفني إن تكرر الخطأ.";
          break;
        default:
          friendlyMessage = e.message ?? friendlyMessage;
      }

      TLoaders.errorSnackBar(
        title: "فشلت عملية المعالجة",
        message: friendlyMessage,
      );
    } catch (e) {
      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال 🌐",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت وتحديث الصفحة ثم المحاولة.",
      );
    } finally {
      isCancelLoading.value = false;
    }
  }

  Future<void> uploadPaymentReceipt(
    BuildContext context,
    String orderId,
    String userId,
  ) async {
    // 1. فحص الاتصال بالإنترنت أولاً
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
      return;
    }

    // 2. اختيار الصورة قبل إظهار الديلوج (حتى لا يعلق الديلوج أثناء اختيار العميل)
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) {
      TLoaders.warningSnackBar(
        title: "تم إلغاء العملية",
        message: "لم يتم اختيار أي صورة للإيصال.",
      );
      return;
    }

    // تأمين صلب: تحقق أن الشاشة لا تزال مفتوحة قبل المتابعة لإظهار الديلوج
    if (!context.mounted) return;

    BuildContext? dialogContext;
    try {
      isCancelLoading.value = true;

      // إظهار الديلوج وحفظ السيرفر كونتكس الخاص به فوراً
      _showLoadingDialog(context, onOpened: (ctx) => dialogContext = ctx);

      final File file = File(image.path);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String storagePath =
          'Users/$userId/Orders/$orderId/receipt_$timestamp.jpg';

      // 3. رفع الصورة إلى الـ Storage
      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // 4. تجهيز العمليات في الـ Batch لـ Firestore
      final WriteBatch batch = _db.batch();
      final DocumentReference orderRef = _db.collection('Orders').doc(orderId);
      final DocumentReference paymentRequestRef = _db
          .collection('PaymentRequests')
          .doc(orderId);

      batch.update(orderRef, {
        'Status': OrderStatus.pendingPaymentApproval.name,
      });

      batch.set(paymentRequestRef, {
        'requestId': orderId,
        'orderId': orderId,
        'userId': userId,
        'receiptUrl': downloadUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'note': 'طلب تفعيل يدوي بموجب حوالة بنكية مرفقة.',
      });

      // تنفيذ الـ Batch وتأكيد البيانات في قاعدة البيانات
      await batch.commit();

      // 5. إغلاق الديلوج بأمان تام بعد التأكد من تدميره وحالة الـ mounted
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      } else if (context.mounted) {
        Navigator.of(context).pop(); // كخيار احتياطي لو فشل الأول
      }

      TLoaders.successSnackBar(
        title: "تم رفع الإثبات بنجاح",
        message:
            "تم إرسال إيصال الدفع بنجاح، جاري مراجعته الآن لتفعيل طلبك من قبل الإدارة.",
      );
    } catch (e) {
      // إغلاق الديلوج في حالة حدوث خطأ أثناء الرفع أو التخزين
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      } else if (context.mounted) {
        // فحص أمان إضافي لإغلاق الأوفرلاي المفتوح
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }

      // console.error("🔥 UPLOAD RECEIPT ERROR: ", e);
      TLoaders.errorSnackBar(
        title: "فشلت العملية",
        message: "حدث خطأ غير متوقع أثناء معالجة الطلب: ${e.toString()}",
      );
    } finally {
      isCancelLoading.value = false;
    }
  }

  void _showLoadingDialog(
    BuildContext context, {
    required Function(BuildContext) onOpened,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // استخدام الفريم المباشر دون تأخير لتمرير الـ Context الصحيح للديلوج نفسه
        onOpened(dialogContext);

        return const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      },
    );
  }

*/

  /*
  Future<void> uploadPaymentReceipt(
    BuildContext context,
    String orderId,
    String userId,
  ) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
      return;
    }

    BuildContext? dialogContext;
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) {
        TLoaders.warningSnackBar(
          title: "تم إلغاء العملية",
          message: "لم يتم اختيار أي صورة للإيصال.",
        );
        return;
      }

      isCancelLoading.value = true;
      _showLoadingDialog(context, onOpened: (ctx) => dialogContext = ctx);

      final File file = File(image.path);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String storagePath =
          'Users/$userId/Orders/$orderId/receipt_$timestamp.jpg';

      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putFile(file);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      final WriteBatch batch = _db.batch();
      final DocumentReference orderRef = _db.collection('Orders').doc(orderId);
      final DocumentReference paymentRequestRef = _db
          .collection('PaymentRequests')
          .doc(orderId);

      batch.update(orderRef, {
        'Status': OrderStatus.pendingPaymentApproval.name,
      });

      batch.set(paymentRequestRef, {
        'requestId': orderId,
        'orderId': orderId,
        'userId': userId,
        'receiptUrl': downloadUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'note': 'طلب تفعيل يدوي بموجب حوالة بنكية مرفقة.',
      });

      await batch.commit();

      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }

      TLoaders.successSnackBar(
        title: "تم رفع الإثبات بنجاح",
        message:
            "تم إرسال إيصال الدفع بنجاح، جاري مراجعته الآن لتفعيل طلبك من قبل الإدارة.",
      );
    } catch (e) {
      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }
      TLoaders.errorSnackBar(
        title: "فشلت العملية",
        message: "حدث خطأ غير متوقع أثناء معالجة الطلب: ${e.toString()}",
      );
    } finally {
      isCancelLoading.value = false;
    }
  }
*/
  /*
  void _showLoadingDialog(
    BuildContext context, {
    required Function(BuildContext) onOpened,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onOpened(dialogContext);
        });

        return const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      },
    );
  }
*/
  /*
  Future<void> handleCancelOrderLogic(
    BuildContext context,
    OrderModel orderModel,
  ) async {
    // ==========================================
    // أولاً: التحقق المسبق محلياً (Local Pre-checks)
    // ==========================================
    final isConected = await NetworkManager.instance.isConnected();
    if (!isConected) {
      //TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
    }

    // 1. فحص حالة الطلب الكلية محلياً
    if (orderModel.status != OrderStatus.pending &&
        orderModel.status != OrderStatus.pendingPayment) {
      var message =
          "هذا الطلب لم يعد في مرحلة الانتظار، لقد انتقل بالفعل إلى التجهيز أو الشحن.";

      switch (orderModel.status) {
        case OrderStatus.cancelled:
          message = "هذا الطلب ملغي بالفعل.";
          break;
        case OrderStatus.pendingPayment:
          "هذا الطلب سوف يتم الغائه دون اعادة اي مبلغ لانه لم يتم دفع ثمنه. ";
        case OrderStatus.timeExpired:
          "هذا الطلب منتهي الصلاحية وبسبب عدم سداد ثمنه.";
        case OrderStatus.pending:
          "هذا الطلب سوف يتم الغائه واعادة ثمنه الى المحفظة.";
        case OrderStatus.processing:
          "هذا الطلب لم يعد في مرحلة الانتظار، لقد انتقل بالفعل إلى التجهيز .";
        case OrderStatus.accepted:
          "هذا الطلب لم يعد في مرحلة الانتظار، لقد تم بالفعل  قبوله من المتاجر .";
        case OrderStatus.shipped:
          "هذا الطلب لم يعد في مرحلة الانتظار، لقد تم بالفعل  شحنه من المتاجر .";
        case OrderStatus.delivered:
          "هذا الطلب لم يعد في مرحلة الانتظار، لقد تم بالفعل  توصيله اليك  .";
        case OrderStatus.refunded:
          "هذا الطلب لم يعد في مرحلة الانتظار الطلب ملغى من قبل المتاجر وتم اعادة ثمنه الى المحفظة  .";
        case OrderStatus.pendingPaymentApproval:
          "هذا الطلب بانتظار تاكيد الدفع من قبل الادارة.";
      }
      ;
      TLoaders.warningSnackBar(title: "تعذر تقديم الطلب", message: message);
      return;
    }

    // 2. فحص حالة المنتجات بداخل الطلب محلياً
    bool isAnyProductProcessedLocally = orderModel.items.any(
      (item) => item.itemStatus != ItemStatus.pending,
    );

    /*if (isAnyProductProcessedLocally) {
      TLoaders.warningSnackBar(
        title: "تعذر الإلغاء تلقائياً",
        message:
            "قام أحد المتاجر بالموافقة على منتج أو تجهيزه بداخل الطلب، يرجى التواصل مع الدعم الفني.",
      );
      return;
    }*/

    // ==========================================
    // ثانياً: استدعاء الـ Cloud Function ومعالجة الأخطاء
    // ==========================================
    BuildContext? dialogContext;
    try {
      isCancelLoading.value = true;
      _showLoadingDialog(context, onOpened: (ctx) => dialogContext = ctx);

      // استدعاء الدالة السحابية بالتنسيق v2 الحديث
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'cancelOrderAndRefund',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
      );

      // تمرير البيانات المطلوبة للدالة (orderId)
      final results = await callable.call(<String, dynamic>{
        'orderId': orderModel.id,
      });

      // ✅ إغلاق دايالوج الانتظار فوراً عند النجاح باستخدام سياقه الخاص
      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }

      // استقبال رد السيرفر الناجح (تأمين قراءة الحقل بالحالتين الكابيتال والسمول)
      if (results.data != null) {
        final resData = Map<String, dynamic>.from(results.data);
        final String status = resData['status'] ?? resData['Status'] ?? '';

        if (status == 'success') {
          // تحديث حالة الطلب محلياً ليتغير الـ UI فوراً أمام العميل
          orderModel = orderModel.copyWith(status: OrderStatus.cancelled);
          update(); // تحديث القوائم المراقبة

          // تأمين جلب قيمة المبلغ المسترد والتعامل معه كـ String آمن
          final refundedAmount =
              resData['refundedAmount'] ?? resData['refunded_amount'] ?? '0';

          _showSuccessSnackbar(
            title: "تم إلغاء الطلب بنجاح",
            message:
                "تم إلغاء طلبك بنجاح واسترداد مبلغ ($refundedAmount .ILS) إلى محفظتك فوراً.",
          );
        }
      }
    } on FirebaseFunctionsException catch (e) {
      // ❌ إغلاق الدايالوج فوراً في حالة خطأ السيرفر
      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }

      String friendlyMessage = "حدث خطأ غير متوقع أثناء معالجة طلبك.";

      switch (e.code) {
        case "unauthenticated":
          friendlyMessage =
              "انتهت جلسة تسجيل الدخول، يرجى إعادة تسجيل الدخول والمحاولة مرة أخرى.";
          break;
        case "invalid-argument":
          friendlyMessage = "البيانات المرسلة غير صالحة، يرجى تحديث الصفحة.";
          break;
        case "not-found":
          friendlyMessage =
              "لم يتم العثور على الطلب أو الحساب في سجلات النظام.";
          break;
        case "permission-denied":
          friendlyMessage =
              "أنت لا تملك الصلاحية لإلغاء هذا الطلب (الطلب لا يخص حسابك).";
          break;
        case "failed-precondition":
          friendlyMessage =
              e.message ??
              "تغيرت حالة الطلب على السيرفر ولم يعد قابلاً للإلغاء المباشر.";
          break;
        case "internal":
          friendlyMessage =
              "حدث خطأ داخلي في الخادم المالي، يرجى المحاولة لاحقاً.";
          break;
        default:
          friendlyMessage = e.message ?? friendlyMessage;
      }

      TLoaders.errorSnackBar(
        title: "فشلت عملية الإلغاء",
        message: friendlyMessage,
      );
    } catch (e) {
      // التقاط أي أخطاء عامة أخرى
      // ❌ إغلاق الدايالوج فوراً في حالة أي خطأ عام آخر
      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
    } finally {
      isCancelLoading.value = false;
    }
  }

  Future<void> handleCancelSpecificItemsLogic({
    required BuildContext context,
    required OrderModel orderModel,
    required List<Map<String, dynamic>>
    itemsToCancel, // تم التحديث ليتوافق مع هيكل الفاريشن الجديد
  }) async {
    // ==========================================
    // أولاً: التحقق المسبق محلياً (Local Pre-checks)
    // ==========================================

    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
      return; // إنهاء الدالة فوراً منعاً لفتح الدايالوج بدون إنترنت
    }

    if (itemsToCancel.isEmpty) {
      TLoaders.errorSnackBar(
        title: "عملية غير مكتملة",
        message: "يرجى تحديد منتج واحد على الأقل لتتمكن من تقديم الطلب.",
      );
      return;
    }

    // ==========================================
    // ثانياً: استدعاء الـ Cloud Function ومعالجة النتائج
    // ==========================================

    // سنحتفظ بسياق الدايالوج هنا لإغلاقه بدقة من أي مكان بداخل الـ try-catch
    BuildContext? dialogContext;

    try {
      isCancelLoading.value = true;

      // فتح الدايالوج وتخزين الـ Context الخاص به
      _showLoadingDialog(context, onOpened: (ctx) => dialogContext = ctx);

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'cancelSpecificItems',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 20)),
      );

      final results = await callable.call(<String, dynamic>{
        'orderId': orderModel.id,
        'itemsToCancel':
            itemsToCancel, // التحديث المزدوج للمعرفات (productId + variationId)
      });

      // ✅ إغلاق دايالوج الانتظار فوراً عند النجاح باستخدام سياقه الخاص
      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }

      if (results.data != null) {
        final data = Map<String, dynamic>.from(results.data);
        final String status = data['status'] ?? data['Status'] ?? '';

        if (status == 'success') {
          final double refundedAmount =
              double.tryParse(data['refundedAmount'].toString()) ?? 0.0;
          final int cancelledCount = data['cancelledCount'] ?? 0;
          final int reviewCount = data['reviewCount'] ?? 0;

          String successMessage = "";

          if (cancelledCount > 0 && reviewCount > 0) {
            successMessage = refundedAmount > 0
                ? "تم إلغاء $cancelledCount منتج فوراً وإعادة ($refundedAmount) شيكل لمحفظتك، وتحويل $reviewCount منتج آخر للإدارة للمراجعة."
                : "تم إلغاء $cancelledCount منتج فوراً وتحديث الفاتورة، وتحويل $reviewCount منتج آخر للإدارة للمراجعة.";
          } else if (cancelledCount > 0) {
            successMessage = refundedAmount > 0
                ? "تم إلغاء المنتج بنجاح، وتم رد مبلغ ($refundedAmount) شيكل إلى محفظتك فوراً."
                : "تم إلغاء المنتج بنجاح وتحديث قيمة الفاتورة الإجمالية للطلب.";
          } else if (reviewCount > 0) {
            successMessage =
                "تم تقديم طلب الإلغاء/الإرجاع لعدد $reviewCount منتج بنجاح، وهو قيد المراجعة حالياً من قِبل الإدارة.";
          } else {
            successMessage = "تمت معالجة تحديثات حالة المنتجات بنجاح.";
          }

          _showSuccessSnackbar(
            title: "تمت العملية بنجاح 🎉",
            message: successMessage,
          );

          update(); // تحديث الـ UI الخاص بـ GetX / Bloc
        }
      }
    } on FirebaseFunctionsException catch (e) {
      // ❌ إغلاق الدايالوج فوراً في حالة خطأ السيرفر
      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }

      String friendlyMessage = "حدث خطأ غير متوقع أثناء معالجة طلبك.";

      switch (e.code) {
        case "unauthenticated":
          friendlyMessage =
              "انتهت جلسة تسجيل الدخول الخاصة بك، يرجى إعادة تسجيل الدخول والمحاولة مرة أخرى.";
          break;
        case "invalid-argument":
          friendlyMessage =
              "البيانات المرسلة غير صالحة، يرجى تحديث الصفحة والمحاولة مجدداً.";
          break;
        case "not-found":
          friendlyMessage =
              "تعذر العثور على مستندات الطلب أو الحساب المرتبط به في النظام.";
          break;
        case "permission-denied":
          friendlyMessage =
              "أنت لا تملك الصلاحية الأمنية الكافية لإجراء هذا التعديل على الطلب.";
          break;
        case "failed-precondition":
          friendlyMessage =
              e.message ??
              "تغيرت حالة المنتج على الخادم ولم يعد قابلاً للتعديل حالياً.";
          break;
        case "internal":
          friendlyMessage =
              "حدث خطأ داخلي في الخادم المالي، يرجى مراجعة الدعم الفني إن تكرر الخطأ.";
          break;
        default:
          friendlyMessage = e.message ?? friendlyMessage;
      }

      TLoaders.errorSnackBar(
        title: "فشلت عملية المعالجة",
        message: friendlyMessage,
      );
    } catch (e) {
      // ❌ إغلاق الدايالوج فوراً في حالة أي خطأ عام آخر
      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }

      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال 🌐",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت وتحديث الصفحة ثم المحاولة.",
      );
    } finally {
      isCancelLoading.value = false;
    }
  }

  // دايالوج الانتظار الشفاف والمُطور لالتقاط الـ Context الفرعي فور بنائه
  void _showLoadingDialog(
    BuildContext context, {
    required Function(BuildContext) onOpened,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // تمرير سياق الدايالوج الجديد فوراً إلى الدالة الرئيسية للاحتفاظ به
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onOpened(dialogContext);
        });

        return const PopScope(
          canPop:
              false, // منع المستخدم من إغلاقه يدوياً عبر زر الرجوع الخلفي للهاتف
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      },
    );
  }

  // دالة اختيار ورفع الإيصال وتحديث البيانات
  Future<void> uploadPaymentReceipt(
    BuildContext context,
    String orderId,
    String userId,
  ) async {
    BuildContext? dialogContext;
    try {
      // 1. اختيار الصورة مع تقليل الجودة لسرعة الرفع وتوفير الباقة
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality:
            70, // 70% مثالية جداً للاستمارات والإيصالات دون فقدان الوضوح
      );

      if (image == null) {
        TLoaders.warningSnackBar(
          title: "تم إلغاء العملية",
          message: "لم يتم اختيار أي صورة للإيصال.",
        );
        return;
      }

      // تشغيل الـ Overlay Loader فوراً لحظر واجهة المستخدم أثناء العمليات الحرجة
      isCancelLoading.value = true;
      _showLoadingDialog(context, onOpened: (ctx) => dialogContext = ctx);

      // 2. رفع الملف إلى Firebase Storage مع تسمية ديناميكية فريدة باستخدام الـ Timestamp
      final File file = File(image.path);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String storagePath =
          'Users/$userId/Orders/$orderId/receipt_$timestamp.jpg';

      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putFile(file);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // 3. الاستعانة بالـ WriteBatch لضمان أمان البيانات (Atomic Write)
      final WriteBatch batch = _db.batch();

      final DocumentReference orderRef = _db.collection('Orders').doc(orderId);
      final DocumentReference paymentRequestRef = _db
          .collection('PaymentRequests')
          .doc(orderId);

      // تحديث الطلب الأصلي (تأكد من وجود pendingPaymentApproval في الـ OrderStatus Enum الخاص بك)
      batch.update(orderRef, {
        'Status': OrderStatus.pendingPaymentApproval.name,
      });

      // إنشاء طلب المراجعة للآدمن
      batch.set(paymentRequestRef, {
        'requestId': orderId,
        'orderId': orderId,
        'userId': userId,
        'receiptUrl': downloadUrl,
        'status': 'pending', // pending, approved, rejected
        'createdAt': FieldValue.serverTimestamp(),
        'note': 'طلب تفعيل يدوي بموجب حوالة بنكية مرفقة.',
      });

      // تنفيذ الـ Batch دفعة واحدة في السيرفر
      await batch.commit();

      isCancelLoading.value = false; // إغلاق اللودر
      TLoaders.successSnackBar(
        title: "تم رفع الإثبات بنجاح",
        message:
            "تم إرسال إيصال الدفع بنجاح، جاري مراجعته الآن لتفعيل طلبك من قبل الإدارة.",
      );
    } catch (e) {
      isCancelLoading.value =
          false; // التأكد من إغلاق اللودر في حالة الخطأ لعدم تجميد التطبيق
      TLoaders.errorSnackBar(
        title: "فشلت العملية",
        message: "حدث خطأ غير متوقع أثناء معالجة الطلب: ${e.toString()}",
      );
    }
  }
*/
  /*
  Future<void> uploadPaymentReceipt(String orderId, String userId) async {
    try {
      // 1. اختيار الصورة من المعرض
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        TLoaders.warningSnackBar(
          title: "تم إلغاء العملية",
          message: "لم يتم اختيار أي صورة للإيصال.",
        );
        return;
      }

      // إظهار مؤشر التحميل للمستخدم
      //TLoaders.showLoadingOverlay(); // استدعاء دالة التحميل الخاصة بك

      // 2. رفع الصورة إلى Firebase Storage
      File file = File(image.path);
      String storagePath = 'Users/$userId/Orders/$orderId/payment_receipt.jpg';
      Reference ref = _storage.ref().child(storagePath);

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 3. تحديث حالة الطلب الأصلي في قاعدة البيانات ليكون تحت المراجعة
      await _db.collection('Orders').doc(orderId).update({
        'status': OrderStatus.pendingPaymentApproval.name,
      });

      // 4. إنشاء مستند طلب مراجعة مخصص لتطبيق الإدارة (Admin App)
      // نضعها في مجموعة منفصلة باسم "PaymentRequests" ليسهل على الآدمن فلترتها ومتابعتها فوراً
      await _db.collection('PaymentRequests').doc(orderId).set({
        'requestId': orderId, // نستخدم نفس رقم الطلب لسهولة الربط
        'orderId': orderId,
        'userId': userId,
        'receiptUrl': downloadUrl,
        'status': 'pending', // pending, approved, rejected
        'createdAt': FieldValue.serverTimestamp(),
        'note': 'طلب تفعيل يدوي بالرغم من الدفع من قبل المستخدم.',
      });

      // إغلاق لودر التحميل
      //TLoaders.stopLoading();

      // تنبيه بالنجاح
      TLoaders.successSnackBar(
        title: "تم رفع الإثبات",
        message:
            "تم إرسال إيصال الدفع بنجاح، جاري مراجعته الآن لتفعيل طلبك من قبل الإدارة.",
      );
    } catch (e) {
      //TLoaders.stopLoading();
      TLoaders.errorSnackBar(title: "خطأ في الرفع", message: e.toString());
    }
  }
*/
  /*
  Future<void> handleCancelSpecificItemsLogic({
    required BuildContext context,
    required OrderModel orderModel,
    required List<Map<String, dynamic>> itemIdsToCancel,
  }) async {
    // ==========================================
    // أولاً: التحقق المسبق محلياً (Local Pre-checks)
    // ==========================================

    final isConected = await NetworkManager.instance.isConnected();
    if (!isConected) {
      //TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
    }

    if (itemIdsToCancel.isEmpty) {
      TLoaders.errorSnackBar(
        title: "عملية غير مكتملة",
        message: "يرجى تحديد منتج واحد على الأقل لتتمكن من تقديم الطلب.",
      );
      return;
    }

    // ==========================================
    // ثانياً: استدعاء الـ Cloud Function ومعالجة النتائج
    // ==========================================
    bool isDialogOpened = false;

    try {
      isCancelLoading.value = true;
      _showLoadingDialog(context);
      isDialogOpened = true;

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'cancelSpecificItems',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 20)),
      );

      final results = await callable.call(<String, dynamic>{
        'orderId': orderModel.id,
        'itemIdsToCancel': itemIdsToCancel,
      });

      // إغلاق دايالوج الانتظار فوراً بأمان
      if (isDialogOpened) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogOpened = false;
      }

      if (results.data != null) {
        final data = Map<String, dynamic>.from(results.data);
        final String status = data['status'] ?? data['Status'] ?? '';

        if (status == 'success') {
          final double refundedAmount =
              double.tryParse(data['refundedAmount'].toString()) ?? 0.0;
          final int cancelledCount = data['cancelledCount'] ?? 0;
          final int reviewCount = data['reviewCount'] ?? 0;

          String successMessage = "";

          if (cancelledCount > 0 && reviewCount > 0) {
            successMessage =
                "تم إلغاء $cancelledCount منتج فوراً وإعادة ($refundedAmount) شيكل لمحفظتك، وتحويل $reviewCount منتج آخر للإدارة للمراجعة.";
          } else if (cancelledCount > 0) {
            successMessage =
                "تم إلغاء المنتج بنجاح، وتم رد مبلغ ($refundedAmount) شيكل إلى محفظتك فوراً.";
          } else if (reviewCount > 0) {
            successMessage =
                "تم تقديم طلب الإلغاء/الإرجاع لعدد $reviewCount منتج بنجاح، وهو قيد المراجعة حالياً من قِبل الإدارة.";
          } else {
            successMessage = "تمت معالجة تحديثات حالة المنتجات بنجاح.";
          }

          _showSuccessSnackbar(
            title: "تمت العملية بنجاح 🎉",
            message: successMessage,
          );

          update(); // تحديث الـ UI
        }
      }
    } on FirebaseFunctionsException catch (e) {
      if (isDialogOpened) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogOpened = false;
      }

      String friendlyMessage = "حدث خطأ غير متوقع أثناء معالجة طلبك.";

      switch (e.code) {
        case "unauthenticated":
          friendlyMessage =
              "انتهت جلسة تسجيل الدخول الخاصة بك، يرجى إعادة تسجيل الدخول والمحاولة مرة أخرى.";
          break;
        case "invalid-argument":
          friendlyMessage =
              "البيانات المرسلة غير صالحة أو مشوهة، يرجى تحديث الصفحة والمحاولة مجدداً.";
          break;
        case "not-found":
          friendlyMessage =
              "تعذر العثور على مستندات الطلب أو الحساب المرتبط به في سجلات السيرفر الكلية.";
          break;
        case "permission-denied":
          friendlyMessage =
              "أنت لا تملك الصلاحية الأمنية الكافية لإجراء هذا التعديل على الطلب المحدَد.";
          break;
        case "failed-precondition":
          friendlyMessage =
              e.message ??
              "تغيرت حالة المنتج على الخادم ولم يعد قابلاً للطلب أو التعديل الفوري حالياً.";
          break;
        case "internal":
          friendlyMessage =
              "حدث خطأ داخلي في معالجات الخادم المالي، يرجى مراجعة الدعم الفني إن تكرر الخطأ.";
          break;
        default:
          friendlyMessage = e.message ?? friendlyMessage;
      }

      TLoaders.errorSnackBar(
        title: "فشلت عملية المعالجة",
        message: friendlyMessage,
      );
    } catch (e) {
      if (isDialogOpened) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogOpened = false;
      }
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال 🌐",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت وتحديث الصفحة ثم المحاولة.",
      );
    } finally {
      isCancelLoading.value = false;
    }
  }

  // دايالوج الانتظار الشفاف والمؤمن بـ BuildContext لمنع التجمد
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const PopScope(
          canPop: false, // منع المستخدم من إغلاقه عبر زر الرجوع في الهاتف
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      },
    );
  }
*/
  /*
  Future<void> handleCancelOrderLogic(
    BuildContext context,
    OrderModel orderModel,
  ) async {
    // ==========================================
    // أولاً: التحقق المسبق محلياً (Local Pre-checks)
    // ==========================================

    // 1. فحص اتصال الإنترنت
    // يمكنك دمج مكتبة connectivity_plus هنا، سأضع فحصاً مبدئياً

    // 2. فحص حالة الطلب الكلية محلياً
    if (orderModel.status != OrderStatus.pending &&
        orderModel.status != OrderStatus.pendingPayment) {
      TLoaders.warningSnackBar(
        title: "تعذر تقديم الطلب",
        message:
            "هذا الطلب لم يعد في مرحلة الانتظار، لقد انتقل بالفعل إلى التجهيز أو الشحن.",
      );
      return; // وقف التنفيذ فوراً دون استدعاء السيرفر
    }

    // 3. فحص حالة المنتجات بداخل الطلب محلياً
    bool isAnyProductProcessedLocally = orderModel.items.any(
      (item) => item.itemStatus != ItemStatus.pending,
    );

    if (isAnyProductProcessedLocally) {
      TLoaders.warningSnackBar(
        title: "تعذر الإلغاء تلقائياً",
        message:
            "قام أحد المتاجر بالموافقة على منتج أو تجهيزه بداخل الطلب، يرجى التواصل مع الدعم الفني.",
      );
      return; // وقف التنفيذ
    }

    // ==========================================
    // ثانياً: استدعاء الـ Cloud Function ومعالجة الأخطاء
    // ==========================================
    try {
      isCancelLoading.value = true;
      _showLoadingDialog(); // فتح مؤشر الانتظار

      // استدعاء الدالة السحابية بالتنسيق v2 الحديث
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'cancelOrderAndRefund',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
      );

      // تمرير البيانات المطلوبة للدالة (orderId)
      final results = await callable.call(<String, dynamic>{
        'orderId': orderModel.id,
      });

      // إغلاق دايالوج الانتظار فوراً عند نجاح العملية
      if (Get.isDialogOpen ?? false) Get.back();

      // استقبال رد السيرفر الناجح
      if (results.data != null && results.data['status'] == 'success') {
        // تحديث حالة الطلب محلياً ليتغير الـ UI فوراً أمام العميل
        orderModel = orderModel.copyWith(status: OrderStatus.cancelled);
        update(); // إذا كنت تستخدم GetBuilder أو لتحديث القوائم المراقبة

        _showSuccessSnackbar(
          title: "تم إلغاء الطلب بنجاح",
          message:
              "تم إلغاء طلبك واسترداد مبلغ (${results.data['refundedAmount']} .ILS) إلى محفظتك فوراً.",
        );
      }
    } on FirebaseFunctionsException catch (e) {
      // إغلاق دايالوج الانتظار عند حدوث خطأ من السيرفر
      if (Get.isDialogOpen ?? false) Get.back();

      // تفكيك أخطاء السيرفر بناءً على الـ Code المحدد في الـ Cloud Function
      String friendlyMessage = "حدث خطأ غير متوقع أثناء معالجة طلبك.";

      switch (e.code) {
        case "unauthenticated":
          friendlyMessage =
              "انتهت جلسة تسجيل الدخول، يرجى إعادة تسجيل الدخول والمحاولة مرة أخرى.";
          break;
        case "invalid-argument":
          friendlyMessage = "البيانات المرسلة غير صالحة، يرجى تحديث الصفحة.";
          break;
        case "not-found":
          friendlyMessage =
              "لم يتم العثور على الطلب أو الحساب في سجلات النظام.";
          break;
        case "permission-denied":
          friendlyMessage =
              "أنت لا تملك الصلاحية لإلغاء هذا الطلب (الطلب لا يخص حسابك).";
          break;
        case "failed-precondition":
          // هنا تظهر الرسالة الدقيقة التي كتبناها في السيرفر (مثال: تم قبول منتج أو تغيرت الحالة)
          friendlyMessage =
              e.message ??
              "تغيرت حالة الطلب على السيرفر ولم يعد قابلاً للإلغاء المباشر.";
          break;
        case "internal":
          friendlyMessage =
              "حدث خطأ داخلي في الخادم المالي، يرجى المحاولة لاحقاً.";
          break;
        default:
          friendlyMessage = e.message ?? friendlyMessage;
      }

      TLoaders.errorSnackBar(
        title: "فشلت عملية الإلغاء",
        message: friendlyMessage,
      );
    } catch (e) {
      // التقاط أي أخطاء عامة أخرى (مثل انقطاع الشبكة أثناء الطلب الجاري)
      if (Get.isDialogOpen ?? false) Get.back();
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت لديك وإعادة المحاولة.",
      );
    } finally {
      isCancelLoading.value = false;
    }
  }

  Future<void> handleCancelSpecificItemsLogic({
    required BuildContext context,
    required OrderModel orderModel,
    required List<String> itemIdsToCancel,
  }) async {
    // ==========================================
    // أولاً: التحقق المسبق محلياً (Local Pre-checks)
    // ==========================================

    // 1. فحص أمان أولي للتأكد من تمرير عناصر
    if (itemIdsToCancel.isEmpty) {
      TLoaders.errorSnackBar(
        title: "عملية غير مكتملة",
        message: "يرجى تحديد منتج واحد على الأقل لتتمكن من تقديم الطلب.",
      );
      return;
    }

    // 2. فحص اتصال الإنترنت (يمكنك دمج كود connectivity_plus المعتمد لديك هنا)

    // ==========================================
    // ثانياً: استدعاء الـ Cloud Function ومعالجة النتائج
    // ==========================================
    try {
      // تفعيل مؤشر حالة التحميل وفتح الدايالوج الشفاف لمنع أي نقرات عشوائية أثناء المعالجة المالية
      isCancelLoading.value = true;
      _showLoadingDialog();

      // استدعاء الدالة السحابية المحدثة بالتنسيق v2
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'cancelSpecificItems',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 20)),
      );

      // تمرير المعطيات المحددة التي تتوقعها الدالة على السيرفر (ID الطلب وقائمة المنتجات)
      final results = await callable.call(<String, dynamic>{
        'orderId': orderModel.id,
        'itemIdsToCancel': itemIdsToCancel,
      });

      // إغلاق دايالوج الانتظار فوراً عند نجاح العملية واستجابة الخادم
      if (Get.isDialogOpen ?? false) Get.back();

      // استقبال وتحليل رد السيرفر الناجح
      if (results.data != null && results.data['status'] == 'success') {
        final data = results.data;

        // تحويل أرقام المبالغ المستردة بشكل آمن متوافق مع نظام الفلوتر
        final double refundedAmount =
            double.tryParse(data['refundedAmount'].toString()) ?? 0.0;
        final int cancelledCount = data['cancelledCount'] ?? 0;
        final int reviewCount = data['reviewCount'] ?? 0;

        // صياغة رسالة نجاح تفاعلية وذكية تشرح للمستخدم ما تم خلف الكواليس بدقة
        String successMessage = "";

        if (cancelledCount > 0 && reviewCount > 0) {
          successMessage =
              "تم إلغاء $cancelledCount منتج فوراً وإعادة ($refundedAmount) شيكل لمحفظتك، وتحويل $reviewCount منتج آخر للإدارة للمراجعة.";
        } else if (cancelledCount > 0) {
          successMessage =
              "تم إلغاء المنتج بنجاح، وتم رد مبلغ ($refundedAmount) شيكل إلى محفظتك فوراً.";
        } else if (reviewCount > 0) {
          successMessage =
              "تم تقديم طلب الإلغاء/الإرجاع لعدد $reviewCount منتج بنجاح، وهو قيد المراجعة حالياً من قِبل الإدارة.";
        } else {
          successMessage = "تمت معالجة تحديثات حالة المنتجات بنجاح.";
        }

        _showSuccessSnackbar(
          title: "تمت العملية بنجاح 🎉",
          message: successMessage,
        );

        // تحديث الـ UI (إذا كنت تستخدم GetBuilder أو رغبت في إعادة جلب بيانات الطلب من الفايرستور مباشرة ليعكس الحالات الجديدة)
        update();
      }
    } on FirebaseFunctionsException catch (e) {
      // إغلاق دايالوج الانتظار فوراً عند حدوث استثناء من خادم الفايربيس
      if (Get.isDialogOpen ?? false) Get.back();

      // تفكيك دقيق ومحترف لكافة شيفرات أخطاء السيرفر (Error Codes) وعرضها بلغة عربية مفهومة للمستخدم
      String friendlyMessage = "حدث خطأ غير متوقع أثناء معالجة طلبك.";

      switch (e.code) {
        case "unauthenticated":
          friendlyMessage =
              "انتهت جلسة تسجيل الدخول الخاصة بك، يرجى إعادة تسجيل الدخول والمحاولة مرة أخرى.";
          break;
        case "invalid-argument":
          friendlyMessage =
              "البيانات المرسلة غير صالحة أو مشوهة، يرجى تحديث الصفحة والمحاولة مجدداً.";
          break;
        case "not-found":
          friendlyMessage =
              "تعذر العثور على مستندات الطلب أو الحساب المرتبط به في سجلات السيرفر الكلية.";
          break;
        case "permission-denied":
          friendlyMessage =
              "أنت لا تملك الصلاحية الأمنية الكافية لإجراء هذا التعديل على الطلب المحدَد.";
          break;
        case "failed-precondition":
          // هنا نلتقط النص المخصص والدقيق القادم مباشرة من عبارات الـ throw بالسيرفر (مثال: المنتج معالج مسبقاً)
          friendlyMessage =
              e.message ??
              "تغيرت حالة المنتج على الخادم ولم يعد قابلاً للطلب أو التعديل الفوري حالياً.";
          break;
        case "internal":
          friendlyMessage =
              "حدث خطأ داخلي في معالجات الخادم المالي، يرجى مراجعة الدعم الفني إن تكرر الخطأ.";
          break;
        default:
          friendlyMessage = e.message ?? friendlyMessage;
      }

      TLoaders.errorSnackBar(
        title: "فشلت عملية المعالجة",
        message: friendlyMessage,
      );
    } catch (e) {
      // التقاط الأخطاء العامة الخارجة عن الفايربيس (مثل انقطاع مفاجئ بالشبكة أو تجمد بنية البيانات)
      if (Get.isDialogOpen ?? false) Get.back();
      TLoaders.errorSnackBar(
        title: "خطأ في الاتصال 🌐",
        message:
            "تعذر الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت وتحديث الصفحة ثم المحاولة.",
      );
    } finally {
      // إغلاق حالة التحميل في جميع المسارات (سواء نجحت العملية أو فشلت) لتسريح عناصر الواجهة
      isCancelLoading.value = false;
    }
  }

  // دايالوج الانتظار الشفاف
  void _showLoadingDialog() {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.white)),
      barrierDismissible: false,
    );
  }
*/
  // سناك بار الأخطاء الاحترافي
  /*
  void _showErrorSnackbar({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 5),
    );
  }
*/
  // سناك بار النجاح الاحترافي
  /*
  void TLoaders.successSnackBar({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      duration: const Duration(seconds: 5),
    );
  }
*/
  /* Future<List<OrderModel>> fetchUserOrder() async {
    try {
      isOrdersLoading.value = true;

      final userId = AuthenticationRepository.instance.authUser?.uid ?? "";
      if (userId.isEmpty) return [];

      // ربط القائمة بالـ Stream القادم من المستودع
      userOrders.bindStream(orderRepository.fetchUserOrders(userId));
      return userOrders;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'خطأ', message: e.toString());
      return [];
    } finally {
      isOrdersLoading.value = false;
    }
  }*/
}
