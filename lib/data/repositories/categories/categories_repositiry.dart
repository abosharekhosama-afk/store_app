import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/features/shop/models/category_model.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/exceptions/exports.dart';
import 'package:untitled2_ecom/utils/helpers/network_manager.dart';
import 'package:untitled2_ecom/utils/popups/exports.dart';

class CategoriesRepositiry extends GetxController {
  static CategoriesRepositiry get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await _db.collection("Categories").get();
      final list = snapshot.docs
          .map((e) => CategoryModel.fromSnapshot(e))
          .toList();
      return list;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw "somthing went wrong, pleas try agin";
    }
  }

  Future<void> uploadDummyData(List<CategoryModel> categories) async {
    try {
      //final stroage = Get.put(TfirebaseStorageService());
      TFullScreenLoader.openLoadingDialog(
        "جارٍ تحميل البيانات...",
        TImages.docerAnimation,
      );

      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      for (var category in categories) {
        // final file = await stroage.getImageDataFromAssets(category.image);
        /* final url = await stroage.uploadImageData(
          "Categories",
          file,
          category.name,
        );*/
        // category.image = url;
        await _db
            .collection("Categories")
            .doc(category.id)
            .set(category.toJson());
      }
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
        title: "تهانينا",
        message: "تم تحميل جميع البيانات.",
      );
    } on FirebaseException catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "خطأ", message: e);
      throw TFirebaseException(e.code).message;
    } on FormatException catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "خطأ", message: e);
      throw TFormatException();
    } on PlatformException catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "خطأ", message: e);
      throw TPlatformException(e.code).message;
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "خطأ", message: e);
      throw "حدث خطأ ما، يرجى المحاولة لاحقاً";
    }
  }

  Future<List<CategoryModel>> getSubCategory(String categorieId) async {
    try {
      final snapshot = await _db
          .collection("Categories")
          .where("ParentId", isEqualTo: categorieId)
          .get();
      final result = snapshot.docs
          .map((e) => CategoryModel.fromSnapshot(e))
          .toList();
      return result;
    } on FirebaseException catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "خطأ", message: e);
      throw TFirebaseException(e.code).message;
    } on FormatException catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "خطأ", message: e);
      throw TFormatException();
    } on PlatformException catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "خطأ", message: e);
      throw TPlatformException(e.code).message;
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "خطأ", message: e);
      throw "حدث خطأ ما، يرجى المحاولة لاحقاً";
    }
  }
}
