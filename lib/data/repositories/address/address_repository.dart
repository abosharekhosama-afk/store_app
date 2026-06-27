import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:untitled2_ecom/features/personalization/models/address_model_new.dart';

class AddressRepository extends GetxController {
  static AddressRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<List<AddressModelNew>> fetchUserAddresses() async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;
      if (userId.isEmpty) {
        throw "Unable to find user information. Try agin in few minutes";
      }

      final documentSnapshot = await _db
          .collection("User")
          .doc(userId)
          .collection(AddressModelNew.getdAddressCollection)
          .get();
      final result = documentSnapshot.docs
          .map((e) => AddressModelNew.fromDocumentSnapshot(e))
          .toList();
      return result;
    } catch (e) {
      throw "Somthing went wrong while fetching Address Information. Try again later.....";
    }
  }

  Future<void> updateSelectedAddress(String addressId, bool selected) async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;
      await _db
          .collection("User")
          .doc(userId)
          .collection(AddressModelNew.getdAddressCollection)
          .doc(addressId)
          .update({AddressModelNew.getSelectedAddress: selected});
    } catch (e) {
      throw "Unable to update your address selection. Try agine later";
    }
  }

  Future<String> addAddresses(AddressModelNew address) async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;

      final currentAddress = await _db
          .collection("User")
          .doc(userId)
          .collection(AddressModelNew.getdAddressCollection)
          .add(address.toJson());
      return currentAddress.id;
    } catch (e) {
      throw "Somthing went wrong while fetching Address Information. Try again later";
    }
  }

  // جلب كافة البيانات من Firebase
  Future<List<Map<String, dynamic>>> fetchAllShippingData() async {
    try {
      final snapshot = await _db.collection('ShippingRates').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } on FirebaseException catch (e) {
      throw 'حدث خطأ في قاعدة البيانات: ${e.message}';
    } catch (e) {
      throw 'عذراً، حدث خطأ غير متوقع أثناء جلب البيانات.';
    }
  }
}
