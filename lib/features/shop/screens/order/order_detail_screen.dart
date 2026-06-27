import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/common/widgets/contaniners/rounded_container.dart';
import 'package:untitled2_ecom/common/widgets/images/rounded_image.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/enums.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/order_controller_new.dart';
import 'package:untitled2_ecom/features/shop/models/cart_item_model.dart';
import 'package:untitled2_ecom/features/shop/models/order_model.dart';
import 'package:untitled2_ecom/features/shop/screens/order/order_time_line.dart';
import 'package:untitled2_ecom/features/shop/screens/order/widget/TOrderActionBottomSheet.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';
import 'package:untitled2_ecom/utils/popups/exports.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = OrderController.instance;
    return Scaffold(
      appBar: TAppbar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الطلب',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text('#${order.id}', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        showBlur: true,
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- 1. قسم تتبع الطلب (التصميم الحديث) ---
              TRoundedContainer(
                showBorder: false,
                padding: const EdgeInsets.all(TSizes.md),
                backgroundColor: dark ? TColors.darkerGrey : TColors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "حالة الطلب الآن",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          order.orderStatusText,
                          style: TextStyle(
                            color: TColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    TOrderTimeline(currentStatus: order.actualStatus),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// --- 2. تفاصيل المنتجات (Order Items) ---
              Row(
                children: [
                  const Icon(Iconsax.bag_2, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "المنتجات المطلوبة",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text(
                    "${order.items.length} قطع",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: TSizes.spaceBtwItems),
                itemBuilder: (_, index) {
                  final item = order.items[index];
                  final bool isDark = THelperFunctions.isDarkMode(context);

                  // 1. فحص الحالات محلياً لتحديد هل يحق للمستخدم الضغط على الزر؟
                  // تظهر الأيقونة فقط إذا كانت الحالة تسمح بالإلغاء الفوري أو طلب مراجعة الأدمن
                  final bool canCancelOrReturn =
                      item.itemStatus == ItemStatus.pending ||
                      item.itemStatus == ItemStatus.accepted ||
                      item.itemStatus == ItemStatus.shipped ||
                      item.itemStatus == ItemStatus.delivered;

                  return Container(
                    padding: const EdgeInsets.all(TSizes.sm),
                    decoration: BoxDecoration(
                      color: isDark ? TColors.darkerGrey : TColors.white,
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // 1. صورة المنتج مع خلفية ناعمة
                        TRoundedImage(
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          imageUrl: item.image ?? "",
                          isNetworkImage: true,
                          borderRadius: TSizes.md,
                          backgroundColor: isDark
                              ? TColors.dark
                              : TColors.light,
                          padding: const EdgeInsets.all(TSizes.sm),
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems),

                        // 2. تفاصيل المنتج
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatusChip(item.itemStatus),
                              const SizedBox(height: 5),
                              Text(
                                item.title,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "الكمية: ${item.quantity}",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),

                        // 3. السعر (بخط عريض ولون مميز)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TSizes.sm,
                          ),
                          child: Text(
                            "\$${item.price}",
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: TColors.primary,
                                ),
                          ),
                        ),

                        // 4. [القسم الجديد الإحترافي]: زر إلغاء / إرجاع العنصر الفردي
                        if (canCancelOrReturn)
                          IconButton(
                            onPressed: () => _onCancelOrReturnItemPressed(
                              context,
                              controller,
                              order,
                              item,
                            ),
                            icon: Icon(
                              // تغيير شكل الأيقونة ديناميكياً لتوحي بالإرجاع بعد الاستلام أو الإلغاء قبله
                              (item.itemStatus == ItemStatus.shipped ||
                                      item.itemStatus == ItemStatus.delivered)
                                  ? Icons.assignment_return_outlined
                                  : Icons.cancel_presentation_outlined,
                              color: Colors.redAccent,
                              size: 24,
                            ),
                            tooltip:
                                (item.itemStatus == ItemStatus.shipped ||
                                    item.itemStatus == ItemStatus.delivered)
                                ? "طلب إرجاع المنتج"
                                : "إلغاء هذا المنتج",
                          )
                        else if (item.itemStatus ==
                                ItemStatus.cancellationRequested ||
                            item.itemStatus == ItemStatus.returnRequested)
                          // إذا كان الطلب معلقاً عند الأدمن بالفعل، نظهر ساعة رملية صغيرة ولا نترك الزر قابلاً للضغط
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },

                /*
                itemBuilder: (_, index) {
                  final item = order.items[index];
                  final bool isDark = THelperFunctions.isDarkMode(context);

                  return Container(
                    padding: const EdgeInsets.all(TSizes.sm),
                    decoration: BoxDecoration(
                      color: isDark ? TColors.darkerGrey : TColors.white,
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                      // إضافة ظل ناعم وبدون حدود (No Border)
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // 1. صورة المنتج مع خلفية ناعمة
                        TRoundedImage(
                          fit: BoxFit.cover,
                          width: 80, // زيادة الحجم قليلاً للتصميم الحديث
                          height: 80,
                          imageUrl: item.image ?? "",
                          isNetworkImage: true,
                          borderRadius: TSizes.md,
                          backgroundColor: isDark
                              ? TColors.dark
                              : TColors.light,
                          padding: const EdgeInsets.all(TSizes.sm),
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems),

                        // 2. تفاصيل المنتج
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // حالة المنتج (Widget لتمييز الحالة)
                              _buildStatusChip(item.itemStatus),
                              const SizedBox(height: 5),

                              Text(
                                item.title,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),

                              Text(
                                "الكمية: ${item.quantity}",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),

                        // 3. السعر (بخط عريض ولون مميز)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TSizes.sm,
                          ),
                          child: Text(
                            "\$${item.price}",
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: TColors.primary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              */
              ),

              /*
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: TSizes.spaceBtwItems),
                itemBuilder: (_, index) {
                  final item = order.items[index];
                  return Row(
                    children: [
                      TRoundedImage(
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70,
                        imageUrl: item.image ?? "",
                        isNetworkImage: true,
                        borderRadius: TSizes.md,
                        backgroundColor: dark
                            ? TColors.darkerGrey
                            : TColors.light,
                        padding: const EdgeInsets.all(TSizes.sm),
                      ),
                      const SizedBox(width: TSizes.spaceBtwItems),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "الكمية: ${item.quantity}",
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "\$${item.price}",
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                },
              ),
              */
              const SizedBox(height: TSizes.spaceBtwSections),

              /// --- 3. ملخص الحساب وعنوان الشحن ---
              TRoundedContainer(
                showBorder: false,
                padding: const EdgeInsets.all(TSizes.md),

                backgroundColor: TColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row("المجموع الجزئي", "\$${order.itemsAmount}"),
                    _row(
                      "إجمالي رسوم الشحن والتجميع",
                      "\$${order.shippingAmount}",
                    ),
                    const Divider(),
                    _row(
                      "الإجمالي النهائي",
                      "\$${order.totalAmount}",
                      isBold: true,
                    ),
                    const Divider(),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    sectionHeading(
                      labelText: "عنوان التوصيل الرئيسي",
                      showButtton: false,
                      padding: EdgeInsets.zero,
                    ),
                    Text(
                      order.address?.fullAddress ?? "لا يوجد عنوان محدد",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems / 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_city,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: TSizes.sm),
                        Text(
                          "${order.address?.address ?? "لا يوجد عنوان محدد"}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              /// --- 4. زر الدعم أو المساعدة ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // استدعاء البوتم شيت وتمرير الكونتكست والكونترولر والموديل الحالي للطلب
                    TOrderActionBottomSheet.show(context, order);
                  },
                  child: const Text("إدارة أو خيارات الطلب"),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }

  // تابع مساعد لبناء "Status Chip" احترافي
  Widget _buildStatusChip(ItemStatus status) {
    Color color;
    String text;
    IconData icon;

    // تنسيق الحالات بناءً على المعايير الحديثة لتجربة المستخدم
    switch (status) {
      case ItemStatus.pending:
        color = Colors.orange;
        text = "قيد الانتظار";
        icon = Iconsax.clock; // أيقونة الساعة للانتظار
        break;

      case ItemStatus.accepted:
        color = Colors.purple;
        text = "تم قبوله";
        icon = Iconsax.like_1; // أيقونة الإعجاب أو الموافقة
        break;

      case ItemStatus.readyForPickup:
        color = Colors.blue;
        text = "جاهز للشحن";
        icon = Iconsax.box; // أيقونة الصندوق للتجهيز
        break;

      case ItemStatus.shipped:
        color = Colors.indigo;
        text = "تم شحنه";
        icon = Iconsax.truck_fast; // أيقونة الشاحنة السريعة
        break;

      case ItemStatus.delivered:
        color = Colors.green;
        text = "تم توصيله";
        icon = Iconsax.verify; // أيقونة التحقق للتسليم النهائي
        break;

      case ItemStatus.cancelled:
        color = Colors.blueGrey; // لون محايد للإلغاء
        text = "تم إلغاؤه";
        icon = Iconsax.close_circle;
        break;

      case ItemStatus.rejected:
        color = Colors.red;
        text = "مرفوض / مرجع";
        icon = Iconsax.danger; // أيقونة التنبيه للرفض
        break;

      default:
        color = Colors.grey;
        text = "غير معروف";
        icon = Iconsax.info_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), // زيادة الشفافية قليلاً لبروز اللون
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ), // تكبير الأيقونة قليلاً لتناسب الخط
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700, // خط عريض قليلاً لسهولة القراءة
            ),
          ),
        ],
      ),
    );
  }
}

Widget _row(String title, String value, {bool isBold = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ],
  );
}

void _onCancelOrReturnItemPressed(
  BuildContext context,
  OrderController controller,
  OrderModel order,
  CartItemModel item,
) {
  // 1. فحص الحماية الأولية: التحقق من حالات المنع التام
  if (item.itemStatus == ItemStatus.cancelled ||
      item.itemStatus == ItemStatus.returned) {
    TLoaders.errorSnackBar(
      title: "عملية غير صالحة",
      message: "هذا المنتج تمت معالجته مسبقاً وإغلاق ملفه المالي.",
    );
    return;
  }

  if (item.itemStatus == ItemStatus.cancellationRequested ||
      item.itemStatus == ItemStatus.returnRequested) {
    TLoaders.errorSnackBar(
      title: "طلب معلق",
      message: "هذا المنتج قيد المراجعة حالياً من قبل إدارة المنصة.",
    );
    return;
  }

  // 2. صياغة نص التنبيه بناءً على المسار اللوجستي للمنتج
  String dialogTitle = "إلغاء عنصر من الطلب";
  String dialogContent =
      "هل أنت متأكد من رغبتك في إلغاء المنتج [${item.title}]؟";

  if (item.itemStatus == ItemStatus.pending) {
    dialogContent +=
        "\nسيتم رد قيمته (\$${item.price * item.quantity}) لمحفظتك فوراً كونه لم يدخل مرحلة التجهيز بعد.";
  } else if (item.itemStatus == ItemStatus.accepted ||
      item.itemStatus == ItemStatus.readyForPickup) {
    dialogContent =
        "هذا المنتج قيد التحضير في المتجر. سيتم إرسال طلب إلغاء للمسؤول للموافقة عليه.";
  } else if (item.itemStatus == ItemStatus.shipped ||
      item.itemStatus == ItemStatus.delivered) {
    dialogTitle = "طلب إرجاع منتج";
    dialogContent =
        "هل أنت متأكد من تقديم طلب إرجاع للمنتج المستلم [${item.title}]؟ سيقوم المسؤول بمراجعة الطلب ومطابقته للشروط.";
  }

  // 3. إظهار دايالوج تأكيد احترافي وجذاب للمستخدم لمنع الضغط بالخطأ
  Get.dialog(
    AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          const SizedBox(width: 8),
          Text(
            dialogTitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(dialogContent, style: const TextStyle(fontSize: 14)),
      actions: [
        TextButton(
          onPressed: () => Get.back(), // إغلاق الدايالوج وإلغاء العملية
          child: const Text("تراجع", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back(); // إغلاق الدايالوج أولاً

            // استدعاء دالة فلوتر التي قمنا بتحديثها في الخطوة السابقة لتضرب السيرفر
            controller.handleCancelSpecificItemsLogic(
              context: context,
              orderModel: order,
              itemsToCancel: [
                {
                  "productId": item.productId,
                  "variationId":
                      item.variationId, // سيتم إلغاء هذا الفاريشن فقط!
                },
              ], // تمرير الـ ID الخاص بهذا المنتج كقائمة مفرَدة
            );
          },
          child: const Text("تأكيد الأمر"),
        ),
      ],
    ),
    barrierDismissible: false, // إجبار المستخدم على اختيار أحد الزرين
  );
}







  /*Widget _buildStatusChip(ItemStatus status) {
    Color color;
    String text;
    IconData icon;

    // تحديد الخصائص بناءً على الحالة
    switch (status) {
      case ItemStatus.shipped:
        color = Colors.green;
        text = "تم شحنه";
        icon = Iconsax.tick_circle;
        break;
      case ItemStatus.pending:
        color = Colors.orange;
        text = "قيد الانتظار";
        icon = Iconsax.timer_1;
        break;
      case ItemStatus.accepted:
        color = Colors.purpleAccent;
        text = "تم قبوله";
        icon = Iconsax.timer_1;
        break;
      case ItemStatus.readyForPickup:
        color = Colors.lightBlue;
        text = "جاهز للشحن";
        icon = Iconsax.timer_1;
        break;
      case ItemStatus.delivered:
        color = Colors.teal;
        text = "تم توصيله";
        icon = Iconsax.timer_1;
        break;
      case ItemStatus.cancelled:
        color = Colors.teal;
        text = "تم رفضه";
        icon = Iconsax.timer_1;
        break;
      case ItemStatus.rejected:
        color = Colors.red;
        text = "مرجع";
        icon = Iconsax.close_circle;
        break;
      default:
        color = Colors.grey;
        text = "غير معروف";
        icon = Iconsax.info_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // خلفية شفافة جداً من نفس لون النص ليعطي مظهر الـ Modern Chip
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100), // حواف دائرية بالكامل
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color), // أيقونة صغيرة بجانب النص
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}*/








/*
class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TAppbar(
        title: Text(
          'Order Details #${order.id}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              TRoundedContainer(
                backgroundColor: dark ? TColors.darkerGrey : TColors.light,
                showBorder: true,
                padding: const EdgeInsets.all(TSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "تتبع الطلب",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TOrderTimeline(
                      currentStatus: order.status,
                    ), // تمرير حالة الطلب من الموديل
                  ],
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // 1. حالة الطلب الأساسية (Status & Date)
              TRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(TSizes.md),
                backgroundColor: dark ? TColors.dark : TColors.light,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.status),
                        const SizedBox(width: TSizes.spaceBtwItems),
                        Text(
                          "Status: ",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          order.orderStatusText,
                          style: TextStyle(
                            color: TColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Iconsax.calendar),
                        const SizedBox(width: TSizes.spaceBtwItems),
                        Text(
                          "Date: ",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(order.formattedOrderDate),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // 2. قائمة العناصر (Items List)
              Text(
                "Order Items",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: TSizes.spaceBtwItems),
                itemBuilder: (_, index) {
                  final item = order.items[index];
                  return TRoundedContainer(
                    backgroundColor: dark ? TColors.darkerGrey : TColors.light,
                    showBorder: true,
                    padding: const EdgeInsets.all(TSizes.sm),
                    child: Row(
                      children: [
                        // صورة المنتج
                        TRoundedImage(
                          width: 60,
                          height: 60,
                          imageUrl: item.image ?? "",
                          isNetworkImage: true,
                          backgroundColor: dark
                              ? TColors.darkerGrey
                              : TColors.light,
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems),

                        // تفاصيل العنصر
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                "Qty: ${item.quantity}",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              // حالة العنصر (إذا كانت موجودة في الموديل الخاص بك)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: TColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item
                                      .itemStatus
                                      .name, // أو item.status إذا كان متاحاً
                                  style: const TextStyle(
                                    color: TColors.primary,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // السعر
                        Text(
                          "\$${item.price}",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // 3. ملخص الحساب (Billing Info)
              // ويدجيت جاهزة لديك غالباً
              const SizedBox(height: TSizes.spaceBtwItems),

              // 4. عنوان الشحن (Shipping Address)
              // TBillingAddressSection(address: order.address),
            ],
          ),
        ),
      ),
    );
  }
}
*/