import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/enums.dart';
import 'package:untitled2_ecom/features/personalization/models/user_stor_model.dart';
import 'package:untitled2_ecom/features/shop/models/cart_item_model.dart';
import 'package:untitled2_ecom/features/shop/models/order_model.dart';
import 'package:untitled2_ecom/features/shop/models/store_orders_model.dart';

class OrderRepository extends GetxController {
  static OrderRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /* ------------------ وظيفة حفظ وتقسيم الطلب ------------------ */
  Future<void> saveOrder(OrderModel order) async {
    try {
      final mainOrderRef = _db
          .collection(OrderModel.getOrderCollectionName)
          .doc(order.id);

      await mainOrderRef.set(order.toJson());

      print("✅ تم حفظ الطلب الرئيسي بنجاح، بانتظار الدفع...");
    } catch (e) {
      throw 'حدث خطأ أثناء حفظ الطلب: $e';
    }
  }

  /*
  Future<void> saveOrder(OrderModel order) async {
    try {
      final batch = _db.batch();

      // 1. حفظ الطلب الرئيسي في مجموعة "Orders" (للمستخدم والأدمن)
      final mainOrderRef = _db
          .collection(OrderModel.getOrderCollectionName)
          .doc(order.id);
      batch.set(mainOrderRef, order.toJson());

      // 2. تقسيم الطلب إلى "StoreOrders" (لكل متجر مستند منفصل)
      for (String storeId in order.storeIds) {
        final storeItems = order.getItemsByStore(storeId);

        // إنشاء مرجع جديد في مجموعة طلبات المتاجر
        final storeOrderRef = _db
            .collection(StoreOrdersModel.getOrderCollectionName)
            .doc();

        final generatedCode = (100000 + Random().nextInt(900000)).toString();
        final storOrders = StoreOrdersModel(
          mainOrderId: order.id,
          storeId: storeId,
          items: (storeItems.map((item) => item).toList()),
          status: OrderStatus.pending,
          orderDate: order.orderDate,
          userAddress: order.address,
          userId: order.userId,
          storeOrderId: "",
          pickupCode: generatedCode.toString(),
          pickupDate: null,
        );

        batch.set(storeOrderRef, storOrders.toJson());

        /*batch.set(storeOrderRef, {
          'mainOrderId': order.id,
          'storeId': storeId,
          'items': storeItems.map((item) => item.toJson()).toList(),
          'status': 'pending', // حالة طلب المتجر
          'orderDate': order.orderDate,
          'userAddress': order.address?.toJson(),
          'userId': order.userId,
        });*/
      }

      // تنفيذ جميع العمليات دفعة واحدة
      await batch.commit();
    } catch (e) {
      throw 'حدث خطأ أثناء حفظ الطلب: $e';
    }
  }
*/
  /* ------------------ وظيفة للمتجر: جلب طلباته فقط ------------------ */
  Stream<List<Map<String, dynamic>>> getStoreOrders(String storeId) {
    return _db
        .collection(StoreOrdersModel.getOrderCollectionName)
        .where(StoreOrdersModel.getStoreId, isEqualTo: storeId)
        .orderBy(StoreOrdersModel.getOrderDate, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /* ------------------ وظيفة للمندوب: جلب ما هو جاهز للاستلام ------------------ */
  Stream<List<Map<String, dynamic>>> getReadyForPickupOrders() {
    return _db
        .collection(StoreOrdersModel.getOrderCollectionName)
        .where(StoreOrdersModel.getStatus, isEqualTo: 'readyForPickup')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /* ------------------ تحديث حالة عنصر (قبول/رفض) مع معالجة مالية ------------------ */
  Future<void> updateStoreItemStatus(
    String storeOrderId,
    String mainOrderId,
    String productId,
    ItemStatus newStatus,
  ) async {
    try {
      await _db.runTransaction((transaction) async {
        // 1. جلب مستند المتجر
        final storeOrderRef = _db
            .collection(StoreOrdersModel.getOrderCollectionName)
            .doc(storeOrderId);
        final mainOrderRef = _db
            .collection(OrderModel.getOrderCollectionName)
            .doc(mainOrderId);

        DocumentSnapshot storeSnap = await transaction.get(storeOrderRef);
        DocumentSnapshot mainSnap = await transaction.get(mainOrderRef);

        if (!storeSnap.exists || !mainSnap.exists) return;

        // 2. تحديث قائمة العناصر في مستند المتجر
        List<CartItemModel> items = storeSnap[StoreOrdersModel.getItems];
        double priceToRefund = 0.0;

        for (var item in items) {
          if (item.productId == productId) {
            item.itemStatus = newStatus;
            if (newStatus == ItemStatus.rejected) {
              priceToRefund = (item.price * item.quantity).toDouble();
            }
          }
        }

        // 3. إذا كان هناك رفض، نحدث المبلغ المرتجع في الطلب الرئيسي
        if (newStatus == ItemStatus.rejected && priceToRefund > 0) {
          transaction.update(mainOrderRef, {
            OrderModel.getRejectedAmount: FieldValue.increment(priceToRefund),
          });
        }

        // 4. تحديث مستند المتجر بالعناصر الجديدة
        transaction.update(storeOrderRef, {StoreOrdersModel.getItems: items});
      });
    } catch (e) {
      throw 'فشل تحديث الحالة: $e';
    }
  }

  /// جلب الطلبات على دفعات (Pagination) باستخدام Future
  Future<Map<String, dynamic>> fetchUserOrdersPaginated({
    required String userId,
    required int limit,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      // 1. بناء الاستعلام الأساسي
      Query query = _db
          .collection(OrderModel.getOrderCollectionName)
          .where(OrderModel.getUserId, isEqualTo: userId)
          .orderBy('OrderDate', descending: true)
          .limit(limit);

      // 2. إذا كان هناك مستند سابق، ابدأ القراءة من بعده
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();

      // 3. تحويل المستندات إلى نماذج OrderModel
      final orders = querySnapshot.docs
          .map((doc) => OrderModel.fromSnapshot(doc))
          .toList();

      // 4. الاحتفاظ بآخر مستند لمعرفة نقطة البداية في المرة القادمة
      final lastDoc = querySnapshot.docs.isNotEmpty
          ? querySnapshot.docs.last
          : null;

      return {'orders': orders, 'lastDocument': lastDoc};
    } on FirebaseException catch (e) {
      throw 'خطأ في قاعدة البيانات: ${e.message}';
    } catch (e) {
      throw 'حدث خطأ غير متوقع: $e';
    }
  }

  /*
  Stream<List<OrderModel>> fetchUserOrders(String userId) {
    try {
      return _db
          .collection(OrderModel.getOrderCollectionName)
          .where(
            OrderModel.getUserId,
            isEqualTo: userId,
          ) // تأكد أن المسمى يطابق ما في toJson
          .orderBy('OrderDate', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => OrderModel.fromSnapshot(doc))
                .toList(),
          );
    } catch (e) {
      throw 'حدث خطأ أثناء جلب الطلبات: $e';
    }
  }
*/
  /// جلب بيانات متجر واحد باستخدام المعرف (ID)
  Future<StoreModel> getStoreById(String storeId) async {
    try {
      final documentSnapshot = await _db
          .collection("Stores")
          .doc(storeId)
          .get();

      if (documentSnapshot.exists) {
        return StoreModel.fromSnapshot(documentSnapshot);
      } else {
        // في حال لم يعثر على المتجر، نعيد كائن فارغ أو نلقي استثناء
        return StoreModel.empty();
      }
    } on FirebaseException catch (e) {
      throw 'خطأ في قاعدة البيانات: ${e.message}';
    } catch (e) {
      throw 'حدث خطأ غير متوقع:12 $e';
    }
  }

  /// دالة تأكيد الاستلام بواسطة المندوب باستخدام الرمز
  Future<bool> verifyAndCompleteOrder(
    String mainOrderId,
    String inputCode,
  ) async {
    try {
      return await _db.runTransaction((transaction) async {
        final orderRef = _db
            .collection(OrderModel.getOrderCollectionName)
            .doc(mainOrderId);
        final snapshot = await transaction.get(orderRef);

        if (!snapshot.exists) throw 'الطلب غير موجود';

        final String correctCode = snapshot[OrderModel.getDeliveryCode];

        // التحقق من الرمز
        if (correctCode == inputCode) {
          // إذا تطابق الرمز، نغير حالة الطلب الرئيسي
          transaction.update(orderRef, {
            OrderModel.getStatus: OrderStatus.delivered.toString(),
            OrderModel.getDeliveryDate: DateTime.now(),
          });

          // ملاحظة: يجب أيضاً تحديث مستندات StoreOrders المرتبطة بهذا الطلب
          // يمكنك جلبها وتحديث حالتها إلى delivered أيضاً هنا
          return true;
        } else {
          throw 'رمز الاستلام غير صحيح، يرجى التأكد من العميل.';
        }
      });
    } catch (e) {
      throw e.toString();
    }
  }
}
