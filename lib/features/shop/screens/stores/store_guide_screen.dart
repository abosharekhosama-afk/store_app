import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/common/widgets/chip/t_modern_scrollable_filter.dart';
import 'package:untitled2_ecom/common/widgets/custom_shapes/containers/search_container_new.dart';
import 'package:untitled2_ecom/features/shop/controllers/store_controller.dart';
import 'package:untitled2_ecom/features/shop/screens/stores/widget/store_large_card.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class StoreGuideScreen extends StatelessWidget {
  const StoreGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoreController());
    final storeSearchController = TextEditingController();

    return Scaffold(
      // 1. أزلنا الـ AppBar التقليدي من هنا لنضعه بداخل الـ NestedScrollView ليتأثر بالتمرير
      body: NestedScrollView(
        headerSliverBuilder: (_, innerBoxIsScrolled) => [
          /// 2. الـ AppBar العلوي المودرن مع خاصية الـ Blur
          SliverToBoxAdapter(
            child: TAppbar(
              showBackArrow: false,
              title: Text(
                "اكتشف المتاجر",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              showBlur: false,
            ),
          ),

          /// 3. تحويل الحاوية العلوية إلى SliverAppBar عائم وذكي (Floating & Snap)
          SliverAppBar(
            pinned: false, // لا نريده ثابتاً عند الصعود لأعلى
            floating:
                true, // الفكرة السحرية: بمجرد سحب الشاشة لأسفل قليلاً يظهر فوراً!
            snap:
                true, // يمتد الشريط بالكامل بمجرد بدء السحب البسيط دون حاجة لسحب مستمر
            automaticallyImplyLeading: false,
            backgroundColor: TColors
                .softWhite, // للحفاظ على جمالية الخلفية والتأثيرات الناعمة
            elevation: 0,
            // الارتفاع التقريبي لمكونات البحث والفلترة مع الحشوات (يمكنك ضبطه ليناسب شاشتك)
            toolbarHeight: 155,
            titleSpacing: 0,

            /// محتوى البحث والفلترة يوضع داخل الـ title للـ SliverAppBar ليتأثر بالحركة الكسولة
            title: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TSizes.defaultSpace,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- محرك البحث المودرن ---
                  TSearchContainerNew(
                    serarchLabel: "ابحث عن متجرك المفضل...",
                    controller: storeSearchController,
                    onFieldSubmitted: (value) => controller.searchStore(value),
                    onSearchIconPressed: () =>
                        controller.searchStore(storeSearchController.text),
                    onChanged: (value) {
                      if (value.trim().isEmpty) {
                        controller.searchQuery.value = "";
                        controller.fetchStoresFromFirebase();
                      }
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // --- شريط تصفية الموقع الموحد ---
                  _buildLocationFilter(controller, context),
                ],
              ),
            ),
          ),
        ],

        /// 4. جسد الصفحة (قائمة عرض المتاجر)
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.filteredStores.isEmpty) {
            return const Center(
              child: Text(
                "لا توجد متاجر متوفرة في هذه المنطقة",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            );
          }
          return ListView.builder(
            // ⚠️ ملاحظة هامة جداً: أزلنا الحشوة العلوية (Top Padding) هنا لكي لا تترك مسافة بيضاء
            // بعد اختفاء الـ AppBar أثناء التمرير لأعلى.
            padding: const EdgeInsets.only(
              left: TSizes.defaultSpace,
              right: TSizes.defaultSpace,
              bottom: TSizes.defaultSpace,
            ),

            // 🌟 الحل هنا: تحديد عدد العناصر الثابت بـ 15
            itemCount: 15,

            itemBuilder: (_, index) {
              // التحقق من أن القائمة تحتوي على بيانات لتجنب أخطاء (Index Out of Bounds) أثناء التجربة
              if (controller.filteredStores.isEmpty) {
                return const SizedBox(); // أو يمكنك عرض مؤشر تحميل أو بطاقة فارغة
              }

              // هنا نقوم بضمان عدم خروج الـ index عن نطاق المصفوفة الفعلية للمتاجر القادمة من الـ Controller
              final storeIndex = index % controller.filteredStores.length;

              return TStoreCard(store: controller.filteredStores[storeIndex]);
            },
          );
          /*return ListView.builder(
            // ⚠️ ملاحظة هامة جداً: أزلنا الحشوة العلوية (Top Padding) هنا لكي لا تترك مسافة بيضاء
            // بعد اختفاء الـ AppBar أثناء التمرير لأعلى.
            padding: const EdgeInsets.only(
              left: TSizes.defaultSpace,
              right: TSizes.defaultSpace,
              bottom: TSizes.defaultSpace,
            ),
            itemCount: controller.filteredStores.length,
            itemBuilder: (_, index) =>
                for(int i=0; i<15; i++) TStoreCard(store: controller.filteredStores[index]),
          );*/
        }),
      ),
    );
  }

  /// دالة بناء الفلترة الجغرافية (بدون تعديل برمجى، فقط تحسين طفيف للهيكل)
  Widget _buildLocationFilter(
    StoreController controller,
    BuildContext context,
  ) {
    final bool dark = THelperFunctions.isDarkMode(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. القائمة المنسدلة للمحافظة
        Expanded(
          flex: 1,
          child: Obx(
            () => Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: dark ? TColors.darkerGrey : TColors.softGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TColors.grey.withOpacity(0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  borderRadius: BorderRadius.circular(12),
                  value: controller.selectedCity.value,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.map_rounded,
                    color: TColors.primary,
                    size: 18,
                  ),
                  items: controller.addressData.keys.map((String gov) {
                    return DropdownMenuItem<String>(
                      value: gov,
                      child: Text(
                        gov,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.updateCity(val);
                  },
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 2. شريط تابات المدن القابل للتمرير الأفقي
        Expanded(
          flex: 3,
          child: Obx(() {
            final List<String> currentCities = [
              "الكل",
              ...controller.addressData[controller.selectedCity.value]!.keys,
            ];

            return TModernScrollableFilter<String>(
              options: currentCities,
              selectedOption: controller.selectedDistrict.value,
              labelBuilder: (city) => city,
              iconBuilder: (city) => city == controller.selectedDistrict.value
                  ? Icons.location_on_rounded
                  : Icons.location_on_outlined,
              onOptionSelected: (city) => controller.updateDistrict(city),
            );
          }),
        ),
      ],
    );
  }
}
