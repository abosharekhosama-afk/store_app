import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:untitled2_ecom/features/shop/models/order_model.dart';

class OrderReposity {
  static get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;
      if (userId.isEmpty) {
        throw "Unable to find user information. Try again in few minutes.";
      }
      final result = await _db
          .collection("User")
          .doc(userId)
          .collection(OrderModel.getOrderCollectionName)
          .get();
      return result.docs
          .map((docSnap) => OrderModel.fromSnapshot(docSnap))
          .toList();
    } catch (e) {
      throw "Somthing went wrong while saving Order Information. Try again later...";
    }
  }

  Future<void> saveOrder(OrderModel order, String userId) async {
    try {
      if (userId.isEmpty) {
        throw "Unable to find user information. Try again in few minutes.";
      }

      await _db
          .collection("User")
          .doc(userId)
          .collection(OrderModel.getOrderCollectionName)
          .add(order.toJson());
    } catch (e) {
      throw "Somthing went wrong while saving Order Information. Try again later...";
    }
  }
}
