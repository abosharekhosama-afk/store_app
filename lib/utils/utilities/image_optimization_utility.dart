import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'dart:io' as io;
import 'package:untitled2_ecom/utils/helpers/network_manager.dart';

/// أداة تحسين وتحميل الصور - متقدمة مثل تطبيقات التسوق العالمية
/// تتعامل مع:
/// - Lazy Loading (تحميل الصور عند الحاجة فقط)
/// - Preloading (تحضير الصور مسبقاً)
/// - Offline Support (الصور المحفوظة بدون إنترنت)
/// - Compression (ضغط وتحسين الصور)
/// - Error Handling (معالجة الأخطاء بكفاءة)
/*
class ImageOptimizationUtility {
  // قائمة الصور المحملة مسبقاً
  static final Set<String> _preloadedImages = {};

  // التحقق من حالة الإنترنت
  static final NetworkManager _networkManager = Get.find<NetworkManager>();

  /// تحميل صورة مسبقاً (preloading) لضمان توفرها بسرعة
  /// مفيد جداً لتحميل صور المنتجات المهمة
  static Future<void> preloadImage(String imageUrl) async {
    if (_preloadedImages.contains(imageUrl)) {
      return; // الصورة محملة بالفعل
    }

    try {
      final isConnected = await _networkManager.isConnected();
      if (!isConnected) {
        // التحقق من وجود الصورة في الـ cache
        final cachedFile = await DefaultCacheManager().getFileFromCache(
          imageUrl,
        );
        if (cachedFile != null) {
          _preloadedImages.add(imageUrl);
        }
      } else {
        // تحميل الصورة في الخفاء
        await DefaultCacheManager().getSingleFile(imageUrl);
        _preloadedImages.add(imageUrl);
      }
    } catch (e) {
      debugPrint('Error preloading image: $e');
    }
  }

  /// تحميل مسبق لمجموعة من الصور
  /// مفيد جداً بعد تحميل قائمة المنتجات
  static Future<void> preloadImages(List<String> imageUrls) async {
    await Future.wait(
      imageUrls.map((url) => preloadImage(url)),
      eagerError: false, // لا نتوقف عند أول خطأ
    );
  }

  /// الحصول على صورة محسّنة مع Lazy Loading
  /// تحميل الصورة فقط عند رؤيتها على الشاشة
  static ImageProvider<Object> getLazyLoadedImage(String imageUrl) {
    return CachedNetworkImageProvider(imageUrl);
  }

  /// التحقق من توفر الصورة بدون إنترنت
  /// إرجاع true إذا كانت الصورة محفوظة في الـ cache
  static Future<bool> isImageAvailableOffline(String imageUrl) async {
    try {
      final cachedFile = await DefaultCacheManager().getFileFromCache(imageUrl);
      return cachedFile != null;
    } catch (e) {
      return false;
    }
  }

  /// حذف صورة محددة من الـ cache
  static Future<void> removeImageFromCache(String imageUrl) async {
    try {
      await DefaultCacheManager().removeFile(imageUrl);
      _preloadedImages.remove(imageUrl);
    } catch (e) {
      debugPrint('Error removing image from cache: $e');
    }
  }

  /// حذف جميع الصور المحفوظة (استخدم بحذر)
  static Future<void> clearImageCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      _preloadedImages.clear();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// الحصول على حجم الـ cache بالـ MB
  static Future<double> getCacheSizeInMB() async {
    try {
      // الحصول على جميع الملفات المحفوظة
      final appCacheDir = io.Directory(
        '${(await getTemporaryDirectory()).path}/libCachedImageData',
      );

      if (!appCacheDir.existsSync()) return 0.0;

      int totalSize = 0;
      final files = appCacheDir.listSync(recursive: true);

      for (var file in files) {
        if (file is io.File) {
          totalSize += file.lengthSync();
        }
      }
      return totalSize / (1024 * 1024); // تحويل من bytes إلى MB
    } catch (e) {
      return 0.0;
    }
  }

  /// الحصول على معلومات عدد الصور المحفوظة
  static Future<int> getCachedImagesCount() async {
    try {
      final appCacheDir = io.Directory(
        '${(await getTemporaryDirectory()).path}/libCachedImageData',
      );

      if (!appCacheDir.existsSync()) return 0;

      final files = appCacheDir.listSync(recursive: true);
      return files.whereType<io.File>().length;
    } catch (e) {
      return 0;
    }
  }

  /// بناء widget صورة محسّنة مع fallback
  /// مفيد جداً عند عدم وجود صورة أو إنترنت
  static Widget optimizedImageWidget(
    String? imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    String? fallbackAssetImage,
    Widget? fallbackWidget,
    BorderRadius? borderRadius,
  }) {
    // إذا لم تكن هناك صورة، عرض fallback
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildFallbackWidget(
        fallbackAssetImage,
        fallbackWidget,
        width,
        height,
        borderRadius,
      );
    }

    // إذا كانت صورة محلية (asset)
    if (!imageUrl.startsWith('http')) {
      return _buildAssetImage(imageUrl, width, height, fit, borderRadius);
    }

    // صورة من الإنترنت مع caching
    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
      fadeInCurve: Curves.easeIn,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.image, size: 30, color: Colors.grey),
          ),
        );
      },
      errorWidget: (context, url, error) {
        // عند الخطأ، محاولة استخدام fallback
        return _buildFallbackWidget(
          fallbackAssetImage,
          fallbackWidget,
          width,
          height,
          borderRadius,
        );
      },
      cacheKey: imageUrl.replaceAll(RegExp(r'[^\w\-]'), '_'),
      maxHeightDiskCache: (height?.toInt() ?? 500) * 2,
      maxWidthDiskCache: (width?.toInt() ?? 500) * 2,
      useOldImageOnUrlChange: true,
    );

    // تطبيق border radius إذا تم توفيره
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: imageWidget);
    }

    return imageWidget;
  }

  /// بناء صورة محلية (Asset)
  static Widget _buildAssetImage(
    String path,
    double? width,
    double? height,
    BoxFit fit,
    BorderRadius? borderRadius,
  ) {
    final imageWidget = Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: imageWidget);
    }

    return imageWidget;
  }

  /// بناء widget البديل (Fallback)
  static Widget _buildFallbackWidget(
    String? fallbackAssetImage,
    Widget? fallbackWidget,
    double? width,
    double? height,
    BorderRadius? borderRadius,
  ) {
    final child =
        fallbackWidget ??
        (fallbackAssetImage != null
            ? Image.asset(
                fallbackAssetImage,
                width: width,
                height: height,
                fit: BoxFit.cover,
              )
            : Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 30, color: Colors.grey),
                ),
              ));

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: child);
    }

    return child;
  }

  /// تحسين URL الصورة بناءً على دقة الشاشة
  /// مفيد لتقليل استهلاك البيانات والذاكرة
  static String optimizeImageUrl(
    String imageUrl, {
    int? maxWidth,
    int? maxHeight,
    int quality = 80, // جودة الضغط 1-100
  }) {
    // إذا كانت الصور من Firebase Storage
    if (imageUrl.contains('firebasestorage')) {
      // يمكن إضافة معاملات التحسين هنا إذا كان Firebase يدعمها
      return imageUrl;
    }

    // يمكن إضافة منطق تحسين آخر حسب مصدر الصور
    return imageUrl;
  }

  /// معلومات تفصيلية عن حالة الـ cache
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final appCacheDir = io.Directory(
        '${(await getTemporaryDirectory()).path}/libCachedImageData',
      );

      if (!appCacheDir.existsSync()) {
        return {
          'total_size_bytes': 0,
          'total_size_mb': '0.0',
          'estimated_images_count': 0,
          'preloaded_images': 0,
        };
      }

      int totalSize = 0;
      int fileCount = 0;

      final files = appCacheDir.listSync(recursive: true);
      for (var file in files) {
        if (file is io.File) {
          totalSize += file.lengthSync();
          fileCount++;
        }
      }

      final sizeInMB = totalSize / (1024 * 1024);

      return {
        'total_size_bytes': totalSize,
        'total_size_mb': sizeInMB.toStringAsFixed(2),
        'estimated_images_count': fileCount,
        'preloaded_images': _preloadedImages.length,
      };
    } catch (e) {
      return {'error': 'Failed to get cache stats: $e'};
    }
  }
}
*/
