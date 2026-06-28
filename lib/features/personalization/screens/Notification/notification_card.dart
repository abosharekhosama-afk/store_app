import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/helpers/helper_functions.dart';

class NotificationCard extends StatelessWidget {
  final Map data;
  final VoidCallback onTap;

  const NotificationCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isOpened = data['isOpened'] ?? false;
    final bool isDark = THelperFunctions.isDarkMode(context);
    final String type = data['type'] ?? 'GENERAL';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // استخدام خلفية خفيفة جداً للإشعارات غير المقروءة
          color: isOpened
              ? (isDark ? TColors.darkerGrey : Colors.white)
              : TColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          // ظل ناعم جداً يعطي عمقاً دون حدة
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isOpened ? 0.02 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          // بوردر خفيف جداً لتمييز البطاقة في الوضع الداكن
          border: isDark
              ? Border.all(color: TColors.darkGrey.withOpacity(0.5))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. الأيقونة داخل شكل هندسي حديث
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getIconColor(type, isOpened).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(type),
                color: _getIconColor(type, isOpened),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // 2. المحتوى النصي
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data['title'] ?? "",
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                fontWeight: isOpened
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                                fontSize: 15,
                              ),
                        ),
                      ),
                      // نقطة الإشعار الجديد
                      if (!isOpened)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: TColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['body'] ?? "",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: isOpened
                          ? Colors.grey
                          : (isDark ? Colors.white70 : Colors.black87),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // الوقت بتنسيق عصري
                  Row(
                    children: [
                      const Icon(Iconsax.clock, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        data['createdAt'] != null
                            ? DateFormat(
                                'hh:mm a  •  yyyy-MM-dd',
                              ).format(data['createdAt'].toDate())
                            : "",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // تحديد الأيقونة بناءً على النوع
  IconData _getIconData(String type) {
    switch (type) {
      case 'REJECTION':
        return Iconsax.close_circle;
      case 'ACCEPTANCE':
        return Iconsax.tick_circle;
      case 'OFFER':
        return Iconsax.discount_shape;
      default:
        return Iconsax.notification_status;
    }
  }

  // تحديد اللون بناءً على النوع والحالة
  Color _getIconColor(String type, bool isOpened) {
    if (isOpened) return Colors.grey;
    switch (type) {
      case 'REJECTION':
        return Colors.red;
      case 'ACCEPTANCE':
        return Colors.green;
      case 'OFFER':
        return Colors.orange;
      default:
        return TColors.primary;
    }
  }
}
