import 'package:flutter/material.dart';
import 'package:untitled2_ecom/enums.dart';

class TOrderTimeline extends StatelessWidget {
  final OrderStatus currentStatus;

  const TOrderTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    // تحديد ما إذا كان التطبيق في الوضع المظلم
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    // 1. تحديد الحالات الفاشلة أو الاستثنائية (التي تكسر المسار الخطي)
    final bool isCancelled = currentStatus == OrderStatus.cancelled;
    final bool isRefunded = currentStatus == OrderStatus.refunded;
    final bool isExpired = currentStatus == OrderStatus.timeExpired;
    final bool isAbnormal = isCancelled || isRefunded || isExpired;

    // 2. بناء المسار الخطي الطبيعي للطلب (بدون الحالات الاستثنائية، ودمج المقبول والتجهيز)
    // لاحظ أننا وضعنا OrderStatus.processing كممثل عن حالتي القبول والتجهيز معاً
    final List<OrderStatus> statuses = isAbnormal
        ? [
            OrderStatus.pendingPayment,
            currentStatus,
          ] // مسار الفشل البسيط (البداية ثم النهاية السيئة)
        : [
            OrderStatus.pendingPayment,
            OrderStatus.pendingPaymentApproval,
            OrderStatus.pending,
            OrderStatus.processing, // تمثل (processing و accepted)
            OrderStatus.shipped,
            OrderStatus.delivered,
          ];

    // 3. 🌟 الخريطة السحرية للوزن الرقمي (Custom Index)
    // هنا نعطي كل حالة ترتيبها المنطقي الفعلي على الخط لمنع تداخل شروط الـ index الافتراضي
    final Map<OrderStatus, int> statusWeight = {
      OrderStatus.pendingPayment: 0,
      OrderStatus.pendingPaymentApproval: 1,
      OrderStatus.pending: 2,
      OrderStatus.accepted: 3, // القبول له نفس وزن التجهيز
      OrderStatus.processing: 3, // التجهيز له نفس وزن القبول
      OrderStatus.readyForPickup: 4,
      OrderStatus.shipped: 5,
      OrderStatus.delivered: 6,
      OrderStatus.timeExpired: 7,
      OrderStatus.cancelled: 7,
      OrderStatus.refunded: 7,
    };

    // جلب الوزن الرقمي للحالة الحالية للطلب
    final int currentWeight = statusWeight[currentStatus] ?? 0;

    // تحديد لون التايملاين (أحمر للحالات السيئة، وأزرق/أساسي للمسار الطبيعي)
    final Color activeColor = isAbnormal
        ? Colors.red
        : const Color(0xFF2196F3); // يمكنك استخدام TColors.primary

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // --- الخط الخلفي الممتد (يعتمد على الوزن المخصص) ---
              Positioned(
                left: 15,
                right: 15,
                child: Row(
                  children: List.generate(statuses.length - 1, (index) {
                    final lineStatus = statuses[index];
                    final int lineWeight = statusWeight[lineStatus] ?? 0;

                    // الخط يضيء إذا كان وزن الحالة الحالية أكبر من وزن هذا الخط
                    final bool lineCompleted =
                        !isAbnormal && (currentWeight > lineWeight);

                    return Expanded(
                      child: Container(
                        height: 3,
                        color: lineCompleted
                            ? activeColor
                            : (dark ? Colors.grey[700] : Colors.grey[300]),
                      ),
                    );
                  }),
                ),
              ),

              // --- الدوائر العائمة (تعتمد على الوزن المخصص) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(statuses.length, (index) {
                  final nodeStatus = statuses[index];
                  final int nodeWeight = statusWeight[nodeStatus] ?? 0;

                  // النقطة الحالية المشعّة
                  // إذا كانت الحالة الحالية المقبولة accepted والنقطة الحالية المعروضة هي processing، نعتبرها الحالية!
                  final bool isCurrent =
                      nodeStatus == currentStatus ||
                      (nodeStatus == OrderStatus.processing &&
                          currentStatus == OrderStatus.accepted);

                  // النقطة مكتملة إذا كان وزن الطلب الحالي تخطاها
                  final bool isCompleted =
                      !isAbnormal && (currentWeight > nodeWeight);

                  return Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? activeColor
                          : (dark ? Colors.grey[800] : Colors.grey[200]),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: activeColor.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : (isCurrent
                              ? Center(
                                  child: Icon(
                                    isAbnormal ? Icons.close : Icons.circle,
                                    color: Colors.white,
                                    size: isAbnormal ? 16 : 10,
                                  ),
                                )
                              : null),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // --- طبقة النصوص الموزعة بالتساوي تحت الخطوط ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(statuses.length, (index) {
              final nodeStatus = statuses[index];

              // التحقق من تفعيل النص بناءً على الحالة الفعلية المدمجة
              final bool isCurrent =
                  nodeStatus == currentStatus ||
                  (nodeStatus == OrderStatus.processing &&
                      currentStatus == OrderStatus.accepted);

              return Expanded(
                child: Text(
                  // إذا كانت الحالة accepted، ستعرض دالة الأسماء "قيد التجهيز" تلقائياً لأن النقطة مدمجة
                  _getStatusName(
                    currentStatus == OrderStatus.accepted &&
                            nodeStatus == OrderStatus.processing
                        ? OrderStatus.processing
                        : nodeStatus,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? activeColor : Colors.grey,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // دالة تحويل الـ Enum إلى نص عربي منسق ومطابق لمتطلباتك
  String _getStatusName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingPayment:
        return "بانتظار الدفع";
      case OrderStatus.pendingPaymentApproval:
        return "مراجعة الدفع";
      case OrderStatus.timeExpired:
        return "انتهى الوقت";
      case OrderStatus.pending:
        return "قيد الانتظار";
      case OrderStatus.processing:
      case OrderStatus.accepted:
        return "قيد التجهيز"; // كلاهما يعطي نفس النص على الواجهة
      case OrderStatus.shipped:
        return "في الطريق";
      case OrderStatus.delivered:
        return "تم التسليم";
      case OrderStatus.cancelled:
        return "ملغي";
      case OrderStatus.refunded:
        return "مرجع";
      case OrderStatus.readyForPickup:
        return "جاهز للجمع";
    }
  }
}
