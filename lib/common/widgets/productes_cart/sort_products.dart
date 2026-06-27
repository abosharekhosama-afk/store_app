import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/layouts/grid_layout.dart';
import 'package:untitled2_ecom/common/widgets/productes/produt_card_vertical.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/vertical_product_shimmer.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/all_product_controller.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart'; // تأكد من وجود المجلدات الصحيحة لديك

class TSortProducts extends StatelessWidget {
  const TSortProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AllProductController.instance;
    final bool dark = THelperFunctions.isDarkMode(context);

    // قائمة خيارات الترتيب (النصوص قادمة من الـ الكنترولر أو الـ Constants)
    final List<String> sortOptions = [
      TTexts.sortByName,
      TTexts.sortByLowestPrice,
      TTexts.sortByHighestPrice,
      TTexts.sortByNewest,
      TTexts.sortBySale,
    ];

    // خريطة لربط كل خيار بأيقونة عصرية تناسبه لتعزيز جمالية التصميم المودرن
    final Map<String, IconData> optionIcons = {
      TTexts.sortByName: Icons.sort_by_alpha_rounded,
      TTexts.sortByLowestPrice: Icons.trending_down_rounded,
      TTexts.sortByHighestPrice: Icons.trending_up_rounded,
      TTexts.sortByNewest: Icons.fiber_new_rounded,
      TTexts.sortBySale: Icons.local_offer_outlined,
    };

    return Column(
      children: [
        /// 1. شريط الفلترة المودرن الموحد (القابل للتمرير الأفقي)
        Container(
          padding: const EdgeInsets.all(6.0),
          margin: const EdgeInsets.symmetric(
            //horizontal: TSizes.defaultSpace,
            vertical: TSizes.sm,
          ),
          decoration: BoxDecoration(
            color: dark
                ? TColors.darkerGrey.withOpacity(0.5)
                : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? TColors.darkerGrey : Colors.grey.withOpacity(0.1),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics:
                const BouncingScrollPhysics(), // يعطي مرونة ناعمة أثناء السحب على هواتف الـ iOS والـ Android
            child: Row(
              children: sortOptions.map((option) {
                return Obx(() {
                  final isSelected =
                      controller.selectedSortOption.value == option;

                  return _buildModernSortBtn(
                    title: option,
                    icon: optionIcons[option] ?? Icons.filter_list_rounded,
                    isSelected: isSelected,
                    onTap: () => controller.onSortOptionChange(option),
                  );
                });
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: TSizes.spaceBtwItems),

        /// 2. عرض المنتجات وشبكة الـ Grid
        Expanded(
          child: SingleChildScrollView(
            controller: controller.scrollController,
            child: Column(
              children: [
                Obx(() {
                  if (controller.isLoading.value &&
                      controller.products.isEmpty) {
                    return const VerticalProductShimmer(itemCount: 4);
                  }

                  return TGridLayout(
                    itemCount: controller.products.length,
                    itemBuilder: (_, index) =>
                        ProdutCardVertical(product: controller.products[index]),
                  );
                }),

                /// مؤشر تحميل إضافي عند الـ Pagination (أسفل الصفحة)
                Obx(
                  () =>
                      controller.isLoading.value &&
                          controller.products.isNotEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: TSizes.spaceBtwSections,
                          ),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 2️⃣ التابع الذكي لبناء عناصر الترتيب المودرن القابلة للتمرير
  Widget _buildModernSortBtn({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 3.0,
      ), // مسافة صغيرة بين الأزرار الملتفة
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 14,
          ), // حشوة أفقية مريحة للنصوص المتغيرة الطول
          decoration: BoxDecoration(
            color: isSelected ? TColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: TColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize
                .min, // يضمن أن يأخذ الزر حجم محتواه فقط ليناسب التمرير
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : TColors.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/*
class TSortProducts extends StatelessWidget {
  const TSortProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AllProductController.instance;

    // قائمة خيارات الترتيب
    final List<String> sortOptions = [
      TTexts.sortByName,
      TTexts.sortByLowestPrice,
      TTexts.sortByHighestPrice,
      TTexts.sortByNewest,
      TTexts.sortBySale,
    ];

    return Column(
      children: [
        /// شريط الفلترة المودرن (Horizontal Chips)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sortOptions.map((option) {
              return Obx(() {
                final isSelected =
                    controller.selectedSortOption.value == option;
                return Padding(
                  padding: const EdgeInsets.only(left: TSizes.sm),
                  child: ChoiceChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        controller.onSortOptionChange(option);
                      }
                    },
                    // تصميم مودرن
                    selectedColor: TColors.primary,
                    backgroundColor: Colors.transparent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? TColors.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                    showCheckmark: false, // لإزالة علامة الصح لجمالية التصميم
                    elevation: isSelected ? 2 : 0,
                  ),
                );
              });
            }).toList(),
          ),
        ),

        const SizedBox(height: TSizes.spaceBtwSections),

        /// عرض المنتجات
        Expanded(
          child: SingleChildScrollView(
            controller: controller
                .scrollController, // نقل الكنترولر إلى هنا ليعمل الـ Pagination بشكل صحيح
            child: Column(
              children: [
                Obx(() {
                  // عرض Skeleton Shimmer أثناء التحميل الأول
                  if (controller.isLoading.value &&
                      controller.products.isEmpty) {
                    return const VerticalProductShimmer(itemCount: 4);
                  }

                  return TGridLayout(
                    itemCount: controller.products.length,
                    itemBuilder: (_, index) =>
                        ProdutCardVertical(product: controller.products[index]),
                  );
                }),

                /// مؤشر تحميل إضافي عند الـ Pagination (أسفل الصفحة)
                Obx(
                  () =>
                      controller.isLoading.value &&
                          controller.products.isNotEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: TSizes.spaceBtwSections,
                          ),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
*/














/*
class TSortProducts extends StatelessWidget {
  const TSortProducts({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب النسخة الموجودة من الكنترولر
    final controller = AllProductController.instance;

    return Column(
      children: [
        /// حقل خيارات الترتيب (Dropdown)
        Obx(
          () => DropdownButtonFormField(
            value: controller.selectedSortOption.value,
            decoration: const InputDecoration(prefixIcon: Icon(Iconsax.sort)),
            onChanged: (value) {
              // استدعاء الدالة التي تعيد بناء الاستعلام وجلب البيانات من السيرفر
              controller.onSortOptionChange(value!);
            },
            items:
                [
                      TTexts.sortByName,
                      TTexts.sortByHighestPrice,
                      TTexts.sortByLowestPrice,
                      TTexts.sortByNewest,
                      TTexts.sortBySale,
                    ]
                    .map(
                      (option) =>
                          DropdownMenuItem(value: option, child: Text(option)),
                    )
                    .toList(),
          ),
        ),

        const SizedBox(height: TSizes.spaceBtwSections),

        /// عرض المنتجات في شبكة (Grid)
        Obx(
          () => TGridLayout(
            itemCount: controller.products.length,
            itemBuilder: (_, index) =>
                ProdutCardVertical(product: controller.products[index]),
          ),
        ),
      ],
    );
  }
}


*/









/*
class TSortProducts extends StatelessWidget {
  const TSortProducts({super.key, required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllProductController());
    controller.assignProducts(products);
    return Column(
      children: [
        DropdownButtonFormField(
          onChanged: (value) {
            controller.sortProduct(value!);
          },
          value: controller.selectedSortOption.value,
          decoration: InputDecoration(prefixIcon: Icon(Iconsax.sort)),
          items:
              [
                    {"value": TTexts.sortByName, "label": TTexts.sortByName},
                    {"value": TTexts.sortByNewest, "label": TTexts.sortByNewest},
                    {"value": TTexts.sortByHighestPrice, "label": TTexts.sortByHighestPrice},
                    {"value": TTexts.sortByLowestPrice, "label": TTexts.sortByLowestPrice},
                    {"value": TTexts.sortBySale, "label": TTexts.sortBySale},
                  ]
                  .map(
                    (element) => DropdownMenuItem(
                      value: element["value"],
                      child: Text(element["label"]!),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: TSizes.spaceBtwSections),
        Obx(
          () => TGridLayout(
            itemCount: controller.products.length,
            itemBuilder: (p0, p1) =>
                ProdutCardVertical(product: controller.products[p1]),
          ),
        ),
      ],
    );
  }
}
*/