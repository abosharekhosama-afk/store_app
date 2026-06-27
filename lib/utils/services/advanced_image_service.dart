
/*
/// خدمة متقدمة لإدارة الصور مع الكاش والعمل بدون إنترنت
class AdvancedImageService {
  static final AdvancedImageService _instance = AdvancedImageService._();

  factory AdvancedImageService() {
    return _instance;
  }

  AdvancedImageService._();

  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  /// التحقق من وجود الصورة في الكاش
  Future<bool> isImageCached(String imageUrl) async {
    try {
      final file = await _cacheManager.getFileFromCache(imageUrl);
      return file != null;
    } catch (e) {
      debugPrint('خطأ في التحقق من الكاش: $e');
      return false;
    }
  }

  /// تحميل الصورة مسبقاً وحفظها في الكاش
  Future<void> preloadImage(String imageUrl) async {
    try {
      await _cacheManager.getSingleFile(imageUrl);
      debugPrint('✅ تم تحميل الصورة في الكاش: $imageUrl');
    } catch (e) {
      debugPrint('❌ خطأ في تحميل الصورة: $e');
    }
  }

  /// تحميل مجموعة من الصور مسبقاً
  Future<void> preloadImages(List<String> imageUrls) async {
    try {
      await Future.wait(imageUrls.map((url) => preloadImage(url)));
      debugPrint('✅ تم تحميل ${imageUrls.length} صورة في الكاش');
    } catch (e) {
      debugPrint('❌ خطأ في تحميل مجموعة الصور: $e');
    }
  }

  /// الحصول على حجم الكاش بالميجابايت
  Future<double> getCacheSizeInMB() async {
    try {
      final info = await _cacheManager.store.getInfo();
      final sizeInBytes = info.sumFilesSize;
      return sizeInBytes / (1024 * 1024);
    } catch (e) {
      debugPrint('خطأ في حساب حجم الكاش: $e');
      return 0.0;
    }
  }

  /// مسح الكاش بالكامل
  Future<void> clearAllCache() async {
    try {
      await _cacheManager.emptyCache();
      debugPrint('✅ تم مسح الكاش بالكامل');
    } catch (e) {
      debugPrint('❌ خطأ في مسح الكاش: $e');
    }
  }

  /// مسح الصور الكاش القديمة (أكثر من يوم واحد)
  Future<void> clearOldCache({
    Duration duration = const Duration(days: 1),
  }) async {
    try {
      final dateLimit = DateTime.now().subtract(duration);
      await _cacheManager.removeWhere(
        (file) => file.validTill.isBefore(dateLimit),
      );
      debugPrint('✅ تم مسح الكاش القديم');
    } catch (e) {
      debugPrint('❌ خطأ في مسح الكاش القديم: $e');
    }
  }

  /// الحصول على عدد الصور في الكاش
  Future<int> getCachedImagesCount() async {
    try {
      final info = await _cacheManager.store.getInfo();
      return info.fileCount;
    } catch (e) {
      debugPrint('خطأ في عد الصور: $e');
      return 0;
    }
  }

  /// الحصول على معلومات الكاش الشاملة
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final sizeInMB = await getCacheSizeInMB();
      final count = await getCachedImagesCount();

      return {
        'totalSizeInMB': sizeInMB.toStringAsFixed(2),
        'filesCount': count,
        'status': 'متاح',
      };
    } catch (e) {
      return {'status': 'خطأ', 'error': e.toString()};
    }
  }
}
*/