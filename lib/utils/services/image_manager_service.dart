import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/utils/helpers/network_manager.dart';

/// Image Manager Service - يدير الصور مع دعم الـ Caching والـ Offline Support
/// مثل تطبيقات التسوق العالمية الكبرى (Amazon, eBay, Alibaba)
class ImageManagerService {
  static const String _cacheKeyPrefix = 'cached_image_';

  /// الحصول على صورة محسّنة مع دعم الـ offline
  /// يتم حفظ الصور تلقائياً في الـ cache بحيث تبقى متاحة بدون إنترنت
  static Widget cachedNetworkImageWidget(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    String? placeholder,
    String? errorImage,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    VoidCallback? onImageLoaded,
    Duration animationDuration = const Duration(milliseconds: 500),
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
      fadeInCurve: Curves.easeIn,
      fadeInDuration: animationDuration,
      fadeOutDuration: animationDuration,
      // معالج عند بداية تحميل الصورة
      placeholder: (context, url) {
        return Container(
          width: width,
          height: height,
          color: backgroundColor ?? Colors.grey[300],
          child: Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
        );
      },
      // معالج عند فشل تحميل الصورة
      errorWidget: (context, url, error) {
        return Container(
          width: width,
          height: height,
          color: backgroundColor ?? Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'فشل تحميل الصورة',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
      // Caching دائم للصور
      cacheKey: _generateCacheKey(imageUrl),
      maxHeightDiskCache: (height?.toInt() ?? 500) * 2,
      maxWidthDiskCache: (width?.toInt() ?? 500) * 2,
      useOldImageOnUrlChange: true,
    );
  }

  /// الحصول على صورة مع Rounded Corners
  static Widget cachedNetworkImageWithRadius(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    double borderRadius = 8.0,
    String? placeholder,
    String? errorImage,
    Color? backgroundColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: cachedNetworkImageWidget(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorImage: errorImage,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// الحصول على صورة دائرية مع caching
  static Widget cachedCircularNetworkImage(
    String imageUrl, {
    double size = 50.0,
    String? placeholder,
    Color? backgroundColor,
    BoxFit fit = BoxFit.cover,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.grey[300],
      ),
      child: ClipOval(
        child: cachedNetworkImageWidget(
          imageUrl,
          width: size,
          height: size,
          fit: fit,
          placeholder: placeholder,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }

  /// التحقق من توفر الصورة في الـ Cache
  /// مفيد للتحقق من الصور المحفوظة بدون اتصال إنترنت
  static Future<bool> isCached(String imageUrl) async {
    try {
      final cacheKey = _generateCacheKey(imageUrl);
      final file = await DefaultCacheManager().getFileFromCache(cacheKey);
      return file != null;
    } catch (e) {
      return false;
    }
  }

  /// حذف الصورة من الـ Cache يدويًا
  static Future<void> removeCachedImage(String imageUrl) async {
    try {
      final cacheKey = _generateCacheKey(imageUrl);
      await DefaultCacheManager().removeFile(cacheKey);
    } catch (e) {
      debugPrint('Error removing cached image: $e');
    }
  }

  /// حذف جميع الصور المحفوظة من الـ Cache
  /// (استخدم بحذر - قد يؤثر على الأداء)
  static Future<void> clearAllCache() async {
    try {
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// إعادة محاولة تحميل صورة بعد فشل
  /// مع backoff exponential للحد من استهلاك البيانات
  static Future<void> retryFailedImageLoad(
    String imageUrl, {
    int maxRetries = 3,
    Duration delayBetweenRetries = const Duration(seconds: 1),
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        await DefaultCacheManager().getSingleFile(imageUrl);
        return; // نجح التحميل
      } catch (e) {
        retryCount++;
        if (retryCount < maxRetries) {
          // انتظر قبل المحاولة التالية (exponential backoff)
          await Future.delayed(delayBetweenRetries * retryCount);
        }
      }
    }
  }

  /// التحقق من الاتصال قبل تحميل الصور
  /// وإخطار المستخدم إذا كان بدون إنترنت
  static Future<bool> checkInternetBeforeImageLoad() async {
    try {
      final networkManager = Get.find<NetworkManager>();
      final isConnected = await networkManager.isConnected();

      if (!isConnected) {
        // معلومة: الصور المحفوظة مسبقاً ستظهر حتى بدون إنترنت
        // بسبب استخدام CachedNetworkImage
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// توليد مفتاح فريد للـ cache للصورة
  static String _generateCacheKey(String imageUrl) {
    return _cacheKeyPrefix + imageUrl.replaceAll(RegExp(r'[^\w\-]'), '_');
  }

  /// تحسين جودة الصور بناءً على حجم الشاشة
  /// مفيد لتقليل استهلاك الذاكرة والبيانات
  static String optimizeImageUrl(String imageUrl, {int? width, int? height}) {
    // إذا كانت الصور من Firebase Storage أو CDN يدعم تحسين الأحجام
    // يمكن إضافة المعاملات هنا
    return imageUrl;
  }
}
