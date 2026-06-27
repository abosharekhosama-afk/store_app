import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/features/personalization/models/user_model.dart';
import 'package:untitled2_ecom/wallet/model/TransactionModel.dart';

class WalletRepository extends GetxController {
  static WalletRepository get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // جلب أول 20 عملية أو جلب المزيد بناءً على آخر مستند
  Future<QuerySnapshot<Map<String, dynamic>>> getTransactionsPaged({
    required String userId,
    required int limit,
    DocumentSnapshot? lastDocument,
    TransactionType? typeFilter,
  }) async {
    Query query = _db
        .collection(UserModel.getUserCollectionName)
        .doc(userId)
        .collection(TransactionModel.getTransactionsCollectionName)
        .orderBy(TransactionModel.getDate, descending: true)
        .limit(limit);

    // إذا كان هناك فلتر لنوع العملية (مشتريات أو مستردات)
    // 2. 🌟 معالجة الفلتر الذكي للمرتجعات (سواء كانت refund أو partial_refund)
    if (typeFilter != null) {
      if (typeFilter == TransactionType.refund) {
        // الفايرستور سيجلب أي مستند يحتوي على "refund" أو "partial_refund" في حقل الـ type
        query = query.where('type', whereIn: ['refund', 'partial_refund']);
      } else {
        query = query.where('type', isEqualTo: typeFilter.name);
      }
    }

    // إذا كنا نريد جلب الصفحة التالية
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return await query.get() as QuerySnapshot<Map<String, dynamic>>;
  }

  // يبقى الرصيد كـ Stream لأنه يتغير نادراً ويجب أن يكون فورياً
  Stream<double> getWalletBalance(String userId) {
    return _db
        .collection(UserModel.getUserCollectionName)
        .doc(userId)
        .snapshots()
        .map((doc) => (doc.data()?['walletBalance'] ?? 0.0).toDouble());
  }
}

/*
class WalletRepository extends GetxController {
  static WalletRepository get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // جلب رصيد المحفظة الحالي
  Stream<UserModel> getWalletBalance(String userId) {
    return _db
        .collection(UserModel.getUserCollectionName)
        .doc(userId)
        .snapshots()
        .map((doc) {
          return (UserModel.fromSnapshot(doc));
        });
  }

  // جلب سجل العمليات
  Stream<List<TransactionModel>> getTransactions(String userId) {
    return _db
        .collection(UserModel.getUserCollectionName)
        .doc(userId)
        .collection(TransactionModel.getTransactionsCollectionName)
        .orderBy(TransactionModel.getDate, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromSnapshot(doc))
              .toList(),
        );
  }

  /* // دالة إضافة مبلغ للمحفظة (عند رفض منتج مثلاً)
  Future<void> addRefundToWallet(
    String userId,
    double amount,
    String orderId,
  ) async {
    final transaction = TransactionModel(
      id: Guid.newGuid().toString(),
      amount: amount,
      status: TransactionStatus.pending,
      type: TransactionType.refund,
      date: DateTime.now(),
      description: "استرجاع مبلغ منتج مرفوض من الطلب #$orderId",
    );

    // تحديث الرصيد وإضافة العملية في وقت واحد (Transaction)
    await _db.runTransaction((transactionBatch) async {
      DocumentReference userRef = _db.collection('Users').doc(userId);
      DocumentSnapshot userDoc = await transactionBatch.get(userRef);

      double currentBalance =
          (userDoc.data() as Map<String, dynamic>)['walletBalance'] ?? 0.0;
      transactionBatch.update(userRef, {
        'walletBalance': currentBalance + amount,
      });

      DocumentReference transRef = userRef.collection('Transactions').doc();
      transactionBatch.set(transRef, transaction.toJson());
    });
  }

  Future<void> addRefundToWallenewt(
    String userId,
    double amount,
    String orderId,
  ) async {
    final transaction = TransactionModel(
      id: Guid.newGuid().toString(),
      amount: amount,
      type: TransactionType.refund,
      status: TransactionStatus.completed, // حالة مكتملة
      date: DateTime.now(),
      description: "استرجاع مبلغ منتج من الطلب #$orderId",
    );

    await _db.runTransaction((transactionBatch) async {
      DocumentReference userRef = _db.collection('Users').doc(userId);
      // ... (نفس منطق التحديث السابق للرصيد)
    });
  }
*/
}*/
