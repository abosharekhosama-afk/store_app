import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:untitled2_ecom/features/personalization/models/address_model_new.dart';
import 'package:untitled2_ecom/features/shop/models/cart_item_model.dart';

class ShippingCalculatorService {
  /// الدالة الرئيسية لحساب التكلفة الإجمالية بناءً على بيانات الخريطة الديناميكية

  // دالة الحساب الرئيسية

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
}
