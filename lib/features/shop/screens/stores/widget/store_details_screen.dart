import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:untitled2_ecom/common/widgets/productes/produt_card_vertical.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/vertical_product_shimmer.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/features/shop/controllers/store_details_controller.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class StoreDetailsScreen extends StatelessWidget {
  const StoreDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. استدعاء الكونترولر وتمرير المتجر المختار له
    final controller = Get.put(StoreDetailsController());
    // جلب المتجر لعرضه في الواجهة (اللوجو، الاسم، الوصف)
    final store = controller.selectedStore.value;

    final ScrollController scrollController = ScrollController();
    final dark = THelperFunctions.isDarkMode(context);

    // 2. إضافة مستشعر للتمرير (Infinite Scroll)
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        controller.fetchMoreProducts();
      }
    });

    return Scaffold(
      body: CustomScrollView(
        controller: scrollController, // ربط المتحكم بالتمرير
        slivers: [
          // 1. الجزء العلوي المتفاعل (Header)
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            automaticallyImplyLeading: false,
            backgroundColor: dark ? TColors.dark : TColors.white,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: dark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: dark ? Brightness.dark : Brightness.light,
            ),
            // زر العودة
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.arrow_back,
                color: dark ? TColors.white : TColors.black,
              ),
            ),
            // الجزء الذي يظهر عند التمدد
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                children: [
                  // صورة الغلاف (Banner)
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: store
                          .storeBanner, // تأكد من وجود هذا الحقل في الموديل
                      fit: BoxFit.cover,
                    ),
                  ),
                  // طبقة ظل خفيفة لتحسين رؤية اللوجو
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),

                  // لوجو المتجر في المنتصف
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: TColors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(store.storeLogo),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // اللوجو الصغير الذي يظهر في الـ AppBar عند التمرير
              title: LayoutBuilder(
                builder: (context, constraints) {
                  var top = constraints.biggest.height;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: top < 100 ? 1.0 : 0.0,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            store.storeLogo,
                          ),
                          radius: 15,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          store.storName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. بيانات المتجر (الاسم، الوصف، التواصل)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المتجر وحالة التوثيق
                  Row(
                    children: [
                      Text(
                        store.storName,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (store.isVerified) ...[
                        const SizedBox(width: 5),
                        const Icon(
                          Iconsax.verify5,
                          color: TColors.primary,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),

                  // العنوان
                  Row(
                    children: [
                      const Icon(
                        Iconsax.location,
                        size: 16,
                        color: TColors.darkGrey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        store.addressModel.fullAddress,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // الوصف (في حاوية نظيفة)
                  Text(
                    store.storeDescription,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge!.apply(fontSizeDelta: 2),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // أزرار التواصل السريع
                  Row(
                    children: [
                      _buildQuickContact(context, Iconsax.call, "اتصال", () {}),
                      const SizedBox(width: TSizes.spaceBtwItems),
                      _buildQuickContact(
                        context,
                        Iconsax.mobile5,
                        "واتساب",
                        () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: TSizes.spaceBtwSections),

                  // عنوان قسم المنتجات
                  const sectionHeading(
                    labelText: "منتجات المتجر",
                    showButtton: false,
                  ),
                ],
              ),
            ),
          ),

          // 3. عرض المنتجات (Grid)
          // --- عرض المنتجات بنظام Obx لمراقبة التغيرات ---
          Obx(() {
            // حالة التحميل الأول (فقط إذا كانت القائمة فارغة والإنترنت بطيء)
            if (controller.isLoding.value &&
                controller.featuredProducts.isEmpty) {
              return const SliverToBoxAdapter(child: VerticalProductShimmer());
            }

            // حالة عدم وجود منتجات للمتجر
            if (controller.featuredProducts.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Text("لا توجد منتجات حالياً في هذا المتجر"),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: TSizes.defaultSpace,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: TSizes.gridViewSpacing,
                  crossAxisSpacing: TSizes.gridViewSpacing,
                  mainAxisExtent: 288,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return ProdutCardVertical(
                    product: controller.featuredProducts[index],
                  );
                }, childCount: controller.featuredProducts.length),
              ),
            );
          }),

          // --- مؤشر تحميل إضافي عند جلب المزيد (Pagination Loading) ---
          Obx(() {
            if (controller.isMoreLoding.value) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(TSizes.defaultSpace),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            return const SliverToBoxAdapter(
              child: SizedBox(height: TSizes.spaceBtwSections),
            );
          }),
        ],
      ),
    );
  }

  // ودجت وسيلة التواصل
  Widget _buildQuickContact(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
