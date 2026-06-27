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

class TSimilarProductCard extends StatelessWidget {
  const TSimilarProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = ProductController.instance;
    final salePercentage = controller.calculateSalePercentage(
      product.price,
      product.salePrice,
    );

    const double cardRadius = 20.0; // توحيد نصف القطر للبطاقة والزر

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetails(product: product)),
      child: Container(
        width: 180,
        // تم إزالة الـ height الثابت ليدع التصميم يتمدد مرناً أو يستقر بناءً على الـ الـ ListView
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cardRadius),
          color: dark ? TColors.darkContainer : TColors.white,
          boxShadow: [
            BoxShadow(
              color: dark ? Colors.black26 : Colors.grey.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: dark ? Colors.white10 : Colors.black.withOpacity(0.03),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // لجعل البطاقة مرنة ومحكومة بعناصرها
          children: [
            /// 1. الجزء العلوي: الصورة والشارات
            Stack(
              children: [
                Container(
                  width:
                      double.infinity, // يشغل كامل عرض البطاقة (180) بشكل أنيق
                  height: 150, // ارتفاع متناسق ومدروس لمنع تزاحم النصوص بالأسفل
                  padding: const EdgeInsets.all(4),
                  child: TRoundedImage(
                    imageUrl: product.thumbnail,
                    isNetworkImage: true,
                    applyImageRadius: true,
                    borderRadius:
                        cardRadius -
                        4, // أصغر قليلاً من الحافة الخارجية لإطار جمالي
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

            /// 2. الجزء الأوسط: قسم العنوان (يتمدد بمرونة لحماية المساحة الكلية)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment
                      .start, // يبدأ من الأعلى ويزحف لأسفل مرناً
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 3. الجزء السفلي الملتصق تماماً (Docked Bottom Row)
            /// تم إخراجه من الـ Padding ليلتحم مباشرة بانحناء الـ Container الخارجي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  CrossAxisAlignment.end, // محاذاة العناصر مع قاع البطاقة
              children: [
                // أسعار المنتج (مضافة داخل مساحة مرنة ومزاحة بحشو يساري/يميني ناعم)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 12,
                      left: 8,
                      bottom: 10,
                    ), // حشو خاص بالأسعار فقط
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
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: dark ? TColors.primary : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // زر الإضافة المطور ليغلق الزاوية السفلية تماماً ويبرز الانحناء الهيكلي
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(
                      cardRadius,
                    ), // يطابق انحناء البطاقة بالكامل من الأسفل
                    topRight: Radius.circular(
                      14,
                    ), // انحناء داخلي معاكس لإعطاء لمسة انسيابية مريحة للعين
                  ),
                  child: ProductCartAddToCartButton(product: product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleTag(String percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: TColors.secondary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "-$percentage%",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}





/*
class TSimilarProductCard extends StatelessWidget {
  const TSimilarProductCard({super.key, required this.product});

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
        // 🌟 تحديد عرض ثابت للبطاقة لتستقر داخل الـ ListView الأفقي بدون أخطاء
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: dark ? TColors.darkContainer : TColors.white,
          boxShadow: [
            BoxShadow(
              color: dark ? Colors.black26 : Colors.grey.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
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
            /// 1. الجزء العلوي: الصورة بحجم ثابت ومحكوم هندسياً
            Stack(
              children: [
                Container(
                  width:
                      TDeviceUtils.getScreenWidth(context) *
                      0.35, // عرض ثابت بنسبة من الشاشة
                  height: 170, // الارتفاع المثالي المتناسق مع نسبة العرض
                  padding: const EdgeInsets.all(4),
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

            /// 2. الجزء السفلي: البيانات (العنوان + السعر وزر الإضافة)
            /// تم استخدام Padding متساوي ومحكم لمنع حدوث أي Overflow للنصوص
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 8,
                  top: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // لتثبيت الأسعار دائماً في الأسفل
                  children: [
                    // العنوان
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13, // حجم ناعم ومناسب لعرض الكارد
                      ),
                    ),

                    // السعر والزر في صف واحد ملاصق لأسفل البطاقة
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
                                  fontSize:
                                      14, // متناسق تماماً مع مساحة الـ 180 بكسل
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

  Widget _buildSaleTag(String percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: TColors.secondary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "-$percentage%",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
*/




/*
class TSimilarProductCard extends StatelessWidget {
  const TSimilarProductCard({super.key, required this.product});

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
        // 🌟 تحديد عرض ثابت بدقة لكي تتناسق البطاقات بجانب بعضها في التمرير الأفقي
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            20,
          ), // نفس الحواف الدائرية الكبيرة
          color: dark ? TColors.darkContainer : TColors.white,
          boxShadow: [
            BoxShadow(
              color: dark ? Colors.black26 : Colors.grey.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15), // نفس الظل الممتد لأسفل بدقة
            ),
          ],
          border: Border.all(
            color: dark ? Colors.white10 : Colors.black.withOpacity(0.03),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:
              MainAxisSize.min, // يجعل العمود مرناً يلتف حول عناصره بأمان
          children: [
            /// 1. الجزء العلوي: الصورة (تم الحفاظ عليها مربعة وبنفس الحواف عبر AspectRatio)
            AspectRatio(
              aspectRatio:
                  1.0, // يضمن نسبة 1:1 (مربعة تماماً) بدون الحاجة لـ Expanded
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    margin: const EdgeInsets.all(
                      4,
                    ), // نفس الهامش الجمالي للصورة
                    child: TRoundedImage(
                      imageUrl: product.thumbnail,
                      isNetworkImage: true,
                      applyImageRadius: true,
                      borderRadius: 16,
                      borderRadiusShapcircular: false,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // شارة الخصم المحفوظة بدقة
                  if (salePercentage != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _buildSaleTag(salePercentage),
                    ),

                  // زر المفضلة بنفس المكان
                  Positioned(
                    top: 5,
                    right: 5,
                    child: FavouriteIcon(productId: product.id),
                  ),
                ],
              ),
            ),

            /// 2. الجزء السفلي: النصوص والسعر وزر الإضافة
            Padding(
              // حشوة داخلية متناسقة ومريحة لحواف النصوص والأسعار
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان المحافظ على نفس خصائصه بدقة (سطرين كحد أقصى)
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // مسافة رأسية ثابتة وآمنة تفصل العنوان عن السعر بدلاً من SpaceBetween المفتوح
                  const SizedBox(height: 12),

                  // السعر والزر في صف واحد متناسق أسفل البطاقة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment:
                        CrossAxisAlignment.end, // محاذاة العناصر للأسفل جمالياً
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
                                fontSize:
                                    15, // تعديل بسيط جداً ليناسب حجم الخط العرضي الصغير
                                fontWeight: FontWeight.w900,
                                color: dark ? TColors.primary : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // زر الإضافة السريع
                      ProductCartAddToCartButton(product: product),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت فرعي لشارة الخصم بنقس المظهر تماماً
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
*/



/*
class TSimilarProductCard extends StatelessWidget {
  const TSimilarProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = ProductController.instance;
    final salePercentage = controller.calculateSalePercentage(
      product.price,
      product.salePrice,
    );

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetails(product: product)),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [TShadowStyle.verticalProductShadow],
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          color: dark ? TColors.darkerGrey : TColors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// -- الجزء العلوي (الصورة + الخصم)
            Stack(
              children: [
                // الصورة مع Aspect Ratio ثابت لضمان تناسق الشبكة
                AspectRatio(
                  aspectRatio: 1,
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
            Padding(
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

        /*
        child: Column(
          children: [
            /// الصورة والخصم
            TRoundedContainer(
              heigth: 160,
              padding: const EdgeInsets.all(TSizes.sm),
              backgroundColor: dark ? TColors.dark : TColors.light,
              child: Stack(
                children: [
                  /// الصورة
                  TRoundedImage(
                    imageUrl: product.thumbnail,
                    applyImageRadius: true,
                    isNetworkImage: true,
                  ),

                  /// علامة الخصم (إن وجد)
                  if (product.salePrice != null)
                    Positioned(
                      top: 12,
                      child: TRoundedContainer(
                        radius: TSizes.sm,
                        backgroundColor: TColors.secondary.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.sm,
                          vertical: TSizes.xs,
                        ),
                        child: Text(
                          '${((product.price - product.salePrice!) / product.price * 100).toStringAsFixed(0)}%',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge!.apply(color: TColors.black),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwItems / 2),

            /// التفاصيل
            Padding(
              padding: const EdgeInsets.only(left: TSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TproductText(title: product.title, smallSize: true),

                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// السعر
                      Flexible(
                        child: TTextPrice(price: product.price.toString()),
                      ),

                      /// زر الإضافة السريع
                      Container(
                        decoration: const BoxDecoration(
                          color: TColors.dark,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(TSizes.cardRadiusMd),
                            bottomRight: Radius.circular(
                              TSizes.productImageRadius,
                            ),
                          ),
                        ),
                        child: const SizedBox(
                          width: TSizes.iconLg * 1.2,
                          height: TSizes.iconLg * 1.2,
                          child: Center(
                            child: Icon(Iconsax.add, color: TColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      */
      ),
    );
  }
}
*/