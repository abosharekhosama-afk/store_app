import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2_ecom/enums.dart';
import 'package:untitled2_ecom/features/personalization/models/address_model_new.dart';
import 'package:untitled2_ecom/features/shop/models/cart_item_model.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class StoreOrdersModel {
  final String storeOrderId;
  final String mainOrderId;
  final String storeId;
  final List<CartItemModel> items;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? pickupDate;
  final AddressModelNew? userAddress;
  final String userId;
  final String pickupCode;
  final DeliveryStatus? deliveryStatus;
  final String? deliveryBoyId;

  StoreOrdersModel({
    required this.storeOrderId,
    required this.mainOrderId,
    required this.storeId,
    required this.items,
    required this.status,
    required this.orderDate,
    required this.pickupDate,
    required this.userAddress,
    required this.userId,
    required this.pickupCode,
    this.deliveryStatus,
    this.deliveryBoyId,
  });

  static String get getOrderCollectionName => "StoreOrders";
  static String get getMainOrderId => "MainOrderId";
  static String get getStoreId => "StoreId";
  static String get getItems => "Items";
  static String get getStatus => "Status";
  static String get getOrderDate => "OrderDate";
  static String get getPickupDate => "PickupDate";
  static String get getUserAddress => "UserAddress";
  static String get getUserId => "UserId";
  static String get getStoreOrderId => "StoreOrderId";
  static String get getPickupCode => "PickupCode";
  static String get getDeliveryStatus => "DeliveryStatus";
  static String get getDeliveryBoyId => "DeliveryBoyId";

  // --- التنسيق والعرض ---
  String get formattedOrderDate => THelperFunctions.getFormattedDate(orderDate);

  Map<String, dynamic> toJson() {
    return {
      getStoreOrderId: storeOrderId,
      getUserId: userId,
      getMainOrderId: mainOrderId,
      getStatus: status.name,
      getOrderDate: orderDate,
      getPickupDate: pickupDate,
      getUserAddress: userAddress?.toJson(),
      getItems: items.map((item) => item.toJson()).toList(),
      getStoreId: storeId,
      getPickupCode: pickupCode,
      getDeliveryStatus: deliveryStatus?.name,
      getDeliveryBoyId: deliveryBoyId,
    };
  }

  factory StoreOrdersModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return StoreOrdersModel(
      storeOrderId: snapshot.id,
      mainOrderId: data[getMainOrderId] as String,
      userId: data[getUserId] as String,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (data[getStatus] ?? OrderStatus.pending.name),
        orElse: () => OrderStatus.pending,
      ),
      orderDate: data[getOrderDate] != null
          ? (data[getOrderDate] as Timestamp).toDate()
          : DateTime.now(),

      pickupDate: data[getPickupDate] != null
          ? (data[getPickupDate] as Timestamp).toDate()
          : null,
      userAddress: data[getUserAddress] != null
          ? AddressModelNew.fromMap(data[getUserAddress])
          : null,
      items:
          (data[getItems] as List<dynamic>?)
              ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      storeId: data[getStoreId] ?? "",
      pickupCode: data[getPickupCode] ?? "",
      deliveryStatus: data[getDeliveryStatus] != null
          ? DeliveryStatus.values.firstWhere(
              (e) => e.name == data[getDeliveryStatus],
              orElse: () => DeliveryStatus.pickedUp,
            )
          : null,
      deliveryBoyId: data[getDeliveryBoyId] ?? null,
    );
  }
}
