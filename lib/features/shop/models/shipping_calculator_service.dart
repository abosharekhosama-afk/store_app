import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:untitled2_ecom/features/personalization/models/address_model_new.dart';
import 'package:untitled2_ecom/features/shop/models/cart_item_model.dart';

class ShippingCalculatorService {
  /// الدالة الرئيسية لحساب التكلفة الإجمالية بناءً على بيانات الخريطة الديناميكية

  // دالة الحساب الرئيسية
  /*
  static double calculateTotalShipping({
    required List<CartItemModel> items,

    required AddressModelNew userAddress,

    required Map<String, AddressModelNew> storeAddresses,

    required Map<String, Map<String, Map<String, dynamic>>> addressDataMap,
  }) {
    // 1. السعر الأساسي هو سعر التوصيل إلى بيت الزبون فقط

    double baseDeliveryFee = getFeeFromMap(
      addressDataMap: addressDataMap,

      governorate: userAddress.city,

      city: userAddress.district,

      street: userAddress.street,
    ); // لو الزبون في النصر، هذا يعطي مثلاً 8 أو 10 شواكل بناءً على خريطتك

    // 2. حساب المتاجر الفريدة (Unique Stores)

    final uniqueStoreIds = items.map((item) => item.storeId).toSet();

    double totalCollectionFee = 0;

    // إذا طلب من متجر واحد فقط، لا توجد رسوم تجميع إضافية (0 شيكل)

    // إذا طلب من أكثر من متجر، نضع رسوم تجميع رمزية (مثلاً 2 شيكل) على كل متجر إضافي لتغطية جهد المندوب

    if (uniqueStoreIds.length > 1) {
      // نخصم 1 لأن المتجر الأول مغطى ضمنياً في مسار المندوب

      totalCollectionFee = (uniqueStoreIds.length - 1) * 2.0;
    }

    // التكلفة الإجمالية العادلة والمطابقة للسوق

    return baseDeliveryFee + totalCollectionFee;
  }
*/

  /*
  // دالة الحساب الرئيسية الجديدة (تعتمد على كوليكشن المصفوفة الثنائية)
  static Future<double> calculateTotalShipping({
    required List<CartItemModel> items,
    required AddressModelNew userAddress,
    required Map<String, AddressModelNew> storeAddresses,
    required Map<String, Map<String, Map<String, dynamic>>> addressDataMap,
  }) async {
    // إذا لم تكن هناك عناصر في السلة، التكلفة صفر
    if (items.isEmpty) return 0.0;

    // 1. تحديد المعرف الجغرافي الفريد لعنوان الزبون الحالي
    // ملاحظة: تأكد من مطابقة مسميات الحقول في موديل الزبون (city تعني المحافظة، district تعني الحي)
    String customerLocationId =
        "${userAddress.city.trim()}_${userAddress.district.trim()}_${userAddress.street.trim()}";

    // 2. استخراج المتاجر الفريدة الموجودة في السلة حالياً
    final uniqueStoreIds = items.map((item) => item.storeId).toSet();

    double totalShippingFee = 0.0;
    int storeIndex = 0;

    final firestore = FirebaseFirestore.instance;

    // 3. الدوران على كل متجر فريد لحساب تكلفة الشحن منه إلى الزبون
    for (String storeId in uniqueStoreIds) {
      double currentStoreFee = 0.0;

      // الحصول على عنوان المتجر من الخريطة الممررة
      AddressModelNew? storeAddress = storeAddresses[storeId];

      if (storeAddress != null) {
        // تركيب المعرف الجغرافي لعنوان المتجر
        String storeLocationId =
            "${storeAddress.city.trim()}_${storeAddress.district.trim()}_${storeAddress.street.trim()}";

        // توليد معرف المستند الثنائي المدمج
        String matrixDocId = "${storeLocationId}__${customerLocationId}";

        try {
          // جلب المستند المدمج مباشرة بـ السرعة القصوى O(1)
          DocumentSnapshot<Map<String, dynamic>> matrixSnapshot =
              await firestore
                  .collection("ShippingRatesMatrix")
                  .doc(matrixDocId)
                  .get();

          if (matrixSnapshot.exists) {
            // أ) إذا وجدنا تسعيرة مخصصة بين شارع هذا المتجر وشارع هذا الزبون
            currentStoreFee = double.parse(
              (matrixSnapshot.data()?['deliveryFee'] ?? 0.0).toString(),
            );
          } else {
            // ب) منطق الحماية الاحتياطي (Fallback): إذا لم يحدد الأدمن سعر الربط الدقيق،
            // نأخذ السعر الافتراضي العام لشارع الزبون من الخريطة المحلية المتوفرة لديك
            currentStoreFee = _getFallbackFee(
              addressDataMap: addressDataMap,
              governorate: userAddress.city,
              city: userAddress.district,
              street: userAddress.street,
            );
          }
        } catch (e) {
          // في حال حدوث أي خطأ في الاتصال، نعتمد على السعر الاحتياطي لضمان عدم توقف الدفع
          currentStoreFee = _getFallbackFee(
            addressDataMap: addressDataMap,
            governorate: userAddress.city,
            city: userAddress.district,
            street: userAddress.street,
          );
        }
      } else {
        // إذا لم تتوفر بيانات عنوان المتجر لأي سبب، نعتمد السعر الاحتياطي للزبون
        currentStoreFee = _getFallbackFee(
          addressDataMap: addressDataMap,
          governorate: userAddress.city,
          city: userAddress.district,
          street: userAddress.street,
        );
      }

      // 4. تطبيق منطق التجميع العادل والمطابق للسوق
      if (storeIndex == 0) {
        // المتجر الأول في السلة: يدفع الزبون تكلفة شحن المسار كاملة
        totalShippingFee += currentStoreFee;
      } else {
        // المتاجر الإضافية (تجميع فرعي): نضيف رسوم تجميع رمزية فقط (مثلاً 2 شيكل) بدلاً من تكلفة مسار كاملة
        totalShippingFee += 2.0;
      }

      storeIndex++;
    }

    return totalShippingFee;
  }
*/
  /*
  // دالة الحساب الرئيسية المطورة (تعتمد على المصفوفة الثنائية والبحث العكسي الذكي)
  static Future<double> calculateTotalShipping({
    required List<CartItemModel> items,
    required AddressModelNew userAddress,
    required Map<String, AddressModelNew> storeAddresses,
    required Map<String, Map<String, Map<String, dynamic>>> addressDataMap,
  }) async {
    // إذا لم تكن هناك عناصر في السلة، التكلفة صفر
    if (items.isEmpty) return 0.0;

    // 1. تحديد المعرف الجغرافي الفريد لعنوان الزبون الحالي
    String customerLocationId =
        "${userAddress.city.trim()}_${userAddress.district.trim()}_${userAddress.street.trim()}";

    // 2. استخراج المتاجر الفريدة الموجودة في السلة حالياً
    final uniqueStoreIds = items.map((item) => item.storeId).toSet();

    double totalShippingFee = 0.0;
    int storeIndex = 0;

    final firestore = FirebaseFirestore.instance;

    // 3. الدوران على كل متجر فريد لحساب تكلفة الشحن منه إلى الزبون
    for (String storeId in uniqueStoreIds) {
      double currentStoreFee = 0.0;

      // الحصول على عنوان المتجر من الخريطة الممررة
      AddressModelNew? storeAddress = storeAddresses[storeId];

      if (storeAddress != null) {
        // تركيب المعرف الجغرافي لعنوان المتجر
        String storeLocationId =
            "${storeAddress.city.trim()}_${storeAddress.district.trim()}_${storeAddress.street.trim()}";

        // أ) توليد معرف المستند الاتجاه الأول: (من المتجر __ إلى الزبون)
        String primaryMatrixDocId = "${storeLocationId}__${customerLocationId}";

        try {
          // جلب مستند الاتجاه الأول
          DocumentSnapshot<Map<String, dynamic>> matrixSnapshot =
              await firestore
                  .collection("ShippingRatesMatrix")
                  .doc(primaryMatrixDocId)
                  .get();

          if (matrixSnapshot.exists) {
            // 🌟 وُجدت التسعيرة في الاتجاه المباشر (مثال: من الجلاء إلى الرمال)
            currentStoreFee = double.parse(
              (matrixSnapshot.data()?['deliveryFee'] ?? 0.0).toString(),
            );
            debugPrint(
              "🎯 [Shipping] Found primary route: $primaryMatrixDocId -> $currentStoreFee ₪",
            );
          } else {
            // 🔄 ب) قلب المعرفات (Swap): توليد معرف المستند في الاتجاه المعاكس (من الزبون __ إلى المتجر)
            String reverseMatrixDocId =
                "${customerLocationId}__${storeLocationId}";

            debugPrint(
              "🔄 [Shipping] Primary route not found. Trying reverse route: $reverseMatrixDocId",
            );

            DocumentSnapshot<Map<String, dynamic>> reverseMatrixSnapshot =
                await firestore
                    .collection("ShippingRatesMatrix")
                    .doc(reverseMatrixDocId)
                    .get();

            if (reverseMatrixSnapshot.exists) {
              // 🌟 وُجدت التسعيرة في الاتجاه المعاكس (مثال: من الرمال إلى الجلاء)
              currentStoreFee = double.parse(
                (reverseMatrixSnapshot.data()?['deliveryFee'] ?? 0.0)
                    .toString(),
              );
              debugPrint(
                "🎯 [Shipping] Found reverse route: $reverseMatrixDocId -> $currentStoreFee ₪",
              );
            } else {
              // ج) منطق الحماية الاحتياطي (Fallback): إذا لم يجد الأدمن المسار بكلا الاتجاهين
              debugPrint(
                "⚠️ [Shipping] Route not found in both directions. Using fallback.",
              );
              currentStoreFee = _getFallbackFee(
                addressDataMap: addressDataMap,
                governorate: userAddress.city,
                city: userAddress.district,
                street: userAddress.street,
              );
            }
          }
        } catch (e) {
          // في حال حدوث أي خطأ شبكة، نعتمد على السعر الاحتياطي لضمان استمرار الدفع
          debugPrint(
            "❌ [Shipping Error] Matrix fetch failed: $e. Using fallback.",
          );
          currentStoreFee = _getFallbackFee(
            addressDataMap: addressDataMap,
            governorate: userAddress.city,
            city: userAddress.district,
            street: userAddress.street,
          );
        }
      } else {
        // إذا لم تتوفر بيانات عنوان المتجر لأي سبب، نعتمد السعر الاحتياطي للزبون
        currentStoreFee = _getFallbackFee(
          addressDataMap: addressDataMap,
          governorate: userAddress.city,
          city: userAddress.district,
          street: userAddress.street,
        );
      }

      // 4. تطبيق منطق التجميع العادل والمطابق للسوق
      if (storeIndex == 0) {
        totalShippingFee += currentStoreFee;
      } else {
        // رسوم تجميع رمزية للمتاجر الإضافية
        totalShippingFee += 2.0;
      }

      storeIndex++;
    }

    return totalShippingFee;
  }
*/

  static Future<Map<String, dynamic>> calculateDetailedShipping({
    required List<CartItemModel> items,
    required AddressModelNew userAddress,
    required Map<String, AddressModelNew> storeAddresses,
    required Map<String, Map<String, Map<String, dynamic>>> addressDataMap,
  }) async {
    if (items.isEmpty) return {'total': 0.0, 'details': <String, double>{}};

    final firestore = FirebaseFirestore.instance;
    final uniqueStoreIds = items.map((item) => item.storeId).toSet();

    double totalShippingFee = 0.0;
    Map<String, double> breakdown = {}; // لحفظ تفاصيل الحسبة وعرضها للعميل
    int storeIndex = 0;

    String customerDistrict = userAddress.district.trim();
    String customerLocationId =
        "${userAddress.city.trim()}_${customerDistrict}_${userAddress.street.trim()}";

    for (String storeId in uniqueStoreIds) {
      double currentStoreFee = 0.0;
      AddressModelNew? storeAddress = storeAddresses[storeId];

      if (storeAddress != null) {
        String storeDistrict = storeAddress.district.trim();
        String storeLocationId =
            "${storeAddress.city.trim()}_${storeDistrict}_${storeAddress.street.trim()}";

        // 🌟 اختبار الذكاء اللوجستي: هل المتجر في نفس حي الزبون ولكن بشارع آخر؟
        if (storeDistrict == customerDistrict) {
          // المندوب متواجد في نفس الحي، يحسب فقط بدل تجميع رمزي (مثال: 3 شيكل)
          currentStoreFee = (storeLocationId == customerLocationId) ? 0.0 : 3.0;
          debugPrint(
            "🎯 [Shipping] Store $storeId is in the SAME district. Fee: $currentStoreFee ₪",
          );
        } else {
          // المتاجر خارج الحي: نطبق مصفوفة المسافات الثنائية (المطور سابقاً)
          String primaryMatrixDocId =
              "${storeLocationId}__${customerLocationId}";
          try {
            DocumentSnapshot<Map<String, dynamic>> snapshot = await firestore
                .collection("ShippingRatesMatrix")
                .doc(primaryMatrixDocId)
                .get();

            if (snapshot.exists) {
              currentStoreFee = double.parse(
                (snapshot.data()?['deliveryFee'] ?? 0.0).toString(),
              );
            } else {
              // فحص الاتجاه المعاكس
              String reverseMatrixDocId =
                  "${customerLocationId}__${storeLocationId}";
              DocumentSnapshot<Map<String, dynamic>> revSnapshot =
                  await firestore
                      .collection("ShippingRatesMatrix")
                      .doc(reverseMatrixDocId)
                      .get();

              if (revSnapshot.exists) {
                currentStoreFee = double.parse(
                  (revSnapshot.data()?['deliveryFee'] ?? 0.0).toString(),
                );
              } else {
                currentStoreFee = _getFallbackFee(
                  addressDataMap: addressDataMap,
                  governorate: userAddress.city,
                  city: userAddress.district,
                  street: userAddress.street,
                );
              }
            }
          } catch (e) {
            currentStoreFee = _getFallbackFee(
              addressDataMap: addressDataMap,
              governorate: userAddress.city,
              city: userAddress.district,
              street: userAddress.street,
            );
          }
        }
      }

      // 🌟 تطبيق منطق التجميع العادل للمشحونات المتعددة
      if (storeIndex == 0) {
        totalShippingFee += currentStoreFee;
        breakdown[storeAddress?.district ?? "المتجر الأساسي"] = currentStoreFee;
      } else {
        // إذا كان هناك متجر آخر خارج الحي تماماً، يضاف عليه رسوم تجميع وليس توصيل كامل
        double additionalFee = (storeAddress?.district == customerDistrict)
            ? currentStoreFee
            : 2.0;
        totalShippingFee += additionalFee;
        breakdown["تجميع: ${storeAddress?.district ?? 'متجر إضافي'}"] =
            additionalFee;
      }

      storeIndex++;
    }

    return {'total': totalShippingFee, 'breakdown': breakdown};
  }

  // دالة المساعدة للاسترداد الاحتياطي من خريطتك القديمة المتداخلة
  static double _getFallbackFee({
    required Map<String, Map<String, Map<String, dynamic>>> addressDataMap,
    required String governorate,
    required String city,
    required String street,
  }) {
    try {
      if (addressDataMap.containsKey(governorate) &&
          addressDataMap[governorate]!.containsKey(city) &&
          addressDataMap[governorate]![city]!.containsKey(street)) {
        return double.parse(
          (addressDataMap[governorate]![city]![street]['fee'] ?? 0.0)
              .toString(),
        );
      }
    } catch (_) {}
    return 10.0; // قيمة افتراضية أمنية (مثلاً 10 شيكل) في حال فراغ قاعدة البيانات تماماً
  }

  /*
  static double calculateTotalShipping({
    required List<CartItemModel> items,
    required AddressModelNew userAddress,
    required Map<String, AddressModelNew> storeAddresses,
    required Map<String, Map<String, Map<String, dynamic>>> addressDataMap,
  }) {
    double totalCollectionFee = 0;
    double deliveryFeeToUser = 0;

    // 1. تحديد المتاجر الفريدة
    final uniqueStoreIds = items.map((item) => item.storeId).toSet();
    Set<String> visitedDistricts = {};

    for (var storeId in uniqueStoreIds) {
      final sAddress = storeAddresses[storeId];
      if (sAddress == null) continue;

      // جلب سعر التوصيل الخاص بحي المتجر من الخريطة
      double storeLocationFee = getFeeFromMap(
        addressDataMap: addressDataMap,
        governorate: sAddress.city,
        city: sAddress.district,
        street: sAddress.street,
      );

      // إذا كان أول متجر في هذا الحي، نأخذ السعر كاملاً، وإذا تكرر الحي نأخذ رسوم رمزية
      if (!visitedDistricts.contains(sAddress.district)) {
        totalCollectionFee += storeLocationFee;
        visitedDistricts.add(sAddress.district);
      } else {
        totalCollectionFee += 2.0; // رسوم تجميع إضافية لنفس الحي
      }
    }

    // 2. حساب تكلفة التوصيل النهائية لمنزل الزبون
    deliveryFeeToUser = getFeeFromMap(
      addressDataMap: addressDataMap,
      governorate: userAddress.city,
      city: userAddress.district,
      street: userAddress.street,
    );

    return totalCollectionFee + deliveryFeeToUser;
  }
*/
  // دالة البحث في الخريطة
  static double getFeeFromMap({
    required Map<String, Map<String, Map<String, dynamic>>> addressDataMap,
    required String governorate,
    required String city,
    required String street,
  }) {
    try {
      final fee = addressDataMap[governorate]?[city]?[street]?['fee'];
      return (fee as num?)?.toDouble() ?? 10.0;
    } catch (e) {
      return 10.0;
    }
  }

  /*static double calculateTotalShipping({
    required List<CartItemModel> items,
    required AddressModelNew userAddress,
    required Map<String, AddressModelNew> storeAddresses,
    required Map<String, Map<String, Map<String, dynamic>>>
    addressDataMap, // البيانات التي تم تحميلها من Firestore
  }) {
    double totalCollectionFee = 0;
    double maxDeliveryFee = 0;

    // 1. تحديد المتاجر الفريدة
    final uniqueStoreIds = items.map((item) => item.storeId).toSet().toList();

    // 2. تتبع المناطق التي تمت زيارتها لتقليل رسوم التجميع
    List<String> visitedStreets = [];

    for (var storeId in uniqueStoreIds) {
      AddressModelNew? sAddress = storeAddresses[storeId];
      if (sAddress == null) continue;

      // حساب رسوم التجميع (الذهاب للمتجر)
      // إذا كان المندوب سيذهب لشارع زاره فعلاً في نفس الطلب، نضع رسوم رمزية
      if (!visitedStreets.contains(sAddress.street)) {
        // رسوم تجميع أساسية (يمكنك جعلها ثابتة أو جلبها من مكان ما)
        totalCollectionFee += 3.0;
        visitedStreets.add(sAddress.street);
      } else {
        totalCollectionFee += 1.5; // متجرين في نفس الشارع
      }

      // 3. تحديد تكلفة التوصيل بناءً على السعر الفعلي في الخريطة
      // نأخذ السعر الخاص بعنوان "الزبون" لأنه هو الوجهة النهائية
      double currentDeliveryFee = _getFeeFromMap(
        addressDataMap: addressDataMap,
        governorate: userAddress.city, // المحافظة
        city: userAddress.district, // المدينة/الحي
        street: userAddress.street, // الشارع
      );

      if (currentDeliveryFee > maxDeliveryFee) {
        maxDeliveryFee = currentDeliveryFee;
      }
    }

    // الإجمالي = رسوم تجميع المندوب من المتاجر + رسوم التوصيل للزبون
    return totalCollectionFee + maxDeliveryFee;
  }

  /// دالة للبحث عن السعر داخل هيكلية الخريطة المعقدة
  static double _getFeeFromMap({
    required Map<String, Map<String, Map<String, dynamic>>> addressDataMap,
    required String governorate,
    required String city,
    required String street,
  }) {
    try {
      // الوصول المتسلسل للبيانات مع معالجة القيم الفارغة
      final govData = addressDataMap[governorate];
      if (govData != null) {
        final cityData = govData[city];
        if (cityData != null) {
          final streetData = cityData[street];
          if (streetData != null && streetData['fee'] != null) {
            return (streetData['fee'] as num).toDouble();
          }
        }
      }
    } catch (e) {
      print("Error fetching fee: $e");
    }

    return 10.0; // سعر افتراضي في حال لم يتم العثور على الشارع في الخريطة
  }
}*/

  /*static double calculateTotalShipping({
    required List<CartItemModel> items,
    required AddressModelNew userAddress,
    required Map<String, AddressModelNew> storeAddresses,
    required Map<String, Map<String, Map<String, dynamic>>> addressDataMap,
  }) {
    double totalCollectionFee = 0; // إجمالي تكاليف المرور على المتاجر
    double deliveryFeeToUser = 0; // تكلفة التوصيل النهائية لبيت الزبون

    // 1. حصر المتاجر الفريدة
    final uniqueStoreIds = items.map((item) => item.storeId).toSet();

    // تتبع الأحياء لعدم دفع "رسوم دخول الحي" مرتين
    Set<String> visitedDistricts = {};

    for (var storeId in uniqueStoreIds) {
      final sAddress = storeAddresses[storeId];
      if (sAddress == null) continue;

      String districtKey = sAddress.district; // مثلاً: "الرمال"

      // 2. حساب تكلفة التجميع من المتجر (Collection Fee)
      // نذهب للخريطة لنجلب سعر التوصيل الخاص بحي "المتجر"
      double storeDistrictFee = _getFeeFromMap(
        addressDataMap: addressDataMap,
        governorate: sAddress.city,
        city: sAddress.district,
        street: sAddress.street,
      );

      if (!visitedDistricts.contains(districtKey)) {
        // أول متجر في هذا الحي: نأخذ القيمة كاملة من الخريطة
        totalCollectionFee += storeDistrictFee;
        visitedDistricts.add(districtKey);
      } else {
        // متجر آخر في نفس الحي: نأخذ رسوم رمزية (ثابتة) لأن المندوب متواجد بالفعل في الحي
        totalCollectionFee += 2.0;
      }
    }

    // 3. حساب تكلفة التوصيل النهائية (من مركز التوزيع إلى بيت الزبون)
    // نستخدم عنوان الزبون لجلب السعر من الخريطة
    deliveryFeeToUser = _getFeeFromMap(
      addressDataMap: addressDataMap,
      governorate: userAddress.city,
      city: userAddress.district,
      street: userAddress.street,
    );

    // الإجمالي = (تكلفة المرور على كل المتاجر) + (تكلفة الذهاب لبيت الزبون)
    return totalCollectionFee + deliveryFeeToUser;
  }

  static double _getFeeFromMap({
    required Map<String, Map<String, Map<String, dynamic>>> addressDataMap,
    required String governorate,
    required String city,
    required String street,
  }) {
    try {
      final fee = addressDataMap[governorate]?[city]?[street]?['fee'];
      return (fee as num?)?.toDouble() ?? 10.0;
    } catch (e) {
      return 10.0;
    }
  }
*/
  /*
class ShippingCalculatorService {
  // خارطة أسعار التوصيل بين المحافظات (أمثلة تقريبية)
  // يمكنك تعديل هذه القيم حسب تسعيرة المندوبين لديك
  static const Map<String, double> deliveryFees = {
    "نفس المنطقة": 5.0,
    "داخل المحافظة": 10.0,
    "محافظة مجاورة": 15.0,
    "بعيد (شمال إلى جنوب)": 20.0,
  };

  /// الدالة الرئيسية لحساب التكلفة الإجمالية
  static double calculateTotalShipping({
    required List<CartItemModel> items,
    required AddressModelNew userAddress,
    required Map<String, AddressModelNew>
    storeAddresses, // معرف المتجر مقابل عنوانه
  }) {
    double totalCollectionFee = 0;
    double maxDeliveryFee = 0;

    // 1. تجميع المتاجر الفريدة في الطلب
    final uniqueStoreIds = items.map((item) => item.storeId).toSet().toList();

    // 2. حساب رسوم التجميع من المتاجر
    // نستخدم "المنطقة" (District) كمقياس لمكان المتجر
    List<String> visitedDistricts = [];

    for (var storeId in uniqueStoreIds) {
      AddressModelNew? sAddress = storeAddresses[storeId];
      if (sAddress == null) continue;

      if (!visitedDistricts.contains(sAddress.district)) {
        // إذا كان المندوب سيذهب لمنطقة جديدة لم يزرها في هذا الطلب
        totalCollectionFee += deliveryFees["نفس المنطقة"]!;
        visitedDistricts.add(sAddress.district);
      } else {
        // إذا كان المتجر في منطقة زارها المندوب فعلاً (متجرين في نفس الحي)
        totalCollectionFee += 2.0; // رسوم إضافية بسيطة بدل تجميع من مكان قريب
      }

      // 3. تحديد تكلفة التوصيل النهائية بناءً على أبعد متجر عن الزبون
      double currentStoreDeliveryFee = _calculateDeliveryRate(
        sAddress,
        userAddress,
      );
      if (currentStoreDeliveryFee > maxDeliveryFee) {
        maxDeliveryFee = currentStoreDeliveryFee;
      }
    }

    return totalCollectionFee + maxDeliveryFee;
  }

  /// دالة داخلية لتحديد فئة السعر بين عنوانين
  static double _calculateDeliveryRate(
    AddressModelNew start,
    AddressModelNew end,
  ) {
    if (start.city == end.city) {
      if (start.district == end.district) {
        return deliveryFees["نفس المنطقة"]!;
      }
      return deliveryFees["داخل المحافظة"]!;
    }

    // منطق بسيط: إذا كان الشحن بين محافظات متباعدة جداً
    if ((start.city == "شمال غزة" && end.city == "رفح") ||
        (start.city == "رفح" && end.city == "شمال غزة")) {
      return deliveryFees["بعيد (شمال إلى جنوب)"]!;
    }

    return deliveryFees["محافظة مجاورة"]!;
  }
}*/
}
