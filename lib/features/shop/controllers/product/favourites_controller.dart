import 'dart:convert';
import 'package:get/get.dart';
import 'package:untitled2_ecom/data/repositories/product/product_repository.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/utils/local_storage/storage_utility.dart';
import 'package:untitled2_ecom/utils/popups/exports.dart';

class FavouritesController extends GetxController {
  static FavouritesController get instance => Get.find();

  final favourites = <String, bool>{}.obs;
  var isLoading = false.obs;
  var favoriteProductsList =
      <ProductModel>[].obs; // استبدل ProductModel بنوع الموديل لديك

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initFavourites();
    favoritesProducts();
  }

  void initFavourites() {
    final json = TLocalStorage.instance().readData("FAVORITES");
    if (json != null) {
      final storedFavourotes = jsonDecode(json) as Map<String, dynamic>;
      favourites.assignAll(
        storedFavourotes.map((key, value) => MapEntry(key, value as bool)),
      );
    }
  }

  bool isFavourite(String productId) {
    return favourites[productId] ?? false;
  }

  void toggleFavouriteProduct(String productId) {
    print("-----------------------");
    print("toggleFavouriteProduct");
    print("-----------------------");

    if (!favourites.containsKey(productId)) {
      favourites[productId] = true;
      saveFavoritesToStorage();
      TLoaders.customToast(message: "تمت إضافة المنتج إلى المفضلة.");

      // اختياري: يمكنك إعادة استدعاء favoritesProducts() هنا لتحديث القائمة بالمنتج الجديد
      favoritesProducts();
    } else {
      TLocalStorage.instance().removeData(productId);
      favourites.remove(productId);
      saveFavoritesToStorage();

      // 🔥 تحديث فوري للواجهة: إزالة المنتج من المصفوفة المراقبة محلياً ليختفي فورا من الشاشة
      favoriteProductsList.removeWhere((product) => product.id == productId);

      favourites.refresh();
      TLoaders.customToast(message: "تمت إزالة المنتج من المفضلة.");
    }
  }

  void saveFavoritesToStorage() {
    final encodedFavorites = json.encode(favourites);
    TLocalStorage.instance().saveData("FAVORITES", encodedFavorites);
  }

  Future<void> favoritesProducts() async {
    try {
      isLoading.value = true;

      // جلب البيانات من الدالة الأصلية الخاصة بك
      final products = await ProductRepository.instance.getFavouriteProducts(
        favourites.keys.toList(),
      );

      favoriteProductsList.assignAll(products);
    } catch (e) {
      print("Error fetching favorites: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
