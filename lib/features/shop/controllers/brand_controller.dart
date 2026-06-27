import 'package:get/get.dart';
import 'package:untitled2_ecom/data/repositories/brands/brand_repository.dart';
import 'package:untitled2_ecom/data/repositories/product/product_repository.dart';
import 'package:untitled2_ecom/features/shop/models/brand_model.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/utils/popups/exports.dart';

class BrandController extends GetxController {
  static BrandController get instance => Get.find();

  RxBool isLoding = true.obs;
  final RxList<BrandModel> fetureBrands = <BrandModel>[].obs;
  final RxList<BrandModel> allBrands = <BrandModel>[].obs;
  final brandReposity = Get.put(BrandRepository());

  @override
  void onInit() {
    // TODO: implement onInit
    getFeaturedBrands();
    super.onInit();
  }

  Future<void> getFeaturedBrands() async {
    try {
      isLoding.value = true;
      final brands = await brandReposity.getAllBrands();
      allBrands.assignAll(brands);
      fetureBrands.assignAll(
        allBrands.where((prand) => prand.isFeatured ?? false).take(4),
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
    } finally {
      isLoding.value = false;
    }
  }

  Future<List<BrandModel>> getBrandForCategory(String categoryId) async {
    try {
      final brands = await brandReposity.getBrandForCategory(categoryId);
      return brands;
    } catch (e) {
      TLoaders.errorSnackBar(title: "Oh Snap!1", message: e.toString());
      return [];
    }
  }

  Future<List<ProductModel>> getBrandProducts({
    required String brandId,
    int limit = -1,
  }) async {
    try {
      final products = await ProductRepository.instance.getProductForBrand(
        brandId: brandId,
        limit: limit,
      );
      return products;
    } catch (e) {
      TLoaders.errorSnackBar(title: "Oh Snap!2", message: e.toString());
      return [];
    }
  }
}
