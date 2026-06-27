import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled2_ecom/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:untitled2_ecom/features/personalization/models/user_model.dart';
import 'package:untitled2_ecom/utils/exceptions/exports.dart';

class UserReposity extends GetxController {
  static UserReposity get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /*Future<void> saveUserRecord(UserModel user) async {
    try {
      await _db.collection("User").doc(user.id).set(user.tojson());
    } on FirebaseException catch (e) {
      // اطبع تفاصيل الخطأ هنا
      print('Firebase Exception Code: ${e.code}');
      print('Firebase Exception Message: ${e.message}');
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      print('Format Exception'); // يمكنك إضافة تفاصيل هنا أيضًا
      throw TFormatException();
    } on PlatformException catch (e) {
      // اطبع تفاصيل الخطأ هنا
      print('Platform Exception Code: ${e.code}');
      print('Platform Exception Message: ${e.message}');
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('Generic Exception: $e'); // اطبع تفاصيل الخطأ العام
      throw "somthing went wrong, pleas try agin";
    }
  }*/

  Future<void> saveUserRecord(UserModel user) async {
    try {
      await _db
          .collection(UserModel.getUserCollectionName)
          .doc(user.id)
          .set(user.tojson());
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

  Future<UserModel> fetchUserDetails() async {
    try {
      final documentSnapshot = await _db
          .collection(UserModel.getUserCollectionName)
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .get();
      if (documentSnapshot.exists) {
        return UserModel.fromSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
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

  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _db
          .collection(UserModel.getUserCollectionName)
          .doc(updatedUser.id)
          .update(updatedUser.tojson());
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

  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db
          .collection(UserModel.getUserCollectionName)
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .update(json);
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

  Future<void> removeUserRecord(String userId) async {
    try {
      await _db
          .collection(UserModel.getUserCollectionName)
          .doc(userId)
          .delete();
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

  Future<String> uploadImage(String path, XFile image) async {
    try {
      // استخدام اسم فريد أو تنظيف الاسم الأصلي من أي مسافات للحماية
      final String fileName = image.name.replaceAll(' ', '_');
      final ref = FirebaseStorage.instance.ref(path).child(fileName);

      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw "حدث خطأ غير متوقع أثناء رفع الصورة. الرجاء المحاولة مجدداً";
    }
  }
}
