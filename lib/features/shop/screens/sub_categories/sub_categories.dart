import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/productes/produt_card_vertical.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/tab_shimmer.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/vertical_product_shimmer.dart';
import 'package:untitled2_ecom/features/shop/controllers/category_controller.dart';
import 'package:untitled2_ecom/features/shop/models/category_model.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class SubCategories extends StatelessWidget {
  const SubCategories({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;
    // الحل الأفضل: استدعاء البيانات بعد رسم أول إطار للشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadSubCategoryData(category.id);
    });

    return Scaffold(
      body: Obx(() {
        // حالة التحميل الكلي للصفحة (لأول مرة فقط)
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.subCategories.isEmpty) {
          return const Center(child: Text("لا توجد أقسام فرعية متاحة"));
        }

        return CustomScrollView(
          slivers: [
            // هيدر ثابت يحتوي على السهم والعنوان
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text(
                category.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              elevation: 0,
            ),

            // شريط التبويبات الذي يلتصق بالأعلى (Sticky Tabs)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  alignment: Alignment.bottomRight,
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const TTabShimmer();
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.subCategories.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: TSizes.defaultSpace,
                      ),
                      itemBuilder: (context, index) {
                        return Obx(() {
                          bool isSelected =
                              controller.selectedSubCategoryIndex.value ==
                              index;
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: TSizes.spaceBtwItems,
                            ),
                            child: ChoiceChip(
                              label: Text(controller.subCategories[index].name),
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) {
                                  controller.fetchProductsForSubCategory(
                                    controller.subCategories[index].id,
                                    index,
                                  );
                                }
                              },
                            ),
                          );
                        });
                      },
                    );
                  }),
                ),
              ),
            ),

            // قائمة المنتجات في شبكة (Grid)
            SliverPadding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              sliver: Obx(() {
                if (controller.isLoadingProducts.value) {
                  // يمكنك استبدال هذا بشيمر (Shimmer) لاحقاً
                  return const SliverToBoxAdapter(
                    child: VerticalProductShimmer(),
                  );
                }

                if (controller.categoryProducts.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text("لا توجد منتجات في هذا القسم حالياً"),
                    ),
                  );
                }

                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: TSizes.gridViewSpacing,
                    crossAxisSpacing: TSizes.gridViewSpacing,
                    mainAxisExtent:
                        280, // اضبط الارتفاع حسب تصميم الكارد الخاص بك
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return ProdutCardVertical(
                      product: controller.categoryProducts[index],
                    );
                  }, childCount: controller.categoryProducts.length),
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}

// الكلاس المسؤول عن جعل التبويبات تلتصق بالأعلى
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}























/*
class SubCategories extends StatelessWidget {
  const SubCategories({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;
    return Scaffold(
      appBar: TAppbar(showBackArrow: true, title: Text(category.name)),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              TRoundedImage(
                imageUrl: TImages.promoBanner2,
                width: double.infinity,
                applyImageRadius: true,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              FutureBuilder(
                future: controller.getSubCategory(categoryId: category.id),
                builder: (context, asyncSnapshot) {
                  const loader = HorizantalProductShimmer();
                  final widget = TCloudHelperFunctions.checkMultiRecordState(
                    snapshot: asyncSnapshot,
                    loader: loader,
                  );
                  if (widget != null) return widget;

                  final subCategories = asyncSnapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: subCategories.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final subCategory = subCategories[index];
                      return FutureBuilder(
                        future: controller.getCategoryProducts(
                          categoryId: subCategory.id,
                        ),
                        builder: (context, asyncSnapshot) {
                          final widget =
                              TCloudHelperFunctions.checkMultiRecordState(
                                snapshot: asyncSnapshot,
                                loader: loader,
                              );
                          if (widget != null) return widget;

                          final products = asyncSnapshot.data!;

                          return Column(
                            children: [
                              sectionHeading(
                                labelText: subCategory.name,
                                showButtton: true,
                                onPressed: () => Get.to(
                                  () => AllProducts(
                                    title: subCategory.name,
                                    futureMethod: controller
                                        .getCategoryProducts(
                                          categoryId: subCategory.id,
                                          limit: -1,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: TSizes.spaceBtwItems),

                              //width: double.infinity,
                              SizedBox(
                                height: 130,
                                width: double.infinity,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(
                                        width: TSizes.spaceBtwItems,
                                      ),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) =>
                                      TProductCardHorizantal(
                                        product: products[index],
                                      ),
                                ),
                              ),
                              const SizedBox(height: TSizes.spaceBtwSections),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/