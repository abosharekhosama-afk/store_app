
/*
/// خدمة التحقق من صحة الصور والتأكد من تحميلها بشكل صحيح
class ImageValidationService {
  static final ImageValidationService _instance = ImageValidationService._();

  factory ImageValidationService() {
    return _instance;
  }

  ImageValidationService._();

  final NetworkManager _networkManager = Get.find<NetworkManager>();

  /// التحقق من صحة رابط الصورة
  /// أرجع true إذا كان الرابط صحيحاً وليس فارغاً
  bool isValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return false;
    }

    // التحقق من أن الرابط يبدأ بـ http أو https
    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      return false;
    }

    return true;
  }

  /// الحصول على رابط صورة آمن مع fallback
  String getSafeImageUrl(
    String? imageUrl, {
    String fallbackUrl = 'assets/images/placeholder.png',
  }) {
    if (isValidImageUrl(imageUrl)) {
      return imageUrl!;
    }
    debugPrint('⚠️ تحذير: رابط الصورة غير صحيح: $imageUrl. استخدام fallback');
    return fallbackUrl;
  }

  /// التحقق من جودة الصورة بناءً على حجمها
  /// أرجع true إذا كانت جودة الصورة مقبولة
  bool isImageQualityAcceptable(int? imageSize) {
    if (imageSize == null) {
      return false;
    }

    // إذا كانت الصورة أصغر من 500 بايت، قد تكون صورة placeholder
    if (imageSize < 500) {
      return false;
    }

    // إذا كانت أكبر من 10MB، قد تكون مشكلة
    if (imageSize > 10 * 1024 * 1024) {
      return false;
    }

    return true;
  }

  /// التحقق من حالة الاتصال قبل محاولة تحميل الصور
  Future<bool> canLoadImages() async {
    try {
      final isOnline = await _networkManager.isConnected();
      return isOnline;
    } catch (e) {
      debugPrint('خطأ في التحقق من الاتصال: $e');
      return false;
    }
  }

  /// معالجة الأخطاء الشائعة في تحميل الصور
  static String getImageLoadErrorMessage(String errorCode) {
    const errorMap = {
      'INVALID_URL': 'رابط الصورة غير صحيح',
      'NETWORK_ERROR': 'فشل الاتصال بالإنترنت',
      'TIMEOUT': 'انتهت مهلة التحميل',
      'NOT_FOUND': 'الصورة غير موجودة',
      'PERMISSION_DENIED': 'لا توجد صلاحيات للوصول',
      'STORAGE_ERROR': 'خطأ في التخزين',
      'UNKNOWN': 'خطأ غير معروف',
    };

    return errorMap[errorCode] ?? errorMap['UNKNOWN']!;
  }

  /// السجل والتشخيص
  void logImageLoadingError(String imageUrl, dynamic error) {
    debugPrint(
      '❌ خطأ في تحميل الصورة:\nRabbit: $imageUrl\nخطأ: $error\nالوقت: ${DateTime.now()}',
    );
  }

  void logImageLoadingSuccess(String imageUrl) {
    debugPrint(
      '✅ تم تحميل الصورة بنجاح:\nRabbit: $imageUrl\nالوقت: ${DateTime.now()}',
    );
  }
}
*/