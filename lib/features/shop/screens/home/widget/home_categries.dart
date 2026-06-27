import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/image_text_widget/categrie_widget.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/category_shimmers.dart';
import 'package:untitled2_ecom/features/shop/controllers/category_controller.dart';
import 'package:untitled2_ecom/features/shop/screens/sub_categories/sub_categories.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class THomeCategries extends StatelessWidget {
  const THomeCategries({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());
    return Obx(() {
      if (controller.isLoading.value) return const TCategoryShimmers();
      if (controller.featuredCategories.isEmpty) {
        return Center(
          child: Text(
            "لم يتم العثور على بيانات!",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.apply(color: Colors.white),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(right: TSizes.defaultSpace),
        child: SizedBox(
          height: 88,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.featuredCategories.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return TCategrieWidget(
                icon: controller.featuredCategories[index].image,
                leabel: controller.featuredCategories[index].name,
                OnTap: () => Get.to(
                  () => SubCategories(
                    category: controller.featuredCategories[index],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
