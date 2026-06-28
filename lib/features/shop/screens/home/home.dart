import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/custom_shapes/containers/search_container_new.dart';
import 'package:untitled2_ecom/common/widgets/custom_shapes/curved_edges/t_modern_header_design.dart';
import 'package:untitled2_ecom/common/widgets/productes/produt_card_vertical.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/vertical_product_shimmer.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/product_controller.dart';
import 'package:untitled2_ecom/features/shop/screens/all_products/all_products.dart';
import 'package:untitled2_ecom/features/shop/screens/home/widget/home_appbar.dart';
import 'package:untitled2_ecom/features/shop/screens/home/widget/home_categries.dart';
import 'package:untitled2_ecom/features/shop/screens/home/widget/promo_slider.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/utils/device/device_utils.dart';
import 'package:untitled2_ecom/utils/helpers/helper_functions.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());
    final bool dark = THelperFunctions.isDarkMode(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      // استخدام المقاسات الافتراضية الذكية بدون إزالة الـ Padding بالكامل لتجنب مشاكل الأبعاد
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          // يمكنك الاحتفاظ بتتبع الأوفست إذا كنت تحتاجه لعمليات أخرى مثل (تحميل المزيد Pagination)
          if (scrollNotification.metrics.axis == Axis.vertical) {
            controller.scrollOffset.value = scrollNotification.metrics.pixels;
          }
          return false;
        },
        child: CustomScrollView(
          key: const PageStorageKey<String>('home_scroll_key'),
          controller: controller.scrollController,
          slivers: [
            // ---------------------------------------------------------------------------
            // 1. الـ SliverAppBar العائم والمطور (Floating App Bar Logic)
            // ---------------------------------------------------------------------------
            SliverAppBar(
              forceMaterialTransparency: true,
              pinned: false, // نجعله false لكي يختفي بالكامل عند التمرير لأسفل
              floating:
                  true, // [السحر هنا]: يظهر فوراً بمجرد التمرير البسيط لأعلى
              snap:
                  true, // يجعل الهيدر يفتح ويغلق بسلاسة كقطعة واحدة مطاطية مريحة للعين
              expandedHeight:
                  245, // مقاس متناسق ومريح لعدم تمديد الواجهة أكثر من اللازم
              automaticallyImplyLeading: false,
              toolbarHeight: kToolbarHeight,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),

              // [الجزء المتمدد المفتوح]: يختفي ويظهر ديناميكياً مع حركة اليد
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode
                    .parallax, // تأثير البارالاكس العالمي الناعم أثناء الحركة
                background: ClipPath(
                  clipper: TModernCurvedClipper(),
                  child: TModernHeaderDesign(
                    isCollapsed: false,
                    statusBarHeight: statusBarHeight,
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          const THomeAppBar(),
                          const SizedBox(height: TSizes.spaceBtwItems / 2),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TSizes.defaultSpace,
                            ),
                            child: Column(
                              children: [
                                TSearchContainerNew(
                                  serarchLabel: "ابحث عن منتجاتك...",
                                  controller:
                                      controller.searchTextFieldController,
                                  onFieldSubmitted: (value) =>
                                      controller.searchProducts(value),
                                  onSearchIconPressed: () =>
                                      controller.searchProducts(
                                        controller
                                            .searchTextFieldController
                                            .text,
                                      ),
                                  onChanged: (value) {
                                    if (value.trim().isEmpty) {
                                      controller.searchQuery.value = "";
                                      controller.searchResults.clear();
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwItems / 2,
                                ),
                                sectionHeading(
                                  labelText: TTexts.popularProducts,
                                  showButtton: false,
                                  textColor: dark ? Colors.white : Colors.black,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems / 2),
                          const THomeCategries(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ---------------------------------------------------------------------------
            // 2. شريط التصنيفات الثابت (يتحرك مع الصفحة بشكل طبيعي ومنظم)
            // ---------------------------------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: TSizes.spaceBtwSections),
                    const TPromoSlider(),
                    const SizedBox(height: TSizes.spaceBtwSections),
                    sectionHeading(
                      padding: EdgeInsets.zero,
                      labelText: "المنتجات المميزة",
                      showButtton: true,
                      textColor: dark ? TColors.white : TColors.black,
                      onPressed: () => Get.to(
                        () => AllProducts(
                          title: "جميع المنتجات",
                          futureMethod: controller.fetchAllFeaturedProducts(),
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                  ],
                ),
              ),
            ),

            // ---------------------------------------------------------------------------
            // 3. شبكة عرض المنتجات المميزة أو نتائج البحث (Grid)
            // ---------------------------------------------------------------------------
            Obx(() {
              if (controller.isLoding.value ||
                  controller.isSearchLoading.value) {
                return const SliverToBoxAdapter(
                  child: VerticalProductShimmer(),
                );
              }

              final productsToShow = controller.searchQuery.value.isNotEmpty
                  ? controller.searchResults
                  : controller.featuredProducts;

              if (productsToShow.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Text("لا توجد نتائج تطابق بحثك!"),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace / 2,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: TSizes.gridViewSpacing / 2,
                    crossAxisSpacing: TSizes.gridViewSpacing / 2,
                    mainAxisExtent: 288,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        ProdutCardVertical(product: productsToShow[index]),
                    childCount: productsToShow.length,
                  ),
                ),
              );
            }),

            // ---------------------------------------------------------------------------
            // 4. مؤشر التحميل الإضافي (Pagination Loader) والمسافة السفلية للـ Navigation
            // ---------------------------------------------------------------------------
            SliverToBoxAdapter(
              child: Obx(
                () => Column(
                  children: [
                    if (controller.isMoreLoding.value ||
                        controller.isMoreSearchLoading.value)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: TSizes.spaceBtwSections,
                        ),
                        child: CircularProgressIndicator(),
                      ),
                    SizedBox(
                      height:
                          TDeviceUtils.getBottomNavigationBarHeight() +
                          TSizes.spaceBtwSections * 2,
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
}
