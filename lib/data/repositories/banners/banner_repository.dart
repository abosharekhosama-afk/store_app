import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/features/shop/models/banner_model.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/exceptions/exports.dart';
import 'package:untitled2_ecom/utils/helpers/network_manager.dart';
import 'package:untitled2_ecom/utils/popups/exports.dart';

class BannerRepository extends GetxController {
  static BannerRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<List<BannerModel>> fetchBanners() async {
    try {
      final result = await _db
          .collection("Banners")
          .where("Acttive", isEqualTo: true)
          .get();
      return result.docs.map((e) => BannerModel.fromsnapshot(e)).toList();
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

  Future<void> uploadDummyData(List<BannerModel> banners) async {
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

      for (var banner in banners) {
        // final file = await stroage.getImageDataFromAssets(category.image);
        /* final url = await stroage.uploadImageData(
          "Categories",
          file,
          category.name,
        );*/
        // category.image = url;
        await _db.collection("Banners").doc().set(banner.toJson());
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
