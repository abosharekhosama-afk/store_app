import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/common/widgets/contaniners/rounded_container.dart';
import 'package:untitled2_ecom/common/widgets/images/rounded_image.dart';
import 'package:untitled2_ecom/common/widgets/loaders/animation_loader.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/TOrderShimmer.dart';
import 'package:untitled2_ecom/enums.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/order_controller_new.dart';
import 'package:untitled2_ecom/features/shop/screens/order/order_detail_screen.dart';
import 'package:untitled2_ecom/navigation_menu.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';
import 'package:flutter/services.dart'; // ضروري لعملية النسخ

class OrdersList extends StatelessWidget {
  const OrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(OrderController());

    return Scaffold(
      // إضافة خاصية السحب للتحديث لحل مشكلة المزامنة
      // backgroundColor: const Color(0xFFF8F9FB), // لون خلفية هادئ وعصري
      body: RefreshIndicator(
        onRefresh: () async => controller.fetchUserOrders(),
        child: Obx(() {
          // التحقق من حالة الاتصال
          // بدلاً من مؤشر التحميل التقليدي
          if (controller.isLoading.value && controller.userOrders.isEmpty) {
            return const TOrderShimmer();
          }

          // 2. حالة القائمة فارغة (نقوم بعمل return مباشر للودجيت دون تخزينها في متغير خارجي)
          if (controller.userOrders.isEmpty) {
            return TAnimationLoaderWidget(
              text: "أوه! لا توجد طلبات بعد!",
              animation: TImages.cartAnimation,
              showAction: true,
              actionText: "لنملأ السلة الآن",
              onActionPressed: () => Get.off(() => const NavigationMenu()),
            );
          }

          final orders = controller.userOrders;

          return ListView.separated(
            controller: controller
                .scrollController, // 🌟 ربط ميكانيكية التمرير اللانهائي هنا
            separatorBuilder: (_, __) =>
                const SizedBox(height: TSizes.spaceBtwItems),
            itemCount: orders.length + (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              // إذا وصلنا للمؤشر الأخير وكان التطبيق يجلب بيانات إضافية، اعرض الـ Loader السفلي
              if (index == orders.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: TSizes.spaceBtwSections,
                  ),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final order = orders[index];
              final statusColor = _getStatusColor(order.status);

              return TRoundedContainer(
                showBorder: false,
                padding: const EdgeInsets.all(TSizes.md),
                backgroundColor: dark ? TColors.darkerGrey : TColors.white,
                child: Column(
                  children: [
                    /// 1. الرأس (الحالة والتاريخ)
                    GestureDetector(
                      onTap: () =>
                          Get.to(() => OrderDetailScreen(order: order)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Iconsax.box,
                              color: statusColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.orderStatusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  order.formattedOrderDate,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Iconsax.arrow_left, size: 18),
                            onPressed: () =>
                                Get.to(() => OrderDetailScreen(order: order)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

                    /// 2. المعرف وكود التسليم مع أزرار النسخ
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoWithCopy(
                            context,
                            label: "رقم الطلب",
                            value: "#${order.id}",
                            fullValue: order.id,
                            icon: Iconsax.tag,
                            color: TColors.primary,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoWithCopy(
                            context,
                            label: "كود الاستلام",
                            value: order.deliveryCode,
                            fullValue: order.deliveryCode,
                            icon: Iconsax.key,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// 3. شريط الصور (هذا هو الجزء الذي سألت عنه)
                    if (order.items.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // عرض صور المنتجات (بحد أقصى 4 صور)
                          SizedBox(
                            height: 45,
                            child: Row(
                              children: [
                                for (
                                  int i = 0;
                                  i <
                                      (order.items.length > 4
                                          ? 4
                                          : order.items.length);
                                  i++
                                )
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: TColors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                    child: TRoundedImage(
                                      borderRadius: 8,
                                      width: 45,
                                      height: 45,
                                      imageUrl: order.items[i].image ?? "",
                                      isNetworkImage: true,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                if (order.items.length > 4) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    "+${order.items.length - 4}",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // السعر الإجمالي بجانب الصور
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "إجمالي المبلغ",
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Text(
                                "\$${order.totalAmount}",
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  /// ودجت مخصص لعرض المعلومات مع زر النسخ
  Widget _buildInfoWithCopy(
    BuildContext context, {
    required String label,
    required String value,
    required String fullValue,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(value, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(width: 4),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: fullValue));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("تم نسخ $label بنجاح"),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Icon(Iconsax.copy, size: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return TColors.primary;
    }
  }
}




/*
class OrdersList extends StatelessWidget {
  const OrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(OrderController());
    return FutureBuilder(
      future: controller.fetchUserOrder(),
      builder: (context, asyncSnapshot) {
        final emptyWidget = TAnimationLoaderWidget(
          text: "Woops! No Orders Yet!",
          animation: TImages.cartAnimation,
          showAction: true,
          actionText: "Let\s fill it.",
          onActionPressed: () => Get.off(() => NavigationMenu()),
        );

        final respon = TCloudHelperFunctions.checkMultiRecordState(
          snapshot: asyncSnapshot,
          nothingFound: emptyWidget,
        );
        if (respon != null) return respon;

        final orders = asyncSnapshot.data!;
        return ListView.separated(
          separatorBuilder: (context, index) =>
              SizedBox(height: TSizes.spaceBtwItems),
          shrinkWrap: true,
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return InkWell(
              onTap: () => Get.to(() => OrderDetailScreen(order: order)),
              child: TRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(TSizes.md),
                backgroundColor: dark ? TColors.dark : TColors.white,
                child: Column(
                  children: [
                    // السطر الأول: الحالة والتاريخ
                    Row(
                      children: [
                        Icon(
                          Iconsax.box,
                          color: _getStatusColor(order.status),
                        ), // أيقونة متغيرة اللون
                        const SizedBox(width: TSizes.spaceBtwItems / 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.orderStatusText,
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .apply(
                                      color: _getStatusColor(order.status),
                                      fontWeightDelta: 2,
                                    ),
                              ),
                              Text(
                                order.formattedOrderDate,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Iconsax.arrow_right_3, size: 18),
                      ],
                    ),

                    const SizedBox(height: TSizes.spaceBtwItems),

                    // السطر الثاني: صور مصغرة للمنتجات (اختياري لكنه احترافي جداً)
                    if (order.items.isNotEmpty)
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: order.items.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: TRoundedImage(
                              fit: BoxFit.cover,
                              imageUrl: order.items[i].image ?? "",
                              isNetworkImage: true,
                              width: 40,
                              height: 40,
                              applyImageRadius: true,
                            ),
                          ),
                        ),
                      ),

                    const Divider(),

                    // السطر الثالث: رقم الطلب والمبلغ الإجمالي
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ID: #${order.id}",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          "\$${order.totalAmount}",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),

                    // رمز الاستلام بتصميم مميز
                    if (order.status == OrderStatus.shipped)
                      Container(
                        margin: const EdgeInsets.only(
                          top: TSizes.spaceBtwItems,
                        ),
                        padding: const EdgeInsets.all(TSizes.sm),
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: TColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.password_check,
                              size: 20,
                              color: TColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "رمز الاستلام: ${order.deliveryCode}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },

          /*
          itemBuilder: (context, index) {
            final order = orders[index];
            return InkWell(
              onTap: () => Get.to(
                () => OrderDetailScreen(order: order),
              ), // الانتقال وتمرير الطلب
              child: TRoundedContainer(
                showBorder: true,
                borderColor: TColors.grey,
                backgroundColor: dark ? TColors.dark : TColors.light,
                padding: EdgeInsets.all(TSizes.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.ship),
                        const SizedBox(width: TSizes.spaceBtwItems / 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.orderStatusText,
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .apply(
                                      color: TColors.primary,
                                      fontWeightDelta: 1,
                                    ),
                              ),
                              Text(
                                order.formattedOrderDate,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                        Icon(Iconsax.arrow_right_34, size: TSizes.iconSm),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Iconsax.tag),
                              const SizedBox(width: TSizes.spaceBtwItems / 2),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
                                    ),
                                    Text(
                                      order.id,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Iconsax.calendar),
                              const SizedBox(width: TSizes.spaceBtwItems / 2),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Shipping Date",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
                                    ),
                                    /*Text(
                                      order.formattedDeilveryDate,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),*/
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (order.status == OrderStatus.shipped)
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          color: Colors.blue.withOpacity(0.1),
                          child: Text(
                            "رمز الاستلام: ${order.deliveryCode}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        */
        );
      },
    );
  }

  // دالة مساعدة للألوان
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return TColors.primary;
    }
  }
}
*/