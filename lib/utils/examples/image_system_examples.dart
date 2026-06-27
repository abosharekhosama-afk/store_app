/// مثال عملي شامل - كيفية استخدام نظام إدارة الصور الجديد
/// في تطبيق التسوق الإلكتروني
///
/// يوضح هذا الملف:
/// - تحميل صور المنتجات مسبقاً
/// - عرض الصور بكفاءة
/// - معالجة الأخطاء والانقطاع
/// - إدارة الـ cache
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/product_controller.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/image_cache_controller.dart';
import 'package:untitled2_ecom/utils/utilities/image_optimization_utility.dart';

/// المثال 1: تحميل صور المنتجات مسبقاً بعد جلبها
class ProductListWithImagePreloading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productController = Get.put(ProductController());
    final imageCacheController = ImageCacheController.instance;

    return Scaffold(
      appBar: AppBar(title: Text('المنتجات')),
      body: Obx(() {
        if (productController.isLoding.value) {
          return Center(child: CircularProgressIndicator());
        }

        // بعد تحميل المنتجات، قم بتحميل الصور مسبقاً
        if (productController.featuredProducts.isNotEmpty) {
          final imageUrls = productController.featuredProducts
              .map((p) => p.thumbnail)
              .toList();

          // تحميل الصور في الخلفية (لا ينتظر المستخدم)
          Future.microtask(
            () => imageCacheController.preloadProductImages(imageUrls),
          );
        }

        return GridView.builder(
          itemCount: productController.featuredProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final product = productController.featuredProducts[index];
            return ProductImageCard(product: product);
          },
        );
      }),
    );
  }
}

/// المثال 2: عرض صورة المنتج مع معالجة الاتصال
class ProductImageCard extends StatelessWidget {
  final product;

  ProductImageCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageCacheController = ImageCacheController.instance;

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Stack(
              children: [
                // عرض الصورة مع caching تلقائي
                ImageOptimizationUtility.optimizedImageWidget(
                  product.thumbnail,
                  fallbackAssetImage: 'assets/images/placeholder.png',
                  borderRadius: BorderRadius.circular(8),
                ),

                // مؤشر الصورة المحفوظة
                FutureBuilder<bool>(
                  future: imageCacheController.isImageAvailableOffline(
                    product.thumbnail,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.data == true) {
                      return Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'محفوظ',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(product.price.toString()),
      ],
    );
  }
}

/// المثال 3: صفحة تفاصيل المنتج مع صور محسّنة
class ProductDetailsWithOptimizedImages extends StatefulWidget {
  final productId;

  ProductDetailsWithOptimizedImages({required this.productId});

  @override
  _ProductDetailsWithOptimizedImagesState createState() =>
      _ProductDetailsWithOptimizedImagesState();
}

class _ProductDetailsWithOptimizedImagesState
    extends State<ProductDetailsWithOptimizedImages> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  final imageCacheController = ImageCacheController.instance;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _preloadProductImages();
  }

  /// تحميل صور المنتج مسبقاً
  void _preloadProductImages() async {
    // هنا يمكنك جلب صور المنتج من قاعدة البيانات
    // وتحميلها مسبقاً
    final productController = Get.find<ProductController>();
    final products = productController.featuredProducts;

    if (products.isNotEmpty) {
      // تحميل الصورة الرئيسية من أول منتج
      final imageUrls = products.map((p) => p.thumbnail).toList();
      await imageCacheController.preloadProductImages(imageUrls);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    // استخدم أول منتج من featured products كمثال
    final products = productController.featuredProducts;
    final product = products.isNotEmpty ? products.first : null;

    return Scaffold(
      appBar: AppBar(title: Text('تفاصيل المنتج')),
      body: product == null
          ? Center(child: Text('لم يتم العثور على المنتج'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // عرض صور المنتج في مجموعة
                  Container(
                    height: 400,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      children: [
                        // الصورة الرئيسية
                        _buildProductImage(product.thumbnail),

                        // صور إضافية (إذا وجدت)
                        // ...
                      ],
                    ),
                  ),

                  // مؤشرات الصور
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 1; i++) // وضع عدد الصور هنا
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: _currentImageIndex == i ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == i
                                ? Colors.blue
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),

                  // معلومات المنتج
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${product.price} ريال',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 16),

                        // معلومات حجم الـ cache
                        Obx(
                          () => Text(
                            'الصور المحفوظة: ${imageCacheController.cacheSizeText.value}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// بناء widget الصورة مع معالجة الانقطاع
  Widget _buildProductImage(String imageUrl) {
    return Stack(
      children: [
        // الصورة الرئيسية
        ImageOptimizationUtility.optimizedImageWidget(
          imageUrl,
          fallbackAssetImage: 'assets/images/placeholder.png',
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/// المثال 4: إدارة الـ cache في صفحة الإعدادات
class ImageCacheManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final imageCacheController = ImageCacheController.instance;

    return Scaffold(
      appBar: AppBar(title: Text('إدارة الصور')),
      body: Obx(
        () => ListView(
          children: [
            // قسم معلومات الـ cache
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات الـ Cache',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16),

                  // حجم الـ cache
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('حجم الـ Cache:'),
                      Text(
                        imageCacheController.cacheSizeText.value,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // عدد الصور المحفوظة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('عدد الصور:'),
                      Text(
                        imageCacheController.cachedImagesCount.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // أزرار الإجراءات
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => imageCacheController.clearAllImageCache(),
                    icon: Icon(Icons.delete),
                    label: Text('حذف جميع الصور المحفوظة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: () =>
                        _showCacheStats(context, imageCacheController),
                    icon: Icon(Icons.info),
                    label: Text('عرض التفاصيل'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// عرض تفاصيل الـ cache
  void _showCacheStats(BuildContext context, ImageCacheController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الـ Cache'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Text('الحجم الإجمالي: ${controller.cacheSizeText.value}'),
            ),
            SizedBox(height: 8),
            Obx(() => Text('عدد الصور: ${controller.cachedImagesCount}')),
            SizedBox(height: 8),
            Text(
              'بعد حذف الصور سيتم تحميلها مجدداً عند الحاجة',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
*/
