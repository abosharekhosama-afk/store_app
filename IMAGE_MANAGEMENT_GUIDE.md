## نظام إدارة الصور المحسّن - Image Management System

### نظرة عامة
تم تطوير نظام متقدم لإدارة الصور مماثل لتطبيقات التسوق العالمية الكبرى مثل Amazon و eBay و Alibaba.

### الميزات الرئيسية:

#### 1. **Automatic Caching**
- حفظ تلقائي للصور لاستخدامها بدون إنترنت
- يتم حفظ الصور بأحجام محسّنة
- إدارة ذكية لحجم الـ cache

#### 2. **Offline Support**
- الصور المحفوظة مسبقاً تبقى متاحة بدون إنترنت
- عرض placeholder أثناء فقدان الاتصال
- معالجة سلسة للانتقال من online إلى offline

#### 3. **Lazy Loading**
- تحميل الصور فقط عند الحاجة
- تقليل استهلاك البيانات والذاكرة
- أداء أسرع عند التصفح

#### 4. **Preloading**
- تحميل الصور مسبقاً عند جلب قائمة المنتجات
- تحسين تجربة المستخدم عند التنقل

#### 5. **Error Handling**
- معالجة ذكية لأخطاء التحميل
- عرض صور بديلة (fallback images)
- إعادة محاولة تحميل الصور التالفة

---

### دليل الاستخدام:

#### **1. استخدام الصور المحسّنة في الـ UI**

```dart
// استخدام صورة محسّنة مع rounded corners
TRoundedImage(
  imageUrl: 'https://example.com/image.jpg',
  isNetworkImage: true,
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  borderRedius: 8.0,
)

// استخدام صورة دائرية مع caching
TCircularImage(
  image: 'https://example.com/avatar.jpg',
  isNetworkImage: true,
  width: 80,
  heigth: 80,
)

// استخدام widget محسّن متقدم
ImageManagerService.cachedNetworkImageWidget(
  'https://example.com/image.jpg',
  width: 300,
  height: 300,
  fit: BoxFit.cover,
)
```

#### **2. تحميل صور المنتجات مسبقاً**

```dart
// بعد جلب قائمة المنتجات
final controller = ImageCacheController.instance;
final imageUrls = products.map((p) => p.image).toList();
await controller.preloadProductImages(imageUrls);
```

#### **3. التحقق من الصور المتاحة بدون إنترنت**

```dart
final controller = ImageCacheController.instance;

// التحقق من صورة واحدة
bool isAvailable = await controller.isImageAvailableOffline(
  'https://example.com/image.jpg'
);

// التحقق من مجموعة صور
Map<String, String> result = await controller.handleOfflineImages(imageUrls);
result.forEach((url, status) {
  print('$url: $status'); // available أو unavailable
});
```

#### **4. الحصول على معلومات الـ Cache**

```dart
final controller = ImageCacheController.instance;

// حجم الـ cache
double sizeMB = await controller.getCacheSizeInMB();
print('Cache Size: $sizeMB MB');

// عدد الصور المحفوظة
int count = Obx(
  () => Text(controller.cachedImagesCount.toString())
);

// نص حجم الـ cache الـ Real-time
Obx(() => Text(controller.cacheSizeText.value))
```

#### **5. معالجة الصور بدون إنترنت**

```dart
final controller = ImageCacheController.instance;

// استخدام Optimized Widget
ImageOptimizationUtility.optimizedImageWidget(
  productImageUrl,
  fallbackAssetImage: 'assets/images/placeholder.png',
  width: 200,
  height: 200,
  borderRadius: BorderRadius.circular(8),
)
```

#### **6. تحميل صورة واحدة مسبقاً**

```dart
final controller = ImageCacheController.instance;
await controller.preloadSingleImage('https://example.com/featured-image.jpg');
```

#### **7. حذف الصور المحفوظة**

```dart
final controller = ImageCacheController.instance;

// حذف صورة واحدة
await controller.removeCachedImage('https://example.com/image.jpg');

// حذف جميع الصور (تحذير!)
await controller.clearAllImageCache();
```

---

### أمثلة متقدمة:

#### **مثال 1: عرض قائمة منتجات مع تحميل صور مسبق**

```dart
// في controller المنتجات
Future<void> fetchProducts() async {
  isLoading(true);
  try {
    products.value = await productRepository.getProducts();
    
    // تحميل الصور مسبقاً
    final imageUrls = products
        .map((p) => p.image)
        .toList();
    await ImageCacheController.instance
        .preloadProductImages(imageUrls);
  } finally {
    isLoading(false);
  }
}
```

#### **مثال 2: عرض رسالة عند عدم الاتصال**

```dart
// في الـ build
Obx(() {
  if (!networkManager.isConnected.value) {
    return Container(
      color: Colors.orange[100],
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(Icons.cloud_off),
          SizedBox(width: 8),
          Text('أنت بدون اتصال - عرض الصور المحفوظة'),
        ],
      ),
    );
  }
  return SizedBox.shrink();
})
```

#### **مثال 3: إدارة الـ cache في الإعدادات**

```dart
class CacheSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = ImageCacheController.instance;
    
    return Column(
      children: [
        Obx(() => ListTile(
          title: Text('حجم الـ Cache'),
          subtitle: Text(controller.cacheSizeText.value),
        )),
        Obx(() => ListTile(
          title: Text('عدد الصور المحفوظة'),
          subtitle: Text(controller.cachedImagesCount.toString()),
        )),
        ElevatedButton(
          onPressed: () => controller.clearAllImageCache(),
          child: Text('حذف جميع الصور'),
        ),
      ],
    );
  }
}
```

---

### الملفات الجديدة المضافة:

1. **`image_manager_service.dart`** - الخدمة الرئيسية لإدارة الصور
2. **`image_optimization_utility.dart`** - أدوات تحسين الصور والـ caching
3. **`image_cache_controller.dart`** - متحكم إدارة الـ cache

### الملفات المحدثة:

1. **`circular_image.dart`** - تحديث لاستخدام CachedNetworkImage
2. **`rounded_image.dart`** - تحديث لاستخدام CachedNetworkImage المحسّنة
3. **`general_bindings.dart`** - إضافة ImageCacheController

---

### أداء مقارن:

| الميزة | قبل | بعد |
|------|-----|-----|
| **تحميل الصور بدون إنترنت** | ❌ | ✅ |
| **استهلاك البيانات** | عالي | منخفض |
| **سرعة التحميل** | بطيء | سريع (cached) |
| **معالجة الأخطاء** | أساسية | متقدمة |
| **Lazy Loading** | ❌ | ✅ |
| **Preloading** | ❌ | ✅ |

---

### ملاحظات مهمة:

1. **حجم الـ Cache**: يتم تحديد الحد الأقصى لحجم الصور المحفوظة بناءً على المساحة المتاحة
2. **مدة الحفظ**: الصور تبقى في الـ cache حتى يتم حذفها يدويًا أو حتى امتلاء الحد الأقصى
3. **الاتصال السيء**: النظام يتعامل تلقائياً مع الاتصالات البطيئة
4. **استهلاك الذاكرة**: تقليل استهلاك الذاكرة من خلال lazy loading

---

### الدعم والتطوير المستقبلي:

- إضافة تحسين حجم الصور تلقائياً
- دعم أنواع صور مختلفة (WebP, AVIF)
- إضافة تصفية الشاشة عند البطاء
- دعم الصور المتحركة (GIF, Animation)
