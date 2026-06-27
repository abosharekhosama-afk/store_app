import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/features/shop/models/brand_category_model.dart';
import 'package:untitled2_ecom/features/shop/models/brand_model.dart';
import 'package:untitled2_ecom/features/shop/models/product_category_model.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/exceptions/exports.dart';
import 'package:untitled2_ecom/utils/helpers/network_manager.dart';
import 'package:untitled2_ecom/utils/popups/exports.dart';

class BrandRepository extends GetxController {
  static BrandRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<List<BrandModel>> getAllBrands() async {
    try {
      final snapshot = await _db.collection("Brands").get();
      final result = snapshot.docs
          .map((e) => BrandModel.fromSnapshot(e))
          .toList();
      return result;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
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

  Future<List<BrandModel>> getBrandForCategory(String categoryId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("BrandCategory")
          .where("categoryId", isEqualTo: categoryId)
          .get();
      List<String> brandIds = snapshot.docs
          .map((e) => e["brandId"] as String)
          .toList();
      final brandsQuery = await _db
          .collection("Brands")
          .where("Id", whereIn: brandIds)
          .limit(2)
          .get();
      List<BrandModel> brands = brandsQuery.docs
          .map((e) => BrandModel.fromSnapshot(e))
          .toList();
      return brands;
    } on FirebaseException catch (e) {
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
      throw TFirebaseException(e.code).message;
    } on FormatException catch (e) {
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
      throw TFormatException();
    } on PlatformException catch (e) {
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
      throw TPlatformException(e.code).message;
    } catch (e) {
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
      throw "حدث خطأ ما، يرجى المحاولة لاحقاً";
    }
  }

  Future<void> uploadDummyData(List<BrandModel> Brands) async {
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

      for (var brand in Brands) {
        // final file = await stroage.getImageDataFromAssets(category.image);
        /* final url = await stroage.uploadImageData(
          "Categories",
          file,
          category.name,
        );*/
        // category.image = url;
        await _db.collection("Brands").doc().set(brand.toJson());
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

  Future<void> uploadDummyDataForBranndAndProductForCategory(
    List<BrandCategoryModel> brands,
    List<ProductCategoryModel> products,
  ) async {
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

      for (var brand in brands) {
        // final file = await stroage.getImageDataFromAssets(category.image);
        /* final url = await stroage.uploadImageData(
          "Categories",
          file,
          category.name,
        );*/
        // category.image = url;
        await _db.collection("BrandCategory").doc().set(brand.toJson());
      }
      for (var product in products) {
        // final file = await stroage.getImageDataFromAssets(category.image);
        /* final url = await stroage.uploadImageData(
          "Categories",
          file,
          category.name,
        );*/
        // category.image = url;
        await _db.collection("ProductCategory").doc().set(product.toJson());
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
}
