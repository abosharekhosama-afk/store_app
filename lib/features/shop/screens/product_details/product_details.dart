import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:untitled2_ecom/common/widgets/custom_shapes/curved_edges/TCuvedEdgeWidget.dart';
import 'package:untitled2_ecom/common/widgets/favourite_icon/favourite_icon.dart';
import 'package:untitled2_ecom/common/widgets/icons/circular_icon.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/similar_product_shimmer.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/product_controller.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/features/shop/screens/checkout/checkout.dart';
import 'package:untitled2_ecom/features/shop/screens/product_details/widgets/bottom_add_to_cart_widget.dart';
import 'package:untitled2_ecom/features/shop/screens/product_details/widgets/more_product.dart';
import 'package:untitled2_ecom/features/shop/screens/product_details/widgets/productMetaData.dart';
import 'package:untitled2_ecom/features/shop/screens/product_details/widgets/product_attributs.dart';
import 'package:untitled2_ecom/features/shop/screens/product_details/widgets/product_image_slider.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = ProductController.instance;
    // 🎯 استدعاء فحص وتتبع الصورة: لن يتم جلب المنتجات المشابهة إلا بعد ظهور صورة المنتج للمستخدم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSimilarProductsAfterImageLoad(
        categoryId: product.categoryId,
        currentProductId: product.id,
        currentProduct: product,
      );
    });
    return Scaffold(
      bottomNavigationBar: TBottomAddToCartWidget(product: product),
      body: CustomScrollView(
        // نستخدم CustomScrollView لدعم تأثيرات الـ Slivers
        slivers: [
          /// 1. الـ AppBar السحري (يتحول من صورة إلى شريط)
          SliverAppBar(
            pinned: true, // يبقى ثابتاً في الأعلى عند التمرير
            expandedHeight: 450, // ارتفاع معرض الصور عند البداية
            automaticallyImplyLeading: false,
            backgroundColor: dark ? TColors.darkerGrey : TColors.white,

            // التحكم في ظهور زر الرجوع والمفضلة فوق الصورة
            leading: Padding(
              padding: const EdgeInsets.only(
                right: 10,
              ), // تعديل الاتجاه لليمين كما طلبت
              child: TCircularIcon(
                icon: Icons.arrow_back, // سهم الرجوع للغة العربية
                onPressed: () => Get.back(),
                color: dark ? TColors.white : TColors.black,
                backgroundColor: Colors.transparent,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FavouriteIcon(productId: product.id),
              ),
            ],

            // الجزء الذي يحتوي على الصورة ويختفي تدريجياً
            flexibleSpace: FlexibleSpaceBar(
              background: TProductImageSlider(product: product),
              collapseMode:
                  CollapseMode.parallax, // تأثير حركة سينمائي عند التمرير
            ),
          ),

          /// 2. محتوى الصفحة (باقي التفاصيل)
          SliverToBoxAdapter(
            child: TCuvedEdgeWidget(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// معلومات المنتج الأساسية
                    TProductmetadata(product: product),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    if (product.isVariableProduct)
                      TProductAttributs(product: product),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => const Checkout()),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text("اتمام الدفع الآن"),
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    const sectionHeading(
                      labelText: "الوصف",
                      showButtton: false,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    ReadMoreText(
                      product.description ?? "",
                      trimLines: 2,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: " عرض المزيد",
                      trimExpandedText: " أقل",
                      moreStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: TColors.primary,
                      ),
                      lessStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: TColors.primary,
                      ),
                    ),

                    const Divider(height: 32),

                    /// المنتجات المشابهة (باستخدام Obx)
                    Obx(() {
                      // 1. إذا كان الكنترولر في حالة جلب البيانات، نعرض الهيدر مع الـ Shimmer
                      if (controller.isLodingSimeler.value) {
                        return const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionHeading(
                              labelText: "قد يعجبك أيضاً",
                              showButtton: false,
                            ),
                            SizedBox(height: TSizes.spaceBtwItems),
                            TSimilarProductShimmer(),
                          ],
                        );
                      }

                      // 2. إذا انتهى التحميل وكانت القائمة المفلترة فارغة، نطلق استدعاء الجلب الآمن كـ Backup ونخفي القسم مؤقتاً
                      if (controller.activeSimilarProducts.isEmpty) {
                        // نستخدم PostFrameCallback لمنع تداخل الـ Build مع تحديث الحالة
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!controller.isLodingSimeler.value) {
                            controller.fetchSimilarProductsAfterImageLoad(
                              categoryId: product.categoryId,
                              currentProductId: product.id,
                              currentProduct: product,
                            );
                          }
                        });
                        return const SizedBox.shrink();
                      }

                      // 3. إذا كانت البيانات جاهزة، نعرض الويدجت بكفاءة
                      return MoreProduct(product: product);
                    }),

                    /*
                    Obx(() {
                      if (controller.isLodingSimeler.value) {
                        return const Column(
                          children: [
                            sectionHeading(
                              labelText: "قد يعجبك أيضاً",
                              showButtton: false,
                            ),
                            SizedBox(height: TSizes.spaceBtwItems),
                            TSimilarProductShimmer(),
                          ],
                        );
                      }

                      if (controller.activeSimilarProducts.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return MoreProduct(product: product);
                    }),
*/
                    const SizedBox(
                      height: 100,
                    ), // مساحة للتمرير خلف الـ Bottom Bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}






/*
class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    //final bool dark = THelperFunctions.isDarkMode(context);
    final controller = ProductController.instance;
    return Scaffold(
      bottomNavigationBar: TBottomAddToCartWidget(product: product),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TProductImageSlider(product: product),

            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // TRatingAndShare(),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TProductmetadata(product: product),
                  if (product.isVariableProduct)
                    TProductAttributs(product: product),
                  //if (product.isSingleProduct)
                  const SizedBox(height: TSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => Checkout()),
                      child: Text("الدفع"),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  sectionHeading(
                    labelText: "الوصف",
                    showButtton: false,
                    padding: EdgeInsets.all(0),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  ReadMoreText(
                    textAlign: TextAlign.start,
                    product.description ?? "",
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: "عرض المزيد",
                    trimExpandedText: "أقل",
                    moreStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    lessStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // داخل الـ Column في ProductDetails
                  Obx(() {
                    // 1. حالة التحميل
                    if (controller.isLodingSimeler.value) {
                      return const Column(
                        children: [
                          sectionHeading(
                            labelText: "قد يعجبك أيضاً",
                            showButtton: false,
                          ),
                          SizedBox(height: TSizes.spaceBtwItems),
                          TSimilarProductShimmer(), // استدعاء الشيمر هنا
                        ],
                      );
                    }

                    // 2. إذا لم توجد منتجات مشابهة (لا تعرض القسم أبداً)
                    if (controller.simaelerProducts.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // 3. عرض البيانات الحقيقية
                    return MoreProduct(product: product);
                  }),

                  const SizedBox(height: TSizes.spaceBtwSections),
                  const SizedBox(height: TSizes.spaceBtwSections),
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