import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/enums.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/order_controller_new.dart';
import 'package:untitled2_ecom/features/shop/models/order_model.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/popups/loaders.dart';

class TOrderActionBottomSheet {
  static void show(BuildContext context, OrderModel orderModel) {
    final bool isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final orderController = OrderController.instance;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors
          .transparent, // لجعل الحواف زجاجية أو دائرية بدون خلفية بيضاء مزعجة
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? TColors.dark : TColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: TColors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: 15,
            left: 20,
            right: 20,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                30, // لدعم لوحة المفاتيح إن ظهرت
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // خط سحب الـ Bottom Sheet العلوي المودرن
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: TColors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),

              Text(
                "خيارات وإدارة الطلب",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: isDark ? TColors.textWhite : TColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // الخيار الأول: تقديم طلب لرفض/إلغاء الطلب
              _buildOptionTile(
                context,
                icon: Icons.cancel_schedule_send_outlined,
                title: "تقديم طلب لإلغاء الطلب",
                subtitle: "إلغاء الطلب قبل عملية الشحن والتجهيز",
                onTap: () {
                  // 1. نستخدم مسار الإغلاق الآمن التابع لـ GetX لإنهاء البوتم شيت أولاً
                  Get.back();

                  // 2. استدعاء الميثود المحدثة مباشرة
                  orderController.handleCancelOrderLogic(context, orderModel);
                },
              ),
              const SizedBox(height: 12),

              // الخيار الثاني: هل لم تستلم الطلب بعد؟
              _buildOptionTile(
                context,
                icon: Icons
                    .local_shipping_outlined, // أو استخدام أيقونة تتبع Icons.local_shipping_outlined
                title: "هل لم تستلم الطلب بعد؟",
                subtitle: "التحقق من حالة وصول شحنتك ومراجعتها",
                onTap: () {
                  Get.back();
                  _handleNotReceivedLogic(context, orderModel);
                },
              ),
              const SizedBox(height: 12),

              // الخيار الثالث: لم يتم تفعيل الطلب بالرغم من الدفع
              _buildOptionTile(
                context,
                icon: Icons.account_balance_wallet_outlined,
                title: "لم يتم تفعيل الطلب بالرغم من الدفع",
                subtitle: "رفع إثبات الدفع لتفعيل طلبك يدوياً",
                onTap: () {
                  Get.back();
                  _showPaymentUploadDialog(
                    context,
                    orderController,
                    orderModel,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ويدجت مخصصة لبناء الخيارات بأسلوب بطاقات مودرن (Modern Cards)
  static Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final bool isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? TColors.darkContainer : TColors.lightGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? TColors.borderDark : TColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: TColors.primary, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? TColors.textWhite : TColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: TColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: TColors.grey),
          ],
        ),
      ),
    );
  }

  // 1. منطق فحص حالة جميع المنتجات لرفض/إلغاء الطلب
  static void _handleCancelOrderLogic(
    BuildContext context,
    OrderModel orderModel,
  ) {
    // افترضنا هنا أن orderModel يحتوي على قائمة المنتجات وبها حقل الحالة status
    // نتحقق إذا كانت جميع المنتجات قد تغيرت حالتها من "بانتظار المراجعة" (مثلاً تم قبولها أو شحنها)
    bool isAnyProductProcessed = orderModel.items.any(
      (item) =>
          item.itemStatus != ItemStatus.pending &&
          item.itemStatus != ItemStatus.rejected,
    );

    if (isAnyProductProcessed) {
      // إذا تم معالجة وقبول المنتجات ولم تعد بانتظار المراجعة يظهر سناك بار احترافي
      TLoaders.errorSnackBar(
        title: "عذراً، لا يمكن الإلغاء",
        message:
            "لا يمكن إلغاء الطلب في هذه المرحلة بسبب أن الطلب تم شحنه وتجهيزه بالفعل.",
      );
    } else {
      // هنا تكتب كود المتابعة في عملية الإلغاء الطبيعية
      TLoaders.successSnackBar(
        title: "تم استلام الطلب",
        message: "جاري تقديم طلب إلغاء الطلب للإدارة.",
      );
    }
  }

  // 2. منطق فحص حالة استلام الطلب
  static void _handleNotReceivedLogic(
    BuildContext context,
    OrderModel orderModel,
  ) {
    // إذا كانت حالة الطلب لم تُشحن أو ما زالت بالطريق
    if (orderModel.status != OrderStatus.delivered) {
      TLoaders.warningSnackBar(
        title: "حالة الشحنة",
        message: "الطلب ما زال في مرحلة التجهيز أو الشحن وسيصلك قريباً.",
      );
    }
    // إذا كانت الحالة في السيستم مسجلة "تم التسليم" ولكن المستخدم لم يستلم
    else if (orderModel.status == OrderStatus.delivered) {
      _showCustomActionDialog(
        context,
        title: "تقديم طلب مراجعة",
        content:
            "النظام يشير إلى أنه تم تسليم الطلب بنجاح. هل ترغب في تقديم طلب مراجعة رسمي للإدارة لتأكيد عدم الاستلام؟",
        confirmLabel: "تقديم الطلب",
        onConfirm: () {
          Get.back();
          // هنا يتم استدعاء الأكشن لتسجيل الطلب في قاعدة البيانات (Supabase/Firebase)
          TLoaders.successSnackBar(
            title: "تم بنجاح",
            message: "تم تسجيل طلب المراجعة، سنتواصل معك قريباً.",
          );
        },
      );
    }
  }

  // 3. ديلوج رفع إثبات الدفع عند تفعيل الطلب يدوياً
  static void _showPaymentUploadDialog(
    BuildContext context,
    OrderController orderController,
    OrderModel orderModel,
  ) {
    final bool isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    _showCustomActionDialog(
      context,
      title: "تفعيل الطلب يدوياً",
      content:
          "الرجاء رفع صورة واضحة لإشعار أو إيصال إثبات الدفع البنكي لكي يتم تفعيل طلبك يدوياً من قبل الإدارة بعد المراجعة.",
      confirmLabel: "رفع الإيصال",
      onConfirm: () async {
        Get.back();
        // هنا تستدعي ميثود اختيار الصورة من الـ controller الخاص بك (Image Picker)
        await orderController.uploadPaymentReceipt(
          context,
          orderModel.id,
          orderModel.userId,
        );
        Get.snackbar(
          "جاري الرفع",
          "يتم الآن رفع الإشعار وتسجيل طلب المراجعة.",
          backgroundColor: TColors.primary,
          colorText: Colors.white,
        );
      },
    );
  }

  // ديلوج أساسي عصري وموحد (Reusable Dialog) لمنع تكرار الكود
  static void _showCustomActionDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    final bool isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? TColors.dark : TColors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? TColors.textWhite : TColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: TColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: TColors.borderSecondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        "إلغاء",
                        style: TextStyle(color: TColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onConfirm,
                      child: Text(
                        confirmLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
