import 'package:get/get.dart';
import 'package:untitled2_ecom/data/repositories/categories/categories_repositiry.dart';
import 'package:untitled2_ecom/data/repositories/product/product_repository.dart';
import 'package:untitled2_ecom/features/shop/models/category_model.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/utils/popups/exports.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final _categoriesRepositiry = Get.put(CategoriesRepositiry());
  RxList<CategoryModel> allCategory = <CategoryModel>[].obs;
  RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;
  final isLoading = false.obs;
  RxList<CategoryModel> subCategories = <CategoryModel>[].obs;
  RxList<ProductModel> categoryProducts = <ProductModel>[].obs;
  RxInt selectedSubCategoryIndex = 0.obs; // لمتابعة التبويب المختار
  final isLoadingProducts = false.obs; // لفصل تحميل المنتجات عن الصفحة

  @override
  void onInit() {
    // TODO: implement onInit
    fetchCategories();
    super.onInit();
  }

  // داخل CategoryController
  Future<void> loadSubCategoryData(String categoryId) async {
    try {
      // 1. تصفير القوائم القديمة لضمان عدم ظهور بيانات قديمة
      subCategories.clear();
      categoryProducts.clear();

      isLoading.value = true;

      // 2. جلب الأقسام الفرعية
      final subs = await getSubCategory(categoryId: categoryId);
      subCategories.assignAll(subs);

      if (subCategories.isNotEmpty) {
        // 3. جلب منتجات أول تصنيف فرعي
        selectedSubCategoryIndex.value = 0; // تأكد من تصفير الاندكس
        await fetchProductsForSubCategory(subCategories[0].id, 0);
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /*
  // دالة لجلب التصنيفات الفرعية ومن ثم جلب منتجات أول تصنيف تلقائياً
  Future<void> loadSubCategoryData(String categoryId) async {
    try {
      isLoading.value = true;
      final subs = await getSubCategory(categoryId: categoryId);
      subCategories.assignAll(subs);

      if (subCategories.isNotEmpty) {
        // جلب منتجات أول تصنيف فرعي افتراضياً
        await fetchProductsForSubCategory(subCategories[0].id, 0);
      }
    } finally {
      isLoading.value = false;
    }
  }
*/
  Future<void> fetchProductsForSubCategory(String subId, int index) async {
    selectedSubCategoryIndex.value = index;
    try {
      isLoadingProducts.value = true;
      final products = await getCategoryProducts(categoryId: subId, limit: -1);
      categoryProducts.assignAll(products);
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;

      final categoris = await _categoriesRepositiry.getAllCategories();
      allCategory.assignAll(categoris);
      featuredCategories.assignAll(
        allCategory
            .where((p0) => p0.isFeatured && p0.parentId.isEmpty)
            .take(8)
            .toList(),
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ProductModel>> getCategoryProducts({
    required String categoryId,
    int limit = 4,
  }) async {
    final product = await ProductRepository.instance.getProductForCategory(
      categoryId: categoryId,
      limit: limit,
    );
    return product;
  }

  Future<List<CategoryModel>> getSubCategory({
    required String categoryId,
  }) async {
    try {
      final subCategory = await _categoriesRepositiry.getSubCategory(
        categoryId,
      );
      return subCategory;
    } catch (e) {
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
      return [];
    }
  }
}
