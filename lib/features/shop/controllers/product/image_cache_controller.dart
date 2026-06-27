import 'package:get/get.dart';
import 'package:untitled2_ecom/utils/helpers/network_manager.dart';
import 'package:untitled2_ecom/utils/utilities/image_optimization_utility.dart';

/// متحكم متخصص في إدارة الصور
/// يتعامل مع:
/// - تحميل الصور من الإنترنت
/// - حفظ الصور في الـ cache
/// - معالجة الصور بدون إنترنت
/// - تحسين الأداء والذاكرة
/*
class ImageCacheController extends GetxController {
  static ImageCacheController get instance => Get.find();

  final NetworkManager _networkManager = Get.find<NetworkManager>();

  // ملاحظات الحالة
  final RxBool isLoadingImages = false.obs;
  final RxBool isImagesCached = false.obs;
  final RxInt cachedImagesCount = 0.obs;
  final RxString cacheSizeText = '0 MB'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeImageCache();
  }

  /// تهيئة نظام الـ cache للصور
  Future<void> _initializeImageCache() async {
    try {
      isLoadingImages(true);
      final stats = await ImageOptimizationUtility.getCacheStats();

      if (stats.containsKey('total_size_mb')) {
        cacheSizeText.value = '${stats['total_size_mb']} MB';
        cachedImagesCount.value = stats['estimated_images_count'];
        isImagesCached.value = cachedImagesCount.value > 0;
      }
    } catch (e) {
      print('Error initializing image cache: $e');
    } finally {
      isLoadingImages(false);
    }
  }

  /// تحميل مسبق لصور المنتجات
  /// استخدم هذا بعد جلب قائمة المنتجات
  Future<void> preloadProductImages(List<String> imageUrls) async {
    try {
      isLoadingImages(true);
      await ImageOptimizationUtility.preloadImages(imageUrls);
      await _updateCacheStats();
    } catch (e) {
      print('Error preloading images: $e');
    } finally {
      isLoadingImages(false);
    }
  }

  /// تحميل صورة واحدة مسبقاً
  Future<void> preloadSingleImage(String imageUrl) async {
    try {
      await ImageOptimizationUtility.preloadImage(imageUrl);
      await _updateCacheStats();
    } catch (e) {
      print('Error preloading single image: $e');
    }
  }

  /// التحقق من توفر صورة بدون إنترنت
  Future<bool> isImageAvailableOffline(String imageUrl) async {
    return await ImageOptimizationUtility.isImageAvailableOffline(imageUrl);
  }

  /// حذف صورة من الـ cache
  Future<void> removeCachedImage(String imageUrl) async {
    try {
      await ImageOptimizationUtility.removeImageFromCache(imageUrl);
      await _updateCacheStats();
    } catch (e) {
      print('Error removing cached image: $e');
    }
  }

  /// حذف جميع الصور المحفوظة
  /// تحذير: هذا سيؤدي إلى حذف جميع الصور المحفوظة
  Future<void> clearAllImageCache() async {
    try {
      isLoadingImages(true);
      await ImageOptimizationUtility.clearImageCache();
      cacheSizeText.value = '0 MB';
      cachedImagesCount.value = 0;
      isImagesCached.value = false;
    } catch (e) {
      print('Error clearing image cache: $e');
    } finally {
      isLoadingImages(false);
    }
  }

  /// تحديث إحصائيات الـ cache
  Future<void> _updateCacheStats() async {
    try {
      final stats = await ImageOptimizationUtility.getCacheStats();

      if (stats.containsKey('total_size_mb')) {
        cacheSizeText.value = '${stats['total_size_mb']} MB';
        cachedImagesCount.value = stats['estimated_images_count'];
        isImagesCached.value = cachedImagesCount.value > 0;
      }
    } catch (e) {
      print('Error updating cache stats: $e');
    }
  }

  /// الحصول على حجم الـ cache بالـ MB
  Future<double> getCacheSizeInMB() async {
    return await ImageOptimizationUtility.getCacheSizeInMB();
  }

  /// التحقق من الاتصال بالإنترنت
  Future<bool> isConnectedToInternet() async {
    return await _networkManager.isConnected();
  }

  /// معالجة الصور عند عدم وجود إنترنت
  Future<Map<String, String>> handleOfflineImages(
    List<String> imageUrls,
  ) async {
    final Map<String, String> result = {};

    for (var url in imageUrls) {
      final isAvailable =
          await ImageOptimizationUtility.isImageAvailableOffline(url);
      result[url] = isAvailable ? 'available' : 'unavailable';
    }

    return result;
  }
}
*/
