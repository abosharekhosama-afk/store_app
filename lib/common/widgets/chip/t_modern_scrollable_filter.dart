import 'package:flutter/material.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class TModernScrollableFilter<T> extends StatelessWidget {
  final List<T> options; // قائمة الخيارات (قد تكون سترينج أو إينوم)
  final T selectedOption; // الخيار المحدد حالياً
  final String Function(T)
  labelBuilder; // دالة لتحويل الخيار إلى نص عربي يظهر للمستخدم
  final IconData Function(T)?
  iconBuilder; // دالة اختيارية لتحديد أيقونة لكل خيار
  final Function(T) onOptionSelected; // الـ Callback عند ضغط الزر

  const TModernScrollableFilter({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.labelBuilder,
    required this.onOptionSelected,
    this.iconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(6.0),
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
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: options.map((option) {
            final isSelected = option == selectedOption;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: GestureDetector(
                onTap: () => onOptionSelected(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // عرض الأيقونة إذا تم تمرير الـ Builder الخاص بها
                      if (iconBuilder != null) ...[
                        Icon(
                          iconBuilder!(option),
                          color: isSelected ? Colors.white : TColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        labelBuilder(option),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[800],
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
