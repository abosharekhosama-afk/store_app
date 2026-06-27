import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:untitled2_ecom/data/repositories/product/product_repository.dart';
import 'package:untitled2_ecom/features/personalization/models/user_stor_model.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/utils/popups/loaders.dart';

class StoreDetailsController extends GetxController {
  static StoreDetailsController get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  Rx<StoreModel> selectedStore = StoreModel.empty().obs;
  final isLoding = false.obs;
  final isMoreLoding = false.obs;
  final hasMoreData = true.obs;
  DocumentSnapshot? lastDocument;
  final productRepository = Get.put(ProductRepository());
  final _productsBox = Hive.box<ProductModel>('store_products');

  @override
  void onInit() {
    // جلب المتجر الممرر عبر الـ arguments وإسناده قبل بدء جلب البيانات
    if (Get.arguments != null && Get.arguments is StoreModel) {
      selectedStore.value = Get.arguments as StoreModel;
    }

    fetchFeaturedProducts();
    super.onInit();
  }

  // الجلب الأول (أول 20 منتج)
  void fetchFeaturedProducts() async {
    try {
      isLoding.value = true;
      lastDocument = null;
      hasMoreData.value = true;

      // --- خطوة Hive: جلب البيانات المحلية أولاً ---
      if (_productsBox.isNotEmpty) {
        final localProducts = _productsBox.values.toList();
        localProducts.shuffle(); // خلط البيانات المحلية للعشوائية
        featuredProducts.assignAll(localProducts);
        // لا نغلق الـ Loading هنا لأننا سنحدث البيانات في الخلفية
      }

      // --- خطوة Firebase: جلب البيانات الجديدة من السيرفر ---
      final query = FirebaseFirestore.instance
          .collection(TProductFields.productsCollectionName)
          .where(TProductFields.storId, isEqualTo: selectedStore.value.storeId)
          .orderBy(TProductFields.sortId)
          .limit(20);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
        final products = snapshot.docs
            .map((e) => ProductModel.fromSnapshot(e))
            .toList();

        products.shuffle();
        featuredProducts.assignAll(products);

        // --- خطوة Hive: تحديث التخزين المحلي بالمجموعة الجديدة ---
        await _productsBox.clear(); // نمسح القديم
        await _productsBox.addAll(products); // نخزن أول 20 منتج جديد
      }

      if (snapshot.docs.length < 20) hasMoreData.value = false;
    } catch (e) {
      if (featuredProducts.isEmpty) {
        TLoaders.errorSnackBar(
          title: "أوه!",
          message: "تأكد من اتصالك بالإنترنت",
        );
      }
    } finally {
      isLoding.value = false;
    }
  }

  void fetchMoreProducts() async {
    if (isMoreLoding.value || !hasMoreData.value) return;

    try {
      isMoreLoding.value = true;

      final query = FirebaseFirestore.instance
          .collection(TProductFields.productsCollectionName)
          .where(TProductFields.storId, isEqualTo: selectedStore.value.storeId)
          .orderBy(TProductFields.sortId)
          .startAfterDocument(lastDocument!)
          .limit(15);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
        final newProducts = snapshot.docs
            .map((e) => ProductModel.fromSnapshot(e))
            .toList();

        newProducts.shuffle();
        featuredProducts.addAll(newProducts);

        // اختياري: إذا أردت جعل المنتجات الجديدة متاحة أوفلاين أيضاً
        await _productsBox.addAll(newProducts);
      }

      if (snapshot.docs.length < 20) hasMoreData.value = false;
    } catch (e) {
      print("Error fetching more: ${e.toString()}");
    } finally {
      isMoreLoding.value = false;
    }
  }
}
