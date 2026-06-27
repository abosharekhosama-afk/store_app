import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:untitled2_ecom/data/repositories/product/product_repository.dart';
import 'package:untitled2_ecom/features/shop/controllers/home_controller.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/utils/popups/exports.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();
  RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  RxList<ProductModel> simaelerProducts = <ProductModel>[].obs;
  final isLoding = false.obs;
  final isLodingSimeler = false.obs;
  final isMoreLoding = false.obs;
  final hasMoreData = true.obs;
  DocumentSnapshot? lastDocument;
  final scrollController = ScrollController();
  final productRepository = Get.put(ProductRepository());

  RxList<ProductModel> searchResults = <ProductModel>[].obs;
  final isSearchLoading = false.obs;
  RxString searchQuery = ''.obs;
  DocumentSnapshot? lastSearchDoc; // لحفظ آخر مستند في نتائج البحث
  final isMoreSearchLoading = false.obs;
  final hasMoreSearchData = true.obs;
  final _productsBox = Hive.box<ProductModel>('featured_products');

  // متغير لمراقبة هل الهيدر ظاهر أم لا
  var isHeaderVisible = true.obs;
  final scrollOffset = 0.0.obs;
  final searchTextFieldController = TextEditingController();
  var isCollapsedPersisted = false.obs;
  // 🌟 هذا المتغير يعبر عن حالة اكتمال تحميل المنتج الأساسي المعروض حالياً
  var isBaseProductLoaded = false.obs;
  @override
  void onInit() {
    fetchFeaturedProducts();

    scrollController.addListener(() {
      // 1. تحديث قيمة الأوفست
      scrollOffset.value = scrollController.offset;

      // 2. حساب العتبة ديناميكياً وثبات الحالة
      // تم تثبيت الحسابات برقم تقريبي مستقر (300 - 56 - 90 = 154) لمنع قفزات الأبعاد
      double threshold = 154.0;

      // التحديث الذكي: لا نحدث القيمة إلا إذا تغيرت الحالة فعلياً لمنع الـ Lag
      bool currentCollapsed = scrollController.offset >= threshold;
      if (isCollapsedPersisted.value != currentCollapsed) {
        isCollapsedPersisted.value = currentCollapsed;
      }

      // 3. التحكم في ظهور الهيدر
      if (scrollController.offset > 50) {
        if (isHeaderVisible.value) isHeaderVisible.value = false;
      } else {
        if (!isHeaderVisible.value) isHeaderVisible.value = true;
      }

      // 4. جلب المزيد من البيانات عند الوصول للنهاية

      // إذا تصفح المستخدم 80% من الشاشة الحالية، ابدأ بجلب الـ 20 منتج القادمة فوراً في الخلفية
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 400) {
        if (searchQuery.value.isNotEmpty) {
          fetchMoreSearchResults();
        } else {
          fetchMoreProducts();
        }
      }
    });

    // Debounce للبحث
    debounce(searchQuery, (callback) {
      searchProducts(callback.toString());
    }, time: const Duration(milliseconds: 500));

    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchTextFieldController.dispose(); // تنظيف حقل البحث
    super.onClose();
  }

  /*
  @override
  void onInit() {
    fetchFeaturedProducts();

    // مستمع واحد ذكي للتحكم في نوع الجلب (بحث أم منتجات عادية)
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        if (searchQuery.value.isNotEmpty) {
          fetchMoreSearchResults(); // إذا كان هناك نص بحث، اجلب المزيد من النتائج
        } else {
          fetchMoreProducts(); // إذا لم يكن هناك بحث، اجلب المنتجات العادية
        }
      }
    });

    // Debounce للبحث
    debounce(searchQuery, (callback) {
      searchProducts(callback.toString());
    }, time: const Duration(milliseconds: 500));

    // إضافة مستمع للتمرير

    // 3. إضافة الـ Listener لتحديث القيمة عند كل حركة تمرير
    scrollController.addListener(() {
      // تحديث قيمة الـ RxDouble
      scrollOffset.value = scrollController.offset;
    });
    

    scrollController.addListener(() {
      // إذا نزل المستخدم أكثر من 50 بكسل (يمكنك تعديل الرقم)، نُفعل الـ SafeArea
      if (scrollController.offset > 50) {
        if (isHeaderVisible.value) isHeaderVisible.value = false;
      } else {
        if (!isHeaderVisible.value) isHeaderVisible.value = true;
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }*/

  /// 1. القائمة المفلترة للمنتجات المميزة (الموجهة لشاشتك الرئيسية)
  List<ProductModel> get activeFeaturedProducts {
    // جلب قائمة الـ IDs المحظورة من الكنترولر المسؤول (تأكد من كتابة اسم الكنترولر الصحيح لديك)
    final List<String> blockedStoreIds =
        Get.find<HomeController>().blockedStoreIds;

    if (blockedStoreIds.isEmpty) return featuredProducts;

    // استبعاد أي منتج يتبع لمتجر محظور
    return featuredProducts
        .where((product) => !blockedStoreIds.contains(product.storId))
        .toList();
  }

  /// 2. القائمة المفلترة لنتائج البحث
  List<ProductModel> get activeSearchResults {
    final List<String> blockedStoreIds =
        Get.find<HomeController>().blockedStoreIds;

    if (blockedStoreIds.isEmpty) return searchResults;

    return searchResults
        .where((product) => !blockedStoreIds.contains(product.storId))
        .toList();
  }

  /// 3. القائمة المفلترة للمنتجات المشابهة
  List<ProductModel> get activeSimilarProducts {
    final List<String> blockedStoreIds =
        Get.find<HomeController>().blockedStoreIds;

    if (blockedStoreIds.isEmpty) return simaelerProducts;

    return simaelerProducts
        .where((product) => !blockedStoreIds.contains(product.storId))
        .toList();
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
          .collection("Products")
          .orderBy("SortId")
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
          .collection("Products")
          .orderBy("SortId")
          .startAfterDocument(lastDocument!)
          .limit(20);

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

  // 🌟 دالة احترافية تراقب تحميل الصورة الأساسية للمنتج قبل جلب المنتجات المشابهة
  void fetchSimilarProductsAfterImageLoad({
    required String? categoryId,
    required String currentProductId,
    required ProductModel currentProduct,
  }) {
    // إذا لم تكن هناك صورة للمنتج (حالة نادرة)، اجلب المنتجات المشابهة فوراً
    if (currentProduct.thumbnail.isEmpty) {
      fetchSimelarProducts(categoryId, currentProductId, currentProduct);
      return;
    }

    // إنشاء مرجع للصورة المتواجدة على الشبكة
    final ImageProvider imageProvider = NetworkImage(currentProduct.thumbnail);

    // حل وحيد ومستقر لمعرفة هل الصورة تم تحميلها بالكامل أم لا
    final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);

    final ImageStreamListener listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        // 🔥 هنا السحر: الصورة انتهت من التحميل بالكامل وظهرت للمستخدم!
        // نطلق استدعاء المنتجات المشابهة الآن بأمان دون تداخل بالشبكة
        if (simaelerProducts.isEmpty && !isLodingSimeler.value) {
          fetchSimelarProducts(categoryId, currentProductId, currentProduct);
        }
      },
      onError: (exception, stackTrace) {
        // في حال حدوث خطأ في تحميل الصورة بسبب ضعف الشبكة، نجلب المنتجات أيضاً كـ Backup
        if (simaelerProducts.isEmpty && !isLodingSimeler.value) {
          fetchSimelarProducts(categoryId, currentProductId, currentProduct);
        }
      },
    );

    stream.addListener(listener);
  }

  /*
  void fetchFeaturedProducts() async {
    try {
      isLoding.value = true;
      lastDocument = null;
      hasMoreData.value = true;

      // جلب البيانات مع الـ Snapshot للتحكم في الـ Pagination
      final query = FirebaseFirestore.instance
          .collection("Products")
          .orderBy("SortId")
          .limit(20);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
        final products = snapshot.docs
            .map((e) => ProductModel.fromSnapshot(e))
            .toList();

        // خلط محلي لزيادة العشوائية بين المتاجر
        products.shuffle();
        featuredProducts.assignAll(products);
      }

      if (snapshot.docs.length < 20) hasMoreData.value = false;
    } catch (e) {
      TLoaders.errorSnackBar(title: "أوه!", message: e.toString());
    } finally {
      isLoding.value = false;
    }
  }

  // جلب المزيد (عند التمرير)
  void fetchMoreProducts() async {
    if (isMoreLoding.value || !hasMoreData.value) return;

    try {
      isMoreLoding.value = true;

      final query = FirebaseFirestore.instance
          .collection("Products")
          .orderBy("SortId")
          .startAfterDocument(lastDocument!)
          .limit(20);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
        final newProducts = snapshot.docs
            .map((e) => ProductModel.fromSnapshot(e))
            .toList();

        newProducts.shuffle(); // خلط المجموعة الجديدة
        featuredProducts.addAll(newProducts);
      }

      if (snapshot.docs.length < 20) hasMoreData.value = false;
    } catch (e) {
      print(e.toString());
    } finally {
      isMoreLoding.value = false;
    }
  }
*/

  void searchProducts(String query) async {
    final trimmedQuery = query.trim();

    // 1. تحديث قيمة المتغير المُرَاقب ليعلم الـ UI بالحالة الجديدة فوراً
    searchQuery.value = trimmedQuery;

    lastSearchDoc = null; // إعادة ضبط مؤشر الباجينيشن
    hasMoreSearchData.value = true;

    // إذا قام المستخدم بتفريغ النص وضغط بحث، نظف النتائج وعد للمنتجات المميزة
    if (trimmedQuery.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearchLoading.value = true;
      final lowercaseQuery = trimmedQuery.toLowerCase();

      final snapshot = await FirebaseFirestore.instance
          .collection("Products")
          .where("SearchKeywords", arrayContains: lowercaseQuery)
          .limit(20)
          .get();

      if (snapshot.docs.isNotEmpty) {
        lastSearchDoc = snapshot.docs.last;
        searchResults.assignAll(
          snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList(),
        );
      } else {
        searchResults.clear();
      }
      hasMoreSearchData.value = snapshot.docs.length == 20;
    } catch (e) {
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
    } finally {
      isSearchLoading.value = false;
    }
  }

  /*
  // دالة البحث: قمت بإضافة تنظيف للنتائج القديمة عند بدء بحث جديد
  void searchProducts(String query) async {
    lastSearchDoc = null; // إعادة ضبط المؤشر
    hasMoreSearchData.value = true;

    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearchLoading.value = true;
      final lowercaseQuery = query.toLowerCase();

      final snapshot = await FirebaseFirestore.instance
          .collection("Products")
          .where("SearchKeywords", arrayContains: lowercaseQuery)
          .limit(20)
          .get();

      if (snapshot.docs.isNotEmpty) {
        lastSearchDoc = snapshot.docs.last;
        searchResults.assignAll(
          snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList(),
        );
      } else {
        searchResults.clear();
      }
      hasMoreSearchData.value = snapshot.docs.length == 20;
    } catch (e) {
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
    } finally {
      isSearchLoading.value = false;
    }
  }
*/
  // دالة جلب المزيد (Fetch More) تبقى كما هي ولكن مع تغيير الـ where
  void fetchMoreSearchResults() async {
    if (isMoreSearchLoading.value || !hasMoreSearchData.value) return;

    try {
      isMoreSearchLoading.value = true;
      final query = FirebaseFirestore.instance
          .collection("Products")
          .where(
            "SearchKeywords",
            arrayContains: searchQuery.value.toLowerCase(),
          )
          .startAfterDocument(lastSearchDoc!)
          .limit(20);

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        lastSearchDoc = snapshot.docs.last;
        searchResults.addAll(
          snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList(),
        );
      }
      if (snapshot.docs.length < 20) hasMoreSearchData.value = false;
    } finally {
      isMoreSearchLoading.value = false;
    }
  }

  /*
  // --- دالة البحث الأساسية (أول 20 نتيجة) ---
  void searchProducts(String query) async {
    try {
      isSearchLoading.value = true;
      lastSearchDoc = null;
      hasMoreSearchData.value = true;

      // استخدام نطاق نصي للبحث (يبدأ بـ...)
      // ملاحظة: هذا سيبحث عن الكلمات التي تبدأ بـ query
      final snapshot = await FirebaseFirestore.instance
          .collection("Products")
          .where("Title", isGreaterThanOrEqualTo: query)
          .where("Title", isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      if (snapshot.docs.isNotEmpty) {
        lastSearchDoc = snapshot.docs.last;
        searchResults.assignAll(
          snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList(),
        );
      } else {
        searchResults.clear();
      }

      if (snapshot.docs.length < 20) hasMoreSearchData.value = false;
    } catch (e) {
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
    } finally {
      isSearchLoading.value = false;
    }
  }

  // --- دالة جلب المزيد من نتائج البحث ---
  void fetchMoreSearchResults() async {
    if (isMoreSearchLoading.value || !hasMoreSearchData.value) return;

    try {
      isMoreSearchLoading.value = true;

      final query = FirebaseFirestore.instance
          .collection("Products")
          .where("Title", isGreaterThanOrEqualTo: searchQuery.value)
          .where("Title", isLessThanOrEqualTo: '${searchQuery.value}\uf8ff')
          .startAfterDocument(lastSearchDoc!)
          .limit(20);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastSearchDoc = snapshot.docs.last;
        searchResults.addAll(
          snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList(),
        );
      }

      if (snapshot.docs.length < 20) hasMoreSearchData.value = false;
    } catch (e) {
      print(e.toString());
    } finally {
      isMoreSearchLoading.value = false;
    }
  }
*/
  /*
  void searchProducts(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearchLoading.value = true;

      // البحث عن المنتجات التي تبدأ بالنص المدخل
      final snapshot = await FirebaseFirestore.instance
          .collection("Products")
          .where("Title", isGreaterThanOrEqualTo: query)
          .where("Title", isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromSnapshot(doc))
          .toList();
      searchResults.assignAll(products);
    } catch (e) {
      TLoaders.errorSnackBar(title: "خطأ في البحث", message: e.toString());
    } finally {
      isSearchLoading.value = false;
    }
  }
*/
  /*
  void fetchFeaturedProducts() async {
    try {
      isLoding.value = true;
      final products = await productRepository.getAllProducts();
      //final products = TDummyData.products;
      featuredProducts.assignAll(products);
    } catch (e) {
      TLoaders.errorSnackBar(title: "Oh Snap", message: e.toString());
    } finally {
      isLoding.value = false;
    }
  }
*/
  Future<List<ProductModel>> fetchAllFeaturedProducts() async {
    try {
      final products = await productRepository.getAllFeaturedProducts();
      return products;
    } catch (e) {
      TLoaders.errorSnackBar(title: "Oh Snap", message: e.toString());
      return [];
    }
  }

  void fetchSimelarProducts(
    String? categoryId,
    String currentProductId,
    ProductModel currentProduct,
  ) async {
    try {
      isLodingSimeler.value = true;
      final products = await productRepository.getSimilarProducts(
        categoryId: categoryId,
        currentProductId: currentProductId,
        currentProduct: currentProduct,
      );
      //final products = TDummyData.products;
      simaelerProducts.assignAll(products);
    } catch (e) {
      TLoaders.errorSnackBar(title: "Oh Snap", message: e.toString());
    } finally {
      isLodingSimeler.value = false;
    }
  }

  String getProductPrice(ProductModel product) {
    double smallesPrice = double.infinity;
    double largesPrice = 0.0;

    if (product.isSingleProduct) {
      return (product.salePrice > 0 ? product.salePrice : product.price)
          .toString();
    } else {
      for (var variation in product.productVariation!) {
        double priceToConsider = variation.salePrice > 0.0
            ? variation.salePrice
            : variation.price;
        if (priceToConsider < smallesPrice) {
          smallesPrice = priceToConsider;
        }
        if (priceToConsider > largesPrice) {
          largesPrice = priceToConsider;
        }
      }
      if (smallesPrice.isEqual(largesPrice)) {
        return largesPrice.toString();
      } else {
        return "$smallesPrice - ₪$largesPrice";
      }
    }
  }

  String? calculateSalePercentage(double originalPrice, double? salePrice) {
    if (salePrice == null || salePrice <= 0.0) return null;
    if (originalPrice <= 0) return null;
    double percentage = (originalPrice - salePrice) / originalPrice * 100;
    return percentage.toStringAsFixed(0);
  }

  String getProductStockStatus(int stock) {
    return stock > 0 ? "متوفر في المتجر" : "غير متوفر حاليا في المتجر";
  }
}
