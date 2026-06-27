import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/common/widgets/appbar/tabbar.dart';
import 'package:untitled2_ecom/common/widgets/custom_shapes/containers/TSearchContainer.dart';
import 'package:untitled2_ecom/common/widgets/layouts/grid_layout.dart';
import 'package:untitled2_ecom/common/widgets/productes_cart/Cart_menu_icon.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/brand_shimmer.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/common/widgets/brands/brand_card.dart';
import 'package:untitled2_ecom/features/shop/controllers/brand_controller.dart';
import 'package:untitled2_ecom/features/shop/controllers/category_controller.dart';
import 'package:untitled2_ecom/features/shop/screens/brands/brand_products.dart';
import 'package:untitled2_ecom/features/shop/screens/brands/brands.dart';
import 'package:untitled2_ecom/features/shop/screens/store/widget/category_tab.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class Store extends StatelessWidget {
  const Store({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = CategoryController.instance.featuredCategories;
    final brandController = Get.put(BrandController());
    final bool dark = THelperFunctions.isDarkMode(context);

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: TAppbar(
          showBackArrow: false,
          title: Text(
            TTexts.store,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: [TCartCountIcon(iconColor: TColors.dark, onPressed: () {})],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                backgroundColor: dark ? TColors.black : TColors.white,
                expandedHeight: 440,
                flexibleSpace: Padding(
                  padding: EdgeInsetsGeometry.all(TSizes.defaultSpace),
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: TSizes.spaceBtwItems),
                      TSearchContainer(
                        serarchLabel: TTexts.tDashboardSearch,
                        showBackground: false,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      sectionHeading(
                        labelText: TTexts.featuredBrands,
                        showButtton: true,
                        padding: EdgeInsets.all(0),
                        onPressed: () => Get.to(() => Brands()),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems / 1.5),

                      Obx(() {
                        if (brandController.isLoding.value) {
                          return TBrandShimmer();
                        }

                        if (brandController.fetureBrands.isEmpty) {
                          return Center(
                            child: Text(
                              "لم يتم العثور على بيانات!",
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .apply(color: Colors.white),
                            ),
                          );
                        }
                        return TGridLayout(
                          itemCount: brandController.fetureBrands.length,
                          mainAxisExtent: 88,
                          itemBuilder: (p0, p1) {
                            final brand = brandController.fetureBrands[p1];
                            return TBrandCard(
                              showBorder: true,
                              brand: brand,
                              onTap: () =>
                                  Get.to(() => BrandProducts(brand: brand)),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
                bottom: TTabBar(
                  tabs: categories
                      .map((element) => Tab(child: Text(element.name)))
                      .toList(),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: categories
                .map((element) => TCategoryTab(category: element))
                .toList(),
          ),
        ),
      ),
    );
  }
}
