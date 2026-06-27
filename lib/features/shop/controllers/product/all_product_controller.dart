import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/data/repositories/product/product_repository.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/utils/popups/exports.dart';

class AllProductController extends GetxController {
  static AllProductController get instance => Get.find();

  final productRepository = ProductRepository.instance;
  final RxString selectedSortOption = TTexts.sortByName.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

  // متغيرات الـ Pagination
  final ScrollController scrollController = ScrollController();
  DocumentSnapshot? lastDocument;
  RxBool isLoading = false.obs;
  RxBool hasMoreData = true.obs;
  Query? currentQuery;

  @override
  void onInit() {
    onSortOptionChange(TTexts.sortByName);
    super.onInit();
    // مراقبة التمرير
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        fetchNextBatch();
      }
    });
  }

  /// جلب الدفعة الأولى من المنتجات
  Future<List<ProductModel>> fetchProductsByQuery(Query? query) async {
    try {
      if (query == null) return [];

      isLoading.value = true;
      currentQuery = query;
      lastDocument = null; // إعادة ضبط عند بدء استعلام جديد
      hasMoreData.value = true;

      // جلب أول 20
      final result = await productRepository.getProductsForPagination(
        query,
        limit: 20,
      );

      products.assignAll(result.products);
      lastDocument = result.lastDocument;

      if (result.products.length < 20) hasMoreData.value = false;

      return products;
    } catch (e) {
      TLoaders.errorSnackBar(title: "يا للهول", message: e.toString());
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب الدفعة التالية عند التمرير
  Future<void> fetchNextBatch() async {
    if (isLoading.value || !hasMoreData.value || currentQuery == null) return;

    try {
      isLoading.value = true;

      final result = await productRepository.getProductsForPagination(
        currentQuery!,
        limit: 20,
        startAfterDocument: lastDocument,
      );

      products.addAll(result.products);
      lastDocument = result.lastDocument;

      if (result.products.length < 20) hasMoreData.value = false;
    } catch (e) {
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // دالة الفرز (يفضل أن يتم الفرز في Firebase للحصول على نتائج Pagination دقيقة)
  /// دالة لتغيير الترتيب وإعادة الجلب
  void onSortOptionChange(String option) {
    selectedSortOption.value = option;

    // بناء استعلام جديد بناءً على الخيار
    Query newQuery =
        productRepository.productsCollection; // مرجع المجموعة الأساسي

    switch (option) {
      case TTexts.sortByName:
        newQuery = newQuery.orderBy(TProductFields.title, descending: false);
        break;
      case TTexts.sortByHighestPrice:
        newQuery = newQuery.orderBy(TProductFields.price, descending: true);
        break;
      case TTexts.sortByLowestPrice:
        newQuery = newQuery.orderBy(TProductFields.price, descending: false);
        break;
      case TTexts.sortByNewest:
        newQuery = newQuery.orderBy(TProductFields.date, descending: true);
        break;
      case TTexts.sortBySale:
        newQuery = newQuery.orderBy(TProductFields.salePrice, descending: true);
        break;
      // أضف بقية الحالات هنا
    }

    // إعادة جلب البيانات من الصفر بالترتيب الجديد
    fetchProductsByQuery(newQuery);
  }

  void assignProducts(List<ProductModel> products) {
    this.products.assignAll(products);
    onSortOptionChange(TTexts.sortByName);
  }
}













/*
class AllProductController extends GetxController {
  static AllProductController get instance => Get.find();

  final productRepositey = ProductRepository.instance;
  final RxString selectedSortOption = TTexts.sortByName.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

  Future<List<ProductModel>> fetchProductsByQuery(Query? query) async {
    try {
      if (query == null) return [];

      final products = await productRepositey.getAllProductsByQuery(query);
      return products;
    } catch (e) {
      TLoaders.errorSnackBar(title: "Oh Snap!", message: e.toString());
      return [];
    }
  }

  void sortProduct(String sortOption) {
    selectedSortOption.value = sortOption;
    switch (sortOption) {
      case TTexts.sortByName:
        products.sort((a, b) => a.title.compareTo(b.title));
        break;
      case TTexts.sortByHighestPrice:
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case TTexts.sortByLowestPrice:
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case TTexts.sortByNewest:
        products.sort((a, b) => a.date!.compareTo(b.date!));
        break;
      case TTexts.sortBySale:
        products.sort((a, b) {
          if (b.salePrice > 0) {
            return b.salePrice.compareTo(a.salePrice);
          } else if (a.salePrice > 0) {
            return -1;
          } else {
            return 1;
          }
        });
        break;
      default:
        products.sort((a, b) => a.title.compareTo(b.title));
    }
  }

  void assignProducts(List<ProductModel> products) {
    this.products.assignAll(products);
    sortProduct("Name");
  }
}
*/