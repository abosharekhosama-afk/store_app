import 'package:flutter/material.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';
import 'package:iconsax/iconsax.dart'; // أو يمكنك استخدام Icons.clear إذا لم تكن تستخدم iconsax

class TSearchContainerNew extends StatelessWidget {
  const TSearchContainerNew({
    super.key,
    required this.serarchLabel,
    this.controller,
    this.onFieldSubmitted,
    this.onSearchIconPressed,
    this.onChanged,
  });

  final String serarchLabel;
  final TextEditingController? controller;
  final Function(String)? onFieldSubmitted;
  final VoidCallback? onSearchIconPressed;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.md,
        vertical: TSizes.xs,
      ),
      decoration: BoxDecoration(
        color: dark ? TColors.darkerGrey : TColors.light,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(color: TColors.grey.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onFieldSubmitted,
        textInputAction: TextInputAction.search,
        textAlignVertical:
            TextAlignVertical.center, // لضمان موازاة النص مع الأيقونات عمودياً
        decoration: InputDecoration(
          // أيقونة البحث الأساسية في البداية (يسار أو يمين حسب اللغة)
          fillColor: TColors.light,
          icon: GestureDetector(
            onTap: onSearchIconPressed,
            child: const Icon(Icons.search, color: TColors.darkGrey),
          ),
          hintText: serarchLabel,
          hintStyle: Theme.of(context).textTheme.bodySmall,

          // 🌟 إضافة زر الحذف الذكي في نهاية الحقل
          suffixIcon: controller == null
              ? null
              : ListenableBuilder(
                  listenable: controller!,
                  builder: (context, child) {
                    // إذا كان الحقل فارغاً، لا تعرض أيقونة الحذف
                    if (controller!.text.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // إذا كان الحقل يحتوي على نص، اعرض زر الحذف
                    return GestureDetector(
                      onTap: () {
                        controller!.clear(); // مسح النص من الحقل

                        // تفعيل الـ onChanged يدوياً لتحديث حالة البحث وإرجاع المنتجات المميزة فوراً
                        if (onChanged != null) {
                          onChanged!('');
                        }
                      },
                      child: const Icon(
                        Iconsax.close_circle, // أيقونة إغلاق ناعمة وعصرية
                        color: TColors.darkGrey,
                        size: 20,
                      ),
                    );
                  },
                ),

          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}
