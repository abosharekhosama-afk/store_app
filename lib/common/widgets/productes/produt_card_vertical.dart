import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/favourite_icon/favourite_icon.dart';
import 'package:untitled2_ecom/common/widgets/images/rounded_image.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/product_controller.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/features/shop/screens/home/widget/product_cart_add_to_cart_button.dart';
import 'package:untitled2_ecom/features/shop/screens/product_details/product_details.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/helpers/helper_functions.dart';

class ProdutCardVertical extends StatelessWidget {
  const ProdutCardVertical({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = ProductController.instance;
    final salePercentage = controller.calculateSalePercentage(
      product.price,
      product.salePrice,
    );

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetails(product: product)),
      child: Container(
        // إزالة الـ width الثابت ليأخذ مساحة الـ Grid المتاحة
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // حواف دائرية أكبر قليلاً
          color: dark ? TColors.darkContainer : TColors.white,
          boxShadow: [
            BoxShadow(
              color: dark ? Colors.black26 : Colors.grey.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(
                0,
                15,
              ), // ظل ممتد للأسفل ليعطي عمقاً (Elevation)
            ),
          ],
          border: Border.all(
            color: dark ? Colors.white10 : Colors.black.withOpacity(0.03),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            /// 1. الجزء العلوي: الصورة (تأخذ أكبر مساحة ممكنة)
            Expanded(
              flex: 3, // نعطي الصورة ثقل أكبر في المساحة
              child: Stack(
                children: [
                  // استخدام Container لملء المساحة المتاحة بالكامل
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    margin: const EdgeInsets.all(
                      4,
                    ), // هامش بسيط جداً لجمالية الصورة داخل الإطار
                    child: TRoundedImage(
                      imageUrl: product.thumbnail,
                      isNetworkImage: true,
                      applyImageRadius: true,
                      borderRadius: 16,
                      borderRadiusShapcircular: false,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // شارة الخصم
                  if (salePercentage != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _buildSaleTag(salePercentage),
                    ),

                  // زر المفضلة
                  Positioned(
                    top: 5,
                    right: 5,
                    child: FavouriteIcon(productId: product.id),
                  ),
                ],
              ),
            ),

            /// 2. الجزء السفلي: النصوص والسعر (يأخذ المساحة المتبقية)
            Expanded(
              flex: 1, // المساحة المخصصة للبيانات
              child: Padding(
                padding: const EdgeInsets.only(right: 10, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // يوزع العناصر بين أعلى وأسفل المساحة المتبقية
                  children: [
                    // العنوان
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // السعر والزر في صف واحد أسفل البطاقة تماماً
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (product.salePrice > 0)
                                Text(
                                  "₪${product.price}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                "₪${controller.getProductPrice(product)}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: dark ? TColors.primary : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // زر الإضافة
                        ProductCartAddToCartButton(product: product),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت فرعي لشارة الخصم
  Widget _buildSaleTag(String percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TColors.secondary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "-$percentage%",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}








/*
class ProdutCardVertical extends StatelessWidget {
  const ProdutCardVertical({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = ProductController.instance;
    final salePercentage = controller.calculateSalePercentage(
      product.price,
      product.salePrice,
    );

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetails(product: product)),
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(
          0,
        ), // جعلنا Padding صفر لجعل التصميم يبدو ملتحماً أكثر
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // حواف دائرية أكبر قليلاً
          color: dark ? TColors.darkContainer : TColors.white,
          boxShadow: [
            BoxShadow(
              color: dark ? Colors.black26 : Colors.grey.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(
                0,
                15,
              ), // ظل ممتد للأسفل ليعطي عمقاً (Elevation)
            ),
          ],
          border: Border.all(
            color: dark ? Colors.white10 : Colors.black.withOpacity(0.03),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// -- الجزء العلوي (الصورة + الخصم)
            Stack(
              children: [
                // الصورة مع Aspect Ratio ثابت لضمان تناسق الشبكة
                AspectRatio(
                  aspectRatio: 0.9,
                  child: TRoundedContainer(
                    radius: 20,
                    backgroundColor: dark ? TColors.dark : TColors.softWhite,
                    child: TRoundedImage(
                      imageUrl: product.thumbnail,
                      isNetworkImage: true,
                      applyImageRadius: true,
                      borderRadiusShapcircular: false,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                /// -- شارة الخصم الحديثة (Corner Ribbon Style)
                if (salePercentage != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: TColors.primary, // أو لون فاقع مثل الاحمر الهادئ
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(TSizes.md),
                          bottomRight: Radius.circular(15),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            TColors.primary,
                            TColors.primary.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Text(
                        "-$salePercentage%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                /// -- زر المفضلة (عائم وشفاف قليلاً)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? Colors.black38 : Colors.white70,
                      shape: BoxShape.circle,
                    ),
                    child: FavouriteIcon(productId: product.id),
                  ),
                ),
              ],
            ),

            /// -- تفاصيل المنتج
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: dark ? Colors.white : Colors.black87,
                      ),
                    ),
                    // const SizedBox(height: 8),
                    // الماركة بخط أصغر وأهفت
                    /* Row(
                      children: [
                        Text(
                          product.brand?.name ?? '',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Iconsax.verify5,
                          color: TColors.primary,
                          size: 12,
                        ),
                      ],
                    ),*/
                  ],
                ),
              ),
            ),

            const Spacer(),

            /// -- السعر وزر الإضافة
            Padding(
              padding: const EdgeInsets.only(
                right: 12,
                bottom: 0,
              ), // Bottom 0 لجعل الزر ملتصق بالزاوية
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                    CrossAxisAlignment.end, // محاذاة العناصر للأسفل
                children: [
                  /// السعر
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                    ), // رفع السعر قليلاً عن الحافة
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.salePrice > 0)
                          Text(
                            "₪${product.price}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          "₪${controller.getProductPrice(product)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: TColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// زر الإضافة (ملتصق بالزاوية)
                  ProductCartAddToCartButton(product: product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
















/*
class ProdutCardVertical extends StatelessWidget {
  const ProdutCardVertical({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = ProductController.instance;
    final saleParcentage = controller.calculateSalePercentage(
      product.price,
      product.salePrice,
    );

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetails(product: product)),
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          // استخدام ظل ناعم جداً ليعطي إحساساً بالعمق
          // 2. الظل هو السر: نستخدم لون "البيج" بوضوح منخفض جداً بدلاً من الرمادي
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.black.withOpacity(0.3)
                  : TColors.beige.withOpacity(
                      0.25,
                    ), // ظل بيج ناعم يدمج البطاقة بالخلفية
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          // البطاقة بيضاء ناصعة لتبرز فوق الخلفية السكرية (Soft White)
          color: dark ? TColors.darkContainer : TColors.white,
          // 3. إضافة حدود رقيقة جداً بلون سكري لزيادة الفخامة
          border: Border.all(
            color: dark
                ? TColors.borderDark.withOpacity(0.1)
                : TColors.borderLight,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            /// -- الجزء العلوي (الصورة + الخصم + المفضلة)
            TRoundedContainer(
              heigth: 190,
              width: double.maxFinite,
              padding: const EdgeInsets.all(0.0),
              // خلفية خفيفة جداً خلف الصورة لتمييزها
              backgroundColor: dark ? TColors.dark : TColors.softWhite,
              child: Stack(
                children: [
                  /// -- صورة المنتج
                  Obx(() {
                    if (controller.isLoding.value) {
                      return const TShimmerEffect(
                        width: double.infinity,
                        height: 140,
                      );
                    }
                    return TRoundedImage(
                      isNetworkImage: true,
                      imageUrl: product.thumbnail.isEmpty
                          ? 'assets/images/placeholder.png'
                          : product.thumbnail,
                      applyImageRadius: true,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      padding: EdgeInsets.all(0.0),
                    );
                  }),

                  /// -- شارة الخصم (بيج هادئ)
                  if (saleParcentage != null)
                    Positioned(
                      top: 10,
                      left: 5,
                      child: TRoundedContainer(
                        radius: TSizes.sm,
                        backgroundColor: TColors.secondary.withOpacity(
                          0.9,
                        ), // استخدام البيج/اللاتيه
                        padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.sm,
                          vertical: TSizes.xs,
                        ),
                        child: Text(
                          "$saleParcentage%",
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge!.apply(color: TColors.primary),
                        ),
                      ),
                    ),

                  /// -- زر المفضلة
                  Positioned(
                    top: 0,
                    right: 0,
                    child: FavouriteIcon(productId: product.id),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.defaultSpace / 2),

            /// -- تفاصيل المنتج
            Padding(
              padding: const EdgeInsets.only(right: TSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TproductText(title: product.title, smallSize: true),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  // اختيارياً: إضافة الماركة بلون ثانوي باهت
                  // TBrandTitleWithVerifiedIcon(title: product.brand!.name, color: TColors.textSecondary),
                ],
              ),
            ),

            const Spacer(),

            /// -- السعر وزر الإضافة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// السعر
                Flexible(
                  child: Column(
                    children: [
                      if (product.productType ==
                              ProductType.single.toString() &&
                          product.salePrice > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: TSizes.sm),
                          child: TTextPrice(
                            price: product.price.toString(),
                            lineThrough: true,
                            isLarge: false,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(right: TSizes.sm),
                        child: TTextPrice(
                          price: controller.getProductPrice(product),
                        ),
                      ),
                    ],
                  ),
                ),

                /// زر الإضافة (تم تعديله بالأسفل)
                ProductCartAddToCartButton(product: product),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/














/*
class ProdutCardVertical extends StatelessWidget {
  const ProdutCardVertical({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = ProductController.instance;
    final saleParcentage = controller.calculateSalePercentage(
      product.price,
      product.salePrice,
    );

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetails(product: product)),
      child: Container(
        //width: 180,
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [TShadowStyle.verticalProductShadow],
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          color: dark ? TColors.darkerGrey : TColors.white,
        ),
        child: Column(
          children: [
            TRoundedContainer(
              heigth: 190,
              width: double.maxFinite,
              backgroundColor: dark ? TColors.dark : TColors.white,
              child: Stack(
                children: [
                  Obx(() {
                    if (controller.isLoding.value) {
                      return TShimmerEffect(
                        width: double.infinity,
                        height: 140,
                      );
                    }

                    return TRoundedImage(
                      isNetworkImage: true,
                      imageUrl: product.thumbnail.isEmpty
                          ? 'assets/images/placeholder.png'
                          : product.thumbnail,
                      applyImageRadius: true,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadiusShapcircular: false,
                      fit: BoxFit.cover,
                    );
                  }),
                  if (saleParcentage != null)
                    Positioned(
                      top: 12,
                      left: 4,
                      child: TRoundedContainer(
                        radius: TSizes.sm,
                        backgroundColor: TColors.primary.withOpacity(0.8),
                        padding: EdgeInsets.symmetric(
                          horizontal: TSizes.sm,
                          vertical: TSizes.xs,
                        ),
                        child: Text(
                          "$saleParcentage%",
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge!.apply(color: TColors.black),
                        ),
                      ),
                    ),

                  Positioned(
                    top: 0,
                    right: 0,
                    child: FavouriteIcon(productId: product.id),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.defaultSpace / 2),
            Padding(
              padding: EdgeInsetsGeometry.only(right: TSizes.sm),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TproductText(title: product.title, smallSize: true),
                    // const SizedBox(height: TSizes.spaceBtwItems / 2),
                    // TBrandTitleWithVerifiedIcon(title: product.brande!.name),
                  ],
                ),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    children: [
                      if (product.productType ==
                              ProductType.single.toString() &&
                          product.salePrice > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: TSizes.sm),
                          child: TTextPrice(
                            price: product.price.toString(),
                            lineThrough: true,
                            isLarge: false,
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.only(left: TSizes.sm),
                        child: TTextPrice(
                          price: controller.getProductPrice(product),
                        ),
                      ),
                    ],
                  ),
                ),
                ProductCartAddToCartButton(product: product),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/