import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/chip/t_custom_popover.dart';
import 'package:untitled2_ecom/common/widgets/chip/t_pixel_painter.dart';

class TColorPreviewController extends GetxController {
  OverlayEntry? _overlayEntry;

  /// دالة إظهار المعاينة (البكسلات + الفقاعة) عند النقر المطول
  void showPreview(
    BuildContext context,
    String text,
    Color extractedColor,
    bool selected,
  ) {
    // 1. التأكد من إغلاق أي نافذة معاينة سابقة أولاً لتجنب التداخل
    hidePreview();

    // 2. حساب إحداثيات وموقع الـ ChoiceChip الملموس حالياً على الشاشة
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size; // حجم الـ Chip (العرض والارتفاع)
    final position = renderBox.localToGlobal(
      Offset.zero,
    ); // موقع الـ Chip بالنسبة للشاشة

    // 3. إنشاء الـ OverlayEntry الذي سيغطي الشاشة بالكامل
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        // حساب موضع الفقاعة المريح (فوق الـ Chip مباشرة مع مراعاة المنتصف)
        // نقوم بطرح مسافة عمودية (مثلاً 75 بكسل) لترتفع الفقاعة للأعلى، ونضيف نصف عرض الـ Chip لتتوسطه
        final double calculatedTop = position.dy - 80;

        // لمنع خروج الفقاعة عن حواف الشاشة الجانبية، نستخدم الـ MediaQuery
        final screenWidth = MediaQuery.of(overlayContext).size.width;
        double calculatedLeft =
            position.dx +
            (size.width / 2) -
            65; // 65 هي تقريباً نصف عرض الفقاعة

        // حماية الأطراف الجانبية
        if (calculatedLeft < 16) calculatedLeft = 16;
        if (calculatedLeft + 130 > screenWidth)
          calculatedLeft = screenWidth - 146;

        return Material(
          color: Colors
              .transparent, // جعل الخلفية شفافة تماماً لكي لا تحجب التطبيق
          child: Stack(
            children: [
              /// 🌟 [التأثير الأول]: البكسلات الممتدة الذكية على كامل الشاشة
              Positioned.fill(
                child: IgnorePointer(
                  // IgnorePointer ضروري جداً لكي لا تحجب البكسلات نقرات المستخدم الأخرى على التطبيق
                  child: CustomPaint(painter: TPixelPainter()),
                ),
              ),

              /// 🌟 [التأثير الثاني]: عنصر الفقاعة العائمة (Popover) في موقعها الدقيق
              Positioned(
                top: calculatedTop,
                left: calculatedLeft,
                child: FractionalTranslation(
                  translation: const Offset(
                    0.0,
                    0.0,
                  ), // يمكنك ضبط الـ Offset بدقة هنا إذا لزم الأمر
                  child: TCustomPopover(
                    text: text,
                    extractedColor: extractedColor,
                    selected: selected,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // 4. حقن الـ Overlay داخل شاشة التطبيق الحالية
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// دالة إخفاء المعاينة فور رفع الإصبع أو إلغاء الضغط
  void hidePreview() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  void onClose() {
    // تنظيف الذاكرة وإغلاق الـ Overlay في حال تدمير الكنترولر
    hidePreview();
    super.onClose();
  }
}
