import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { purchase, refund, deposit, bank_withdrawal }

enum TransactionStatus { pending, completed, failed } // الحالة الجديدة

class TransactionModel {
  final String id;
  final double amount;
  final TransactionType type;
  final TransactionStatus status; // الحقل الجديد
  final DateTime date;
  final String description;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.date,
    required this.description,
  });

  static String get getTransactionsCollectionName => "Transactions";
  static String get getId => "id";
  static String get getAmount => "amount";
  static String get getType => "type";
  static String get getStatus => "status";
  static String get getDate => "date";
  static String get getDescription => "description";

  Map<String, dynamic> toJson() => {
    getId: id,
    getAmount: amount,
    getType: type.name,
    getStatus: status.name, // حفظ الحالة كـ String
    getDate: date,
    getDescription: description,
  };

  factory TransactionModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;

    // معالجة التاريخ ليدعم 'date' أو 'createdAt' منعاً للاختفاء
    Timestamp? timestamp = data[getDate] as Timestamp?;
    timestamp ??= data['createdAt'] as Timestamp?;
    DateTime parsedDate = timestamp != null
        ? timestamp.toDate()
        : DateTime.now();

    return TransactionModel(
      id: data[getId] ?? '',
      // تحويل آمن من int64 أو double
      amount: (data[getAmount] ?? 0.0).toDouble(),
      // معالجة مرنة لقراءة النوع من قاعدة البيانات
      type: (data[getType] == 'refund' || data[getType] == 'partial_refund')
          ? TransactionType.refund
          : TransactionType.values.firstWhere(
              (e) => e.name == data[getType],
              orElse: () => TransactionType.purchase,
            ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data[getStatus],
        orElse: () => TransactionStatus.completed,
      ),
      date: parsedDate,
      description: data[getDescription] ?? '',
    );
  }

  /*factory TransactionModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return TransactionModel(
      id: data['id'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == data['type']),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TransactionStatus.completed,
      ),
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] ?? '',
    );
  }*/
}
