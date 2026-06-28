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
