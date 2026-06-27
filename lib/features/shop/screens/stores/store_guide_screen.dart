import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/common/widgets/chip/TModernScrollableFilter.dart';
import 'package:untitled2_ecom/common/widgets/custom_shapes/containers/search_container_new.dart';
import 'package:untitled2_ecom/features/shop/controllers/store_controller_new.dart';
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



/*
class StoreGuideScreen extends StatelessWidget {
  const StoreGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoreController());
    final storeSearchController = TextEditingController();
    return Scaffold(
      appBar: TAppbar(
        showBackArrow: false,
        title: Text(
          "اكتشف المتاجر",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        showBlur: true,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (_, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  // محرك البحث
                  TSearchContainerNew(
                    serarchLabel: "ابحث عن متجرك المفضل...",
                    controller: storeSearchController,

                    // السيناريو الأول: الضغط على زر بحث من كيبورد الهاتف
                    onFieldSubmitted: (value) => controller.searchStore(value),

                    // السيناريو الثاني: الضغط على أيقونة العدسة
                    onSearchIconPressed: () =>
                        controller.searchStore(storeSearchController.text),

                    // السيناريو الثالث: إذا مسح النص بالكامل، نعيد المتاجر الافتراضية بدون ضغط زر بحث
                    onChanged: (value) {
                      if (value.trim().isEmpty) {
                        controller.searchQuery.value = "";
                        controller
                            .fetchStoresFromFirebase(); // إرجاع القائمة الكاملة المفلترة بالمدينة فقط
                      }
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // شريط اختيار المحافظة (Horizontal Chips)
                  _buildLocationFilter(controller, context),
                ],
              ),
            ),
          ),
        ],
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            itemCount: controller.filteredStores.length,
            itemBuilder: (_, index) =>
                TStoreCard(store: controller.filteredStores[index]),
          );
        }),
      ),
    );
  }
  /*
  Widget _buildLocationFilter(
    StoreController controller,
    BuildContext context,
  ) {
    final isDark = THelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "تصفية المتاجر حسب الموقع",
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        Row(
          children: [
            // 1. القائمة المنسدلة الاحترافية (المحافظة)
            Expanded(
              flex: 2, // زدنا المساحة قليلاً لتناسب تصميم المكتبة
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    // تخصيص شكل الزر الخارجي
                    buttonStyleData: ButtonStyleData(
                      height: 45,
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: TColors.grey.withOpacity(0.3),
                        ),
                        color: isDark ? TColors.darkerGrey : TColors.softGrey,
                      ),
                    ),
                    // تخصيص أيقونة السهم
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.arrow_drop_down, color: TColors.primary),
                      iconSize: 24,
                    ),
                    // تخصيص القائمة التي تظهر عند النقر
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: isDark ? TColors.darkerGrey : Colors.white,
                      ),
                      elevation: 8,
                      offset: const Offset(0, -5), // إزاحة خفيفة لتبدو طافية
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: WidgetStateProperty.all(6),
                        thumbVisibility: WidgetStateProperty.all(true),
                      ),
                    ),
                    // تخصيص شكل العناصر داخل القائمة
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.symmetric(horizontal: 14),
                    ),

                    value: controller.selectedGov.value,
                    items: controller.addressData.keys.map((String gov) {
                      return DropdownMenuItem<String>(
                        value: gov,
                        child: Text(
                          gov,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.updateGovernorate(val);
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // 2. تابات المناطق (المدن)
            Expanded(
              flex: 3,
              child: Obx(() {
                final cities = [
                  "الكل",
                  ...controller.addressData[controller.selectedGov.value]!.keys,
                ];
                return SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      return Obx(() {
                        final isSelected =
                            controller.selectedCity.value == city;
                        return GestureDetector(
                          onTap: () => controller.updateCity(city),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? TColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? TColors.primary
                                    : TColors.grey.withOpacity(0.5),
                              ),
                              // إضافة ظل خفيف عند الاختيار
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: TColors.primary.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                city,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white70
                                            : Colors.black87),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
*/

  Widget _buildLocationFilter(
    StoreController controller,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "تصفية المتاجر حسب الموقع",
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        Row(
          children: [
            // 1. القائمة المنسدلة (المحافظة) - تأخذ مساحة 40% من العرض مثلاً
            Expanded(
              flex: 1,
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: THelperFunctions.isDarkMode(context)
                        ? TColors.darkerGrey
                        : TColors.softGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TColors.grey.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      borderRadius: BorderRadius.circular(TSizes.buttonRadius),
                      value: controller.selectedCity.value,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: TColors.primary,
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

            // 2. تابات المناطق (المدن) - تأخذ المساحة المتبقية
            Expanded(
              flex: 3,
              child: Obx(() {
                final cities = [
                  "الكل",
                  ...controller
                      .addressData[controller.selectedCity.value]!
                      .keys,
                ];
                return SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      return Obx(() {
                        final isSelected =
                            controller.selectedDistrict.value == city;
                        return GestureDetector(
                          onTap: () => controller.updateDistrict(city),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? TColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? TColors.primary
                                    : TColors.grey.withOpacity(0.5),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                city,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : (THelperFunctions.isDarkMode(context)
                                            ? Colors.white70
                                            : Colors.black87),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  void _showLocationBottomSheet(
    StoreController controller,
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "اختر موقعك لتصفح المتاجر",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // اختيار المحافظة بتصميم كروت صغيرة
            Text("المحافظة", style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: controller.addressData.keys
                    .map(
                      (gov) => Obx(
                        () => Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ChoiceChip(
                            label: Text(gov),
                            selected: controller.selectedCity.value == gov,
                            onSelected: (val) {
                              if (val) controller.updateCity(gov);
                            },
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              "المنطقة / المدينة",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),

            // عرض المناطق كـ Grid لتسهيل الاختيار
            Expanded(
              child: Obx(() {
                final cities = [
                  "الكل",
                  ...controller
                      .addressData[controller.selectedCity.value]!
                      .keys,
                ];
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: 40,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: cities.length,
                  itemBuilder: (_, index) => Obx(() {
                    final isSelected =
                        controller.selectedDistrict.value == cities[index];
                    return ActionChip(
                      label: Center(
                        child: Text(
                          cities[index],
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      backgroundColor: isSelected
                          ? TColors.primary
                          : TColors.light,
                      onPressed: () {
                        controller.updateDistrict(cities[index]);
                        Navigator.pop(context); // إغلاق بعد الاختيار
                      },
                    );
                  }),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLocationBar(
    StoreController controller,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () => _showLocationBottomSheet(controller, context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: TColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: TColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: TColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(
                () => Text(
                  "عرض المتاجر في: ${controller.selectedCity.value} - ${controller.selectedDistrict.value}",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Icon(Icons.unfold_more_rounded, color: TColors.primary),
          ],
        ),
      ),
    );
  }

  /*
  Widget _buildLocationFilter(
    StoreController controller,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. القائمة المنسدلة للمحافظات بتصميم احترافي
        Text("اختر المحافظة", style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: TSizes.spaceBtwItems / 2),

        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.selectedGov.value,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.map_outlined),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              fillColor: THelperFunctions.isDarkMode(context)
                  ? TColors.darkerGrey
                  : TColors.light,
              filled: true,
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            items: controller.addressData.keys.map((String gov) {
              return DropdownMenuItem<String>(
                value: gov,
                child: Text(gov, style: Theme.of(context).textTheme.bodyLarge),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) controller.updateGovernorate(newValue);
            },
          ),
        ),

        const SizedBox(height: TSizes.spaceBtwSections / 1.5),

        // 2. شريط المناطق (Tabs) بتصميم حديث ومميز
        Text("المناطق المتاحة", style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: TSizes.spaceBtwItems / 2),

        Obx(() {
          final cities = [
            "الكل",
            ...controller.addressData[controller.selectedGov.value]!.keys,
          ];

          return SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                return Obx(() {
                  final isSelected = controller.selectedCity.value == city;
                  return GestureDetector(
                    onTap: () => controller.updateCity(city),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(left: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? TColors.primary
                            : (THelperFunctions.isDarkMode(context)
                                  ? TColors.dark
                                  : TColors.softGrey),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: TColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                        border: Border.all(
                          color: isSelected
                              ? TColors.primary
                              : TColors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          city,
                          style: Theme.of(context).textTheme.titleSmall!
                              .copyWith(
                                color: isSelected
                                    ? TColors.white
                                    : (THelperFunctions.isDarkMode(context)
                                          ? TColors.light
                                          : TColors.dark),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          );
        }),
      ],
    );
  }
*/
  /*
  Widget _buildLocationFilter(
    StoreController controller,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان المحافظة
        Text("المحافظة", style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: TSizes.spaceBtwItems / 2),

        // 1. شريط المحافظات - (تم إزالة SliverToBoxAdapter من هنا)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.addressData.keys.map((gov) {
              return Obx(() {
                final isSelected = controller.selectedGov.value == gov;
                return Padding(
                  padding: const EdgeInsets.only(left: TSizes.sm),
                  child: ChoiceChip(
                    label: Text(gov),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) controller.updateGovernorate(gov);
                    },
                  ),
                );
              });
            }).toList(),
          ),
        ),

        const SizedBox(height: TSizes.spaceBtwItems),

        // 2. شريط المدن الديناميكي
        Obx(() {
          final cities = [
            "الكل",
            ...controller.addressData[controller.selectedGov.value]!.keys,
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "المنطقة / المدينة",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cities.length,
                  itemBuilder: (_, index) => Obx(() {
                    final isSelected =
                        controller.selectedCity.value == cities[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text(cities[index]),
                        selected: isSelected,
                        onSelected: (val) =>
                            controller.updateCity(cities[index]),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
*/
  /*
  Widget _buildLocationFilter(
    StoreController controller,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان جانبي بسيط
        Text("المحافظة", style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: TSizes.spaceBtwItems / 2),

        // 1. شريط المحافظات
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.addressData.keys.map((gov) {
                return Obx(() {
                  final isSelected = controller.selectedGov.value == gov;
                  return Padding(
                    padding: const EdgeInsets.only(left: TSizes.sm),
                    child: ChoiceChip(
                      label: Text(gov),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          controller.selectedGov.value = gov;
                          controller.selectedCity.value =
                              "الكل"; // إعادة التصفير
                          controller.applyFilter();
                        }
                      },
                      selectedColor: TColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : TColors.black,
                      ),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: isSelected ? TColors.primary : TColors.grey,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: TSizes.spaceBtwItems),

        // 2. شريط المدن الديناميكي (يظهر فقط عند اختيار محافظة)
        Obx(() {
          final cities = [
            "الكل",
            ...controller.addressData[controller.selectedGov.value]!.keys,
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "المنطقة / المدينة",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cities.length,
                  itemBuilder: (_, index) => Obx(() {
                    final isSelected =
                        controller.selectedCity.value == cities[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text(cities[index]),
                        selected: isSelected,
                        onSelected: (val) {
                          controller.selectedCity.value = cities[index];
                          controller.applyFilter();
                        },
                        checkmarkColor: Colors.white,
                        selectedColor:
                            TColors.secondary, // لون مختلف قليلاً للتمييز
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : TColors.darkGrey,
                          fontSize: 12,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
*/
  /*
  Widget _buildLocationFilter(StoreController controller) {
    final governorates = ["الكل", "غزة", "الشمال", "الوسطى", "خانيونس", "رفح"];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: governorates.length,
        itemBuilder: (_, index) => Obx(() {
          bool isSelected =
              controller.selectedGovernorate.value == governorates[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(governorates[index]),
              selected: isSelected,
              onSelected: (val) {
                controller.selectedGovernorate.value = governorates[index];
                controller.filterByLocation();
              },
            ),
          );
        }),
      ),
    );
  }
*/
}
*/