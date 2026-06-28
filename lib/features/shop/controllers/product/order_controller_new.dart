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
}
