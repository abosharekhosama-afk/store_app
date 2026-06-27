import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2_ecom/enums.dart';
import 'package:untitled2_ecom/features/personalization/models/address_model_new.dart';
import 'package:untitled2_ecom/features/shop/models/cart_item_model.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class OrderModel {
  final String id;
  final String userId;
  final OrderStatus status; // الحالة العامة (Processing, Shipped, etc.)
  final double
  rejectedAmount; // حقل جديد: إجمالي مبالغ العناصر المرفوضة (للإرجاع)
  final DateTime orderDate;
  final String paymentMethod;
  final AddressModelNew? address;
  final DateTime? deliveryDate;
  final List<CartItemModel> items;
  final double itemsAmount; // تكلفة المنتجات فقط
  final double shippingAmount; // تكلفة الشحن المحسوبة
  final double totalAmount; // المجموع الكلي (Items + Shipping)
  final String deliveryCode;
  final String? deliveryBoyId;
  final String senderName; // 1. أضف هذا الحقل هنا
  final double walletPaidAmount;
  final double bankRequiredAmount;
  final String paymentType;
  OrderModel({
    required this.id,
    this.userId = "",
    required this.status,
    required this.totalAmount,
    this.rejectedAmount = 0.0, // القيمة الافتراضية صفر
    required this.orderDate,
    this.paymentMethod = "PayPal",
    this.address,
    this.deliveryDate,
    required this.items,
    required this.itemsAmount,
    required this.shippingAmount,
    required this.deliveryCode, // مطلوب عند إنشاء الطلب
    this.deliveryBoyId, // مطلوب عند إنشاء الطلب
    required this.senderName, // 2. أضفه في الـ Constructor
    this.walletPaidAmount = 0.0, // 👈 إضافة
    this.bankRequiredAmount = 0.0, // 👈 إضافة
    this.paymentType = "full_bank",
  });

  // --- Getters للحسابات المنطقية ---

  // 1. حساب المبلغ الفعلي (الأصلي - المرفوض)
  double get actualAmount => totalAmount - rejectedAmount;

  // 2. جلب قائمة بمعرفات المتاجر الموجودة في هذا الطلب (بدون تكرار)
  List<String> get storeIds =>
      items.map((item) => item.storeId).toSet().toList();

  // 3. التحقق مما إذا كان هناك عناصر مرفوضة تحتاج استرداد مالي
  bool get needsRefund => rejectedAmount > 0;

  // 4. جلب العناصر الخاصة بمتجر معين فقط (لاستخدامه في تطبيق التاجر)
  List<CartItemModel> getItemsByStore(String storeId) {
    return items.where((item) => item.storeId == storeId).toList();
  }

  // --- مسميات الحقول لقاعدة البيانات ---
  static String get getOrderCollectionName => "Orders";
  static String get getId => "Id";
  static String get getUserId => "UserId";
  static String get getStatus => "Status";
  static String get getTotalAmount => "TotalAmount";
  static String get getRejectedAmount => "RejectedAmount"; // ثابت جديد
  static String get getOrderDate => "OrderDate";
  static String get getPaymentMethod => "PaymentMethod";
  static String get getAddress => "Address";
  static String get getDeliveryDate => "DeliveryDate";
  static String get getItems => "Items";
  static String get getItemsAmount => "ItemsAmount";
  static String get getShippingAmount => "ShippingAmount";
  static String get getDeliveryCode => "DeliveryCode";
  static String get getDeliveryBoyId => "DeliveryBoyId";
  static String get getSenderName => "SenderName";
  static String get getWalletPaidAmount => "WalletPaidAmount";
  static String get getBankRequiredAmount => "BankRequiredAmount";
  static String get getPaymentType => "PaymentType";
  // --- التنسيق والعرض ---
  String get formattedOrderDate => THelperFunctions.getFormattedDate(orderDate);

  // --- Getters للحسابات المنطقية المحدثة ---

  // 1. فحص هل الطلب انتهت مهلة سداده البنكية (مر عليه أكثر من ساعة)
  bool get isPaymentExpired {
    if (status == OrderStatus.pendingPayment) {
      final difference = DateTime.now().difference(orderDate);
      return difference.inMinutes >= 60; // إذا مر 60 دقيقة أو أكثر
    }
    return false;
  }

  // 2. الخاصية الحاسمة لجلب الحالة الحقيقية اللحظية للعرض والمنطق
  OrderStatus get actualStatus {
    if (status == OrderStatus.pendingPayment && isPaymentExpired) {
      return OrderStatus
          .cancelled; // تحويل الحالة وهمياً لملغي لإدارة الواجهات والعمليات
    }
    return status; // إرجاع الحالة الأصلية (pending, processing, etc.)
  }

  // 3. تعديل مخرجات النص العربي ليتوافق مع الإلغاء التلقائي
  String get orderStatusText {
    if (status == OrderStatus.pendingPayment && isPaymentExpired) {
      return "ملغي (انتهت مهلة السداد)";
    }

    switch (status) {
      case OrderStatus.delivered:
        return "تم التسليم";
      case OrderStatus.shipped:
        return "في الطريق إليك";
      case OrderStatus.processing:
        return "قيد التجهيز";
      case OrderStatus.cancelled:
        return "ملغي";
      case OrderStatus.pendingPayment:
        return "بانتظار تأكيد الدفع البنكي";
      case OrderStatus.accepted:
        return "تم قبول الطلب";
      case OrderStatus.pending:
        return "بانتظار تأكيد المتاجر";
      case OrderStatus.refunded:
        return "مرجع";
      default:
        return "جاري المراجعة";
    }
  }

  /*
  String get orderStatusText {
    switch (status) {
      case OrderStatus.delivered:
        return "تم التسليم";
      case OrderStatus.shipped:
        return "في الطريق إليك";
      case OrderStatus.processing:
        return "قيد التجهيز";
      case OrderStatus.cancelled:
        return "ملغي";
      case OrderStatus.pendingPayment:
        return "بانتظار تاكيد الدفع";
      case OrderStatus.accepted:
        return "تم قبول الطلب";
      case OrderStatus.pending:
        return "بانتظار تاكيد المتاجر";
      case OrderStatus.refunded:
        return "مرجع";
      default:
        return "جاري المراجعة";
    }
  }
*/
  OrderModel copyWith({
    String? id,
    String? userId,
    OrderStatus? status,
    double? totalAmount,
    double? rejectedAmount,
    DateTime? orderDate,
    String? paymentMethod,
    AddressModelNew? address,
    DateTime? deliveryDate,
    List<CartItemModel>? items,
    double? itemsAmount,
    double? shippingAmount,
    String? deliveryCode,
    String? deliveryBoyId,
    String? senderName, // 3. أضف هذا الحقل هنا
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      rejectedAmount: rejectedAmount ?? this.rejectedAmount,
      orderDate: orderDate ?? this.orderDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      address: address ?? this.address,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      items: items ?? this.items,
      itemsAmount: itemsAmount ?? this.itemsAmount,
      shippingAmount: shippingAmount ?? this.shippingAmount,
      deliveryCode: deliveryCode ?? this.deliveryCode,
      deliveryBoyId: deliveryBoyId ?? this.deliveryBoyId,
      senderName: senderName ?? this.senderName, // 4. أضف هذا الحقل هنا
    );
  }

  Map<String, dynamic> toJson() {
    return {
      getId: id,
      getUserId: userId,
      getStatus: status.name,
      getTotalAmount: totalAmount,
      getRejectedAmount: rejectedAmount,
      getOrderDate: orderDate,
      getPaymentMethod: paymentMethod,
      getAddress: address?.toJson(),
      getDeliveryDate: deliveryDate,
      getItems: items.map((item) => item.toJson()).toList(),
      getDeliveryCode: deliveryCode, // حفظ الرمز
      getDeliveryBoyId: deliveryBoyId,
      getItemsAmount: itemsAmount,
      getShippingAmount: shippingAmount,
      getSenderName: senderName, // حفظ معرف طبيب التسليم
      getWalletPaidAmount: walletPaidAmount, // 👈 حفظ
      getBankRequiredAmount: bankRequiredAmount, // 👈 حفظ
      getPaymentType: paymentType, // 👈 حفظ
    };
  }

  /*
  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      // 1. تحقق استباقي للتأكد من وجود البيانات لمنع الـ Null Pointer Exception
      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception("مستند الطلب غير موجود أو فارغ بالكامل.");
      }

      final data = snapshot.data() as Map<String, dynamic>;

      // 2. معالجة آمنة لحالة الطلب (Status) لمنع انهيار الـ firstWhere عند اختلاف حالة الأحرف
      final String rawStatus = (data[getStatus] ?? '').toString().trim();
      OrderStatus parsedStatus = OrderStatus.values.firstWhere(
        (element) => element.name.toLowerCase() == rawStatus.toLowerCase(),
        orElse: () =>
            OrderStatus.pending, // حالة افتراضية حامية بدلاً من الانهيار
      );

      // 3. معالجة مرنة للتاريخ (يدعم الـ Timestamp والـ String للحماية القصوى)
      DateTime parsedOrderDate = DateTime.now();
      final dynamic rawOrderDate = data[getOrderDate];
      if (rawOrderDate != null) {
        if (rawOrderDate is Timestamp) {
          parsedOrderDate = rawOrderDate.toDate();
        } else if (rawOrderDate is String) {
          parsedOrderDate = DateTime.tryParse(rawOrderDate) ?? DateTime.now();
        }
      }

      // 4. معالجة مرنة لتاريخ التوصيل
      DateTime? parsedDeliveryDate;
      final dynamic rawDeliveryDate = data[getDeliveryDate];
      if (rawDeliveryDate != null) {
        if (rawDeliveryDate is Timestamp) {
          parsedDeliveryDate = rawDeliveryDate.toDate();
        } else if (rawDeliveryDate is String) {
          parsedDeliveryDate = DateTime.tryParse(rawDeliveryDate);
        }
      }

      // 5. معالجة مصفوفة المنتجات بشكل آمن مضاد للـ Null
      List<CartItemModel> parsedItems = [];
      final dynamic rawItems = data[getItems];
      if (rawItems != null && rawItems is List) {
        parsedItems = rawItems
            .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return OrderModel(
        id: (data[getId] ?? snapshot.id).toString(),
        userId: (data[getUserId] ?? '').toString(),
        status: parsedStatus,

        // تأمين الأرقام العشرية من فخ الـ int/double المتأرجح في الفايرستور عبر tryParse كحماية إضافية
        totalAmount:
            double.tryParse((data[getTotalAmount] ?? 0.0).toString()) ?? 0.0,
        rejectedAmount:
            double.tryParse((data[getRejectedAmount] ?? 0.0).toString()) ?? 0.0,
        itemsAmount:
            double.tryParse((data[getItemsAmount] ?? 0.0).toString()) ?? 0.0,
        shippingAmount:
            double.tryParse((data[getShippingAmount] ?? 0.0).toString()) ?? 0.0,

        // الحقول المالية الجديدة المحمية تماماً عبر التحويل النصي الآمن ضد الـ Parsing Errors
        walletPaidAmount:
            double.tryParse((data[getWalletPaidAmount] ?? 0.0).toString()) ??
            0.0,
        bankRequiredAmount:
            double.tryParse((data[getBankRequiredAmount] ?? 0.0).toString()) ??
            0.0,

        orderDate: parsedOrderDate,
        paymentMethod: (data[getPaymentMethod] ?? 'Wallet').toString(),

        address: data[getAddress] != null
            ? AddressModelNew.fromMap(data[getAddress] as Map<String, dynamic>)
            : null,

        deliveryDate: parsedDeliveryDate,
        items: parsedItems,
        deliveryCode: (data[getDeliveryCode] ?? '').toString(),
        deliveryBoyId: data[getDeliveryBoyId]?.toString(),
        senderName: (data[getSenderName] ?? "غير معرف").toString(),
        paymentType: (data[getPaymentType] ?? "full_bank").toString(),
      );
    } catch (e, stackTrace) {
      // طباعة تفاصيل الخطأ والمكان الدقيق لحدوثه في الـ Console أثناء التطوير والمراقبة
      if (kDebugMode) {
        print("🚨 خطأ فادح أثناء معالجة مستند OrderModel (من الفايرستور): $e");
        print("📌 مكان الخطأ (StackTrace):\n$stackTrace");
      }

      // 🌟 خط الدفاع الأخير: إرجاع كائن فارغ/افتراضي آمن لكي لا يتجمد التطبيق أو تنهار قائمة الطلبات
      return OrderModel(
        id: snapshot.id,
        userId: '',
        status: OrderStatus.pending,
        totalAmount: 0.0,
        rejectedAmount: 0.0,
        itemsAmount: 0.0,
        shippingAmount: 0.0,
        walletPaidAmount: 0.0,
        bankRequiredAmount: 0.0,
        orderDate: DateTime.now(),
        paymentMethod: 'Error_Fallback',
        items: [],
        senderName: "خطأ في قراءة البيانات",
        paymentType: "error",
        deliveryCode: "",
      );
    }
  }
*/
  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    // 1. تحقق استباقي للتأكد من وجود البيانات لمنع الـ Null Pointer Exception
    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception("مستند الطلب غير موجود أو فارغ.");
    }

    final data = snapshot.data() as Map<String, dynamic>;

    // 2. معالجة آمنة لحالة الطلب (Status) لمنع انهيار الـ firstWhere عند اختلاف حالة الأحرف
    final String rawStatus = (data[getStatus] ?? '').toString().trim();
    OrderStatus parsedStatus = OrderStatus.values.firstWhere(
      (element) => element.name.toLowerCase() == rawStatus.toLowerCase(),
      orElse: () =>
          OrderStatus.pending, // حالة افتراضية حامية بدلاً من الانهيار
    );

    // 3. معالجة مرنة للتاريخ (يدعم الـ Timestamp والـ String للحماية القصوى)
    DateTime parsedOrderDate = DateTime.now();
    final dynamic rawOrderDate = data[getOrderDate];
    if (rawOrderDate != null) {
      if (rawOrderDate is Timestamp) {
        parsedOrderDate = rawOrderDate.toDate();
      } else if (rawOrderDate is String) {
        parsedOrderDate = DateTime.tryParse(rawOrderDate) ?? DateTime.now();
      }
    }

    // 4. معالجة مرنة لتاريخ التوصيل
    DateTime? parsedDeliveryDate;
    final dynamic rawDeliveryDate = data[getDeliveryDate];
    if (rawDeliveryDate != null) {
      if (rawDeliveryDate is Timestamp) {
        parsedDeliveryDate = rawDeliveryDate.toDate();
      } else if (rawDeliveryDate is String) {
        parsedDeliveryDate = DateTime.tryParse(rawDeliveryDate);
      }
    }

    // 5. معالجة مصفوفة المنتجات بشكل آمن مضاد للـ Null
    List<CartItemModel> parsedItems = [];
    final dynamic rawItems = data[getItems];
    if (rawItems != null && rawItems is List) {
      parsedItems = rawItems
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: (data[getId] ?? snapshot.id).toString(),
      userId: (data[getUserId] ?? '').toString(),
      status: parsedStatus,

      // تأمين الأرقام العشرية من فخ الـ int/double المتأرجح في الفايرستور
      totalAmount: double.parse((data[getTotalAmount] ?? 0.0).toString()),
      rejectedAmount: double.parse((data[getRejectedAmount] ?? 0.0).toString()),
      itemsAmount: double.parse((data[getItemsAmount] ?? 0.0).toString()),
      shippingAmount: double.parse((data[getShippingAmount] ?? 0.0).toString()),

      // الحقول المالية الجديدة المحمية تماماً عبر التحويل النصي الآمن
      walletPaidAmount: double.parse(
        (data[getWalletPaidAmount] ?? 0.0).toString(),
      ),
      bankRequiredAmount: double.parse(
        (data[getBankRequiredAmount] ?? 0.0).toString(),
      ),

      orderDate: parsedOrderDate,
      paymentMethod: (data[getPaymentMethod] ?? 'Wallet').toString(),

      address: data[getAddress] != null
          ? AddressModelNew.fromMap(data[getAddress] as Map<String, dynamic>)
          : null,

      deliveryDate: parsedDeliveryDate,
      items: parsedItems,
      deliveryCode: (data[getDeliveryCode] ?? '').toString(),
      deliveryBoyId: data[getDeliveryBoyId]?.toString(),
      senderName: (data[getSenderName] ?? "غير معرف").toString(),
      paymentType: (data[getPaymentType] ?? "full_bank").toString(),
    );
  }

  /*
  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return OrderModel(
      id: data[getId] as String,
      userId: data[getUserId] as String,
      status: OrderStatus.values.firstWhere(
        (element) => element.name == data[getStatus],
      ),
      totalAmount: (data[getTotalAmount] ?? 0.0).toDouble(),
      rejectedAmount: (data[getRejectedAmount] ?? 0.0).toDouble(),
      orderDate: (data[getOrderDate] as Timestamp).toDate(),
      paymentMethod: data[getPaymentMethod] as String,
      address: data[getAddress] != null
          ? AddressModelNew.fromMap(data[getAddress])
          : null,
      deliveryDate: data[getDeliveryDate] == null
          ? null
          : (data[getDeliveryDate] as Timestamp).toDate(),
      items: (data[getItems] as List<dynamic>)
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      itemsAmount: (data[getItemsAmount] ?? 0.0).toDouble(),
      shippingAmount: (data[getShippingAmount] ?? 0.0).toDouble(),
      deliveryCode: data[getDeliveryCode] ?? '', // استعادة الرمز
      deliveryBoyId:
          data[getDeliveryBoyId] ?? null, // استعادة معرف طبيب التسليم
      senderName: data[getSenderName] ?? "غير معرف",
      walletPaidAmount: (data[getWalletPaidAmount] ?? 0.0)
          .toDouble(), // 👈 استرجاع
      bankRequiredAmount: (data[getBankRequiredAmount] ?? 0.0)
          .toDouble(), // 👈 استرجاع
      paymentType: data[getPaymentType] ?? "full_bank", // 👈 استرجاع
    );
  }
  */
  // دالة مساعدة لإنشاء الطلب وحساب تكاليفه
  factory OrderModel.createNewOrder({
    required String id,
    required String senderName,
    required String userId,
    required List<CartItemModel> items,
    required AddressModelNew userAddress,
    required Map<String, AddressModelNew> storeAddresses,
    required double shippingTotal,
    required double itemsTotal,
    required double finalTotalAmount,
    required DateTime orderDate,
    required DateTime expiresAt,
  }) {
    String generatedCode = (100000 + Random().nextInt(900000)).toString();
    // حساب تكلفة المنتجات
    /*double itemsTotal = items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );*/

    // حساب تكلفة الشحن باستخدام الخدمة الجديدة
    /*double shippingTotal = ShippingCalculatorService.calculateTotalShipping(
      items: items,
      userAddress: userAddress,
      storeAddresses: storeAddresses,
      addressDataMap: AddressController
          .instance
          .palestineAddressData, // البيانات الديناميكية
    );*/

    return OrderModel(
      id: id,
      userId: userId,
      status: OrderStatus.pendingPayment,
      itemsAmount: itemsTotal,
      shippingAmount: shippingTotal,
      totalAmount: finalTotalAmount,
      orderDate: DateTime.now(),
      items: items,
      address: userAddress,
      deliveryCode: generatedCode, // الرمز هنا
      deliveryBoyId: null,
      senderName: senderName, // مرره هنا للكلاس // معرف طبيب التسليم
    );
  }
}














/*
class OrderModel {
  final String id;
  final String userId;
  final OrderStatus status; // الحالة العامة (Processing, Shipped, etc.)
  final double
  rejectedAmount; // حقل جديد: إجمالي مبالغ العناصر المرفوضة (للإرجاع)
  final DateTime orderDate;
  final String paymentMethod;
  final AddressModelNew? address;
  final DateTime? deliveryDate;
  final List<CartItemModel> items;
  final double itemsAmount; // تكلفة المنتجات فقط
  final double shippingAmount; // تكلفة الشحن المحسوبة
  final double totalAmount; // المجموع الكلي (Items + Shipping)
  final String deliveryCode;
  final String? deliveryBoyId;

  OrderModel({
    required this.id,
    this.userId = "",
    required this.status,
    required this.totalAmount,
    this.rejectedAmount = 0.0, // القيمة الافتراضية صفر
    required this.orderDate,
    this.paymentMethod = "PayPal",
    this.address,
    this.deliveryDate,
    required this.items,
    required this.itemsAmount,
    required this.shippingAmount,
    required this.deliveryCode, // مطلوب عند إنشاء الطلب
    this.deliveryBoyId,
  });

  // --- Getters للحسابات المنطقية ---

  // 1. حساب المبلغ الفعلي (الأصلي - المرفوض)
  double get actualAmount => totalAmount - rejectedAmount;

  // 2. جلب قائمة بمعرفات المتاجر الموجودة في هذا الطلب (بدون تكرار)
  List<String> get storeIds =>
      items.map((item) => item.storeId).toSet().toList();

  // 3. التحقق مما إذا كان هناك عناصر مرفوضة تحتاج استرداد مالي
  bool get needsRefund => rejectedAmount > 0;

  // 4. جلب العناصر الخاصة بمتجر معين فقط (لاستخدامه في تطبيق التاجر)
  List<CartItemModel> getItemsByStore(String storeId) {
    return items.where((item) => item.storeId == storeId).toList();
  }

  // --- مسميات الحقول لقاعدة البيانات ---
  static String get getOrderCollectionName => "Orders";
  static String get getId => "Id";
  static String get getUserId => "UserId";
  static String get getStatus => "Status";
  static String get getTotalAmount => "TotalAmount";
  static String get getRejectedAmount => "RejectedAmount"; // ثابت جديد
  static String get getOrderDate => "OrderDate";
  static String get getPaymentMethod => "PaymentMethod";
  static String get getAddress => "Address";
  static String get getDeliveryDate => "DeliveryDate";
  static String get getItems => "Items";
  static String get getItemsAmount => "ItemsAmount";
  static String get getShippingAmount => "ShippingAmount";
  static String get getDeliveryCode => "DeliveryCode";
  static String get getDeliveryBoyId => "DeliveryBoyId";

  // --- التنسيق والعرض ---
  String get formattedOrderDate => THelperFunctions.getFormattedDate(orderDate);

  String get orderStatusText {
    switch (status) {
      case OrderStatus.delivered:
        return "تم التسليم";
      case OrderStatus.shipped:
        return "في الطريق إليك";
      case OrderStatus.processing:
        return "قيد التجهيز";
      case OrderStatus.cancelled:
        return "ملغي";
      default:
        return "جاري المراجعة";
    }
  }

  Map<String, dynamic> toJson() {
    return {
      getId: id,
      getUserId: userId,
      getStatus: status.name,
      getTotalAmount: totalAmount,
      getRejectedAmount: rejectedAmount,
      getOrderDate: orderDate,
      getPaymentMethod: paymentMethod,
      getAddress: address?.toJson(),
      getDeliveryDate: deliveryDate,
      getItems: items.map((item) => item.toJson()).toList(),
      getDeliveryCode: deliveryCode, // حفظ الرمز
      getDeliveryBoyId: deliveryBoyId, // حفظ معرف طبيب التسليم
    };
  }

  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return OrderModel(
      id: data[getId] as String,
      userId: data[getUserId] as String,
      status: OrderStatus.values.firstWhere(
        (element) => element.toString() == data[getStatus],
      ),
      totalAmount: (data[getTotalAmount] ?? 0.0).toDouble(),
      rejectedAmount: (data[getRejectedAmount] ?? 0.0).toDouble(),
      orderDate: (data[getOrderDate] as Timestamp).toDate(),
      paymentMethod: data[getPaymentMethod] as String,
      address: data[getAddress] != null
          ? AddressModelNew.fromMap(data[getAddress])
          : null,
      deliveryDate: data[getDeliveryDate] == null
          ? null
          : (data[getDeliveryDate] as Timestamp).toDate(),
      items: (data[getItems] as List<dynamic>)
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      itemsAmount: (data[getItemsAmount] ?? 0.0).toDouble(),
      shippingAmount: (data[getShippingAmount] ?? 0.0).toDouble(),
      deliveryCode: data[getDeliveryCode] ?? '', // استعادة الرمز
      deliveryBoyId:
          data[getDeliveryBoyId] ?? null, // استعادة معرف طبيب التسليم
    );
  }

  // دالة مساعدة لإنشاء الطلب وحساب تكاليفه
  factory OrderModel.createNewOrder({
    required String id,
    required String userId,
    required List<CartItemModel> items,
    required AddressModelNew userAddress,
    required Map<String, AddressModelNew> storeAddresses,
  }) {
    String generatedCode = (100000 + Random().nextInt(900000)).toString();
    // حساب تكلفة المنتجات
    double itemsTotal = items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    // حساب تكلفة الشحن باستخدام الخدمة الجديدة
    double shippingTotal = ShippingCalculatorService.calculateTotalShipping(
      items: items,
      userAddress: userAddress,
      storeAddresses: storeAddresses,
    );

    return OrderModel(
      id: id,
      userId: userId,
      status: OrderStatus.pending,
      itemsAmount: itemsTotal,
      shippingAmount: shippingTotal,
      totalAmount: itemsTotal + shippingTotal,
      orderDate: DateTime.now(),
      items: items,
      address: userAddress,
      deliveryCode: generatedCode, // الرمز هنا
      deliveryBoyId: null, // معرف طبيب التسليم
    );
  }
}

*/













/*
class OrderModel {
  final String id;
  final String userId;
  final OrderStatus status;
  final double totalAmount;
  final DateTime orderDate;
  final String paymentMethod;
  final AddressModel? address;
  final DateTime? deliveryDate;
  final List<CartItemModel> items;

  OrderModel({
    required this.id,
    this.userId = "",
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    this.paymentMethod = "PayPal",
    this.address,
    this.deliveryDate,
    required this.items,
  });

  static String get getOrderCollectionName => "Orders";
  static String get getId => "Id";
  static String get getUserId => "UserId";
  static String get getStatus => "Status";
  static String get getTotalAmount => "TotalAmount";
  static String get getOrderDate => "OrderDate";
  static String get getPaymentMethod => "PaymentMethod";
  static String get getAddress => "Address";
  static String get getDeliveryDate => "DeliveryDate";
  static String get getItems => "Items";

  String get formattedOrderDate => THelperFunctions.getFormattedDate(orderDate);
  String get formattedDeilveryDate =>
      deliveryDate != null ? THelperFunctions.getFormattedDate(orderDate) : "";

  String get orderStatusText => status == OrderStatus.delivered
      ? "Delivered"
      : status == OrderStatus.shipped
      ? "Shipment on the way"
      : "Processing";

  Map<String, dynamic> toJson() {
    return {
      getId: id,
      getUserId: userId,
      getStatus: status.toString(),
      getTotalAmount: totalAmount,
      getOrderDate: orderDate,
      getPaymentMethod: paymentMethod,
      getAddress: address?.toJson(),
      getDeliveryDate: deliveryDate,
      getItems: items.map((item) => item.toJson()).toList(),
    };
  }

  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return OrderModel(
      id: data[getId] as String,
      userId: data[getUserId] as String,
      status: OrderStatus.values.firstWhere(
        (element) => element.toString() == data[getStatus],
      ),
      totalAmount: data[getTotalAmount] as double,
      orderDate: (data[getOrderDate] as Timestamp).toDate(),
      paymentMethod: data[getPaymentMethod] as String,
      address: AddressModel.fromMap(data[getAddress] as Map<String, dynamic>),
      deliveryDate: data[getDeliveryDate] == null
          ? null
          : (data[getDeliveryDate] as Timestamp).toDate(),
      items: (data[getItems] as List<dynamic>)
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
*/