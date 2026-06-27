import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/exceptions/exports.dart';
import 'package:untitled2_ecom/utils/helpers/network_manager.dart';
import 'package:untitled2_ecom/utils/popups/exports.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  CollectionReference get productsCollection => _db.collection('Products');
  // في ملف ProductRepository
  Future<List<ProductModel>> getRandomProducts({
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      // الترتيب بناءً على الحقل العشوائي SortId
      Query query = _db.collection("Products").orderBy("SortId").limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapShot = await query.get();
      return snapShot.docs
          .map((e) => ProductModel.fromQuerySnapshot(e))
          .toList();
    } catch (e) {
      throw "حدث خطأ أثناء جلب المنتجات: $e";
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapShot = await _db
          .collection("Products")
          // .where("IsFeatured", isEqualTo: true)
          //.limit(4)
          .get();
      return snapShot.docs.map((e) => ProductModel.fromSnapshot(e)).toList();
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

  Future<List<ProductModel>> getAllFeaturedProducts() async {
    try {
      final snapShot = await _db
          .collection("Products")
          .where("IsFeatured", isEqualTo: true)
          .get();
      return snapShot.docs.map((e) => ProductModel.fromSnapshot(e)).toList();
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

  /// جلب المنتجات المشابهة بناءً على القسم أو الأوسمة
  Future<List<ProductModel>> getSimilarProducts({
    required String? categoryId,
    List<String>? tags,
    required String currentProductId,
    required ProductModel currentProduct,
    int limit = 6,
  }) async {
    try {
      // 1. استعلام أساسي لجلب المنتجات من نفس القسم

      // داخل ProductRepository في دالة getSimilarProducts:
      Query query;
      if (currentProduct.tags == null || currentProduct.tags!.isEmpty) {
        // إذا لم تكن هناك تاغات، اقلب الاستعلام فوراً ليعتمد على القسم (CategoryId) كـ Backup آمن
        query = _db
            .collection("Products")
            .where(TProductFields.categoryId, isEqualTo: categoryId);
      } else {
        query = _db
            .collection("Products")
            .where(TProductFields.tags, arrayContainsAny: currentProduct.tags);
      }

      /*    Query query = _db
          .collection("Products")
          .where(TProductFields.tags, arrayContainsAny: currentProduct.tags);
      //.where("CategoryId", isEqualTo: categoryId);
*/
      // 2. إذا كانت الأوسمة موجودة، يمكننا تصفية النتائج بناءً عليها (اختياري حسب منطق قاعدة بياناتك)
      // ملاحظة: Firestore لا يدعم عمل "where" مرتين على حقول مختلفة بـ "array-contains" بسهولة بدون اندكس مركب
      // لذا سنكتفي بالقسم حالياً أو نستخدم الأوسمة كفلتر إضافي برمجياً.

      final snapshot = await query.limit(limit + 1).get();

      // 3. تحويل النتائج واستبعاد المنتج الحالي
      final products = snapshot.docs
          .map((doc) => ProductModel.fromQuerySnapshot(doc))
          .where(
            (product) => product.id != currentProductId,
          ) // استثناء المنتج الحالي
          .take(limit) // التأكد من العودة بالعدد المطلوب فقط بعد الاستثناء
          .toList();

      return products;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } catch (e) {
      throw "حدث خطأ ما، يرجى المحاولة لاحقاً";
    }
  }

  // في كلاس ProductRepository
  Future<({List<ProductModel> products, DocumentSnapshot? lastDocument})>
  getProductsForPagination(
    Query query, {
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      var finalQuery = query.limit(limit);

      if (startAfterDocument != null) {
        finalQuery = finalQuery.startAfterDocument(startAfterDocument);
      }

      final querySnapshot = await finalQuery.get();
      final products = querySnapshot.docs
          .map((doc) => ProductModel.fromQuerySnapshot(doc))
          .toList();
      final lastDoc = querySnapshot.docs.isNotEmpty
          ? querySnapshot.docs.last
          : null;

      return (products: products, lastDocument: lastDoc);
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<ProductModel>> getAllProductsByQuery(Query query) async {
    try {
      final querySnapshot = await query.get();
      final List<ProductModel> productList = querySnapshot.docs
          .map((e) => ProductModel.fromQuerySnapshot(e))
          .toList();
      return productList;
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

  Future<List<ProductModel>> getProductForCategory({
    required String categoryId,
    int limit = 4,
  }) async {
    try {
      List<ProductModel> products = [];
      final snapShot = limit == -1
          ? await _db
                .collection(TProductFields.productsCollectionName)
                .where(TProductFields.categoryId, isEqualTo: categoryId)
                .get()
          : await _db
                .collection(TProductFields.productsCollectionName)
                .where(TProductFields.categoryId, isEqualTo: categoryId)
                .limit(limit)
                .get();

      List<ProductModel> productMd = snapShot.docs
          .map((e) => ProductModel.fromQuerySnapshot(e))
          .toList();
      products = productMd;

      return products;
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

  Future<List<ProductModel>> getFavouriteProducts(
    List<String> productsIds,
  ) async {
    try {
      final snapshot = await _db
          .collection("Products")
          .where(FieldPath.documentId, whereIn: productsIds)
          .get();
      final List<ProductModel> productList = snapshot.docs
          .map((e) => ProductModel.fromSnapshot(e))
          .toList();
      return productList;
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

  Future<void> uploadDummyData(List<ProductModel> products) async {
    try {
      // final storage = Get.put(TfirebaseStorageService());
      TFullScreenLoader.openLoadingDialog(
        "جارٍ تحميل البيانات...",
        TImages.docerAnimation,
      );
      for (var product in products) {
        final isConected = await NetworkManager.instance.isConnected();
        if (!isConected) {
          TFullScreenLoader.stopLoading();
          return;
        }

        /*final thumbanil = await storage.getImageDataFromAssets(
          product.thumbnail,
        );*/
        /*final url = await storage.uploadImageData(
          "Products/Images",
          thumbanil,
          product.thumbnail.toString(),
        );*/

        // product.thumbnail = url;
        // product list of images
        /*if (product.images != null && product.images!.isNotEmpty) {
          List<String> imageUrl = [];
          for (var image in product.images!) {
            final assetImage = await storage.getImageDataFromAssets(image);
            /*final url = await storage.uploadImageData(
              "Products/Images",
              assetImage,
              image,
            );*/
            imageUrl.add(url);
          }
          product.images!.clear();
          product.images!.addAll(imageUrl);
        }*/

        /*if (product.productType == ProductType.variable.toString()) {
          for (var variation in product.productVariation!) {
            final assetImage = await storage.getImageDataFromAssets(
              variation.image,
            );
            final url = await storage.uploadImageData(
              "Products/Images",
              assetImage,
              variation.image,
            );
            variation.image = url;
          }
        }*/
        await _db.collection("Products").doc(product.id).set(product.toJson());
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

  Future<List<ProductModel>> getProductForBrand({
    required String brandId,
    int limit = -1,
  }) async {
    try {
      final snapShot = limit == -1
          ? await _db
                .collection("Products")
                .where("Brande.Id", isEqualTo: brandId)
                .get()
          : await _db
                .collection("Products")
                .where("Brande.Id", isEqualTo: brandId)
                .limit(limit)
                .get();
      return snapShot.docs.map((e) => ProductModel.fromSnapshot(e)).toList();
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

  /*
  Future<List<ProductModel>> getProductForCategory({
    required String categoryId,
    int limit = 4,
  }) async {
    try {
      List<ProductModel> products = [];
      final snapShot = limit == -1
          ? await _db
                .collection("ProductCategory")
                .where("categoryId", isEqualTo: categoryId)
                .get()
          : await _db
                .collection("ProductCategory")
                .where("categoryId", isEqualTo: categoryId)
                .limit(limit)
                .get();

      List<String> productIds = snapShot.docs
          .map((e) => e["productId"] as String)
          .toList();

      print("***************************************");
      productIds.map((e) => print("****${e}****"));
      for (int i = 0; i < productIds.length; i++) {
        print("****${productIds[i]}****");
      }
      print(productIds.length);
      print("***************************************");
      if (productIds.isNotEmpty && productIds != 0) {
        final productQuery = await _db
            .collection("Products")
            .where(FieldPath.documentId, whereIn: productIds)
            .get();
        products = productQuery.docs
            .map((e) => ProductModel.fromSnapshot(e))
            .toList();
      }

      return products;
    } on FirebaseException catch (e) {
      TLoaders.errorSnackBar(title: "Oh Snap?10", message: e.toString());
      throw TFirebaseException(e.code).message;
    } on FormatException catch (e) {
      TLoaders.errorSnackBar(title: "Oh Snap?11", message: e.toString());
      throw TFormatException();
    } on PlatformException catch (e) {
      TLoaders.errorSnackBar(title: "Oh Snap?12", message: e.toString());
      throw TPlatformException(e.code).message;
    } catch (e) {
      TLoaders.errorSnackBar(title: "Oh Snap?133", message: e.toString());
      throw "somthing went wrong, pleas try agin";
    }
  }
*/
}
