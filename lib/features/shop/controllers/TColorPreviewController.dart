import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/chip/TCustomPopover.dart';
import 'package:untitled2_ecom/common/widgets/chip/TPixelPainter.dart';

// تأكد من استيراد ملف الـ Popover والـ Painter الجديدين هنا
// import 'package:your_app/widgets/pixel_painter.dart';
// import 'package:your_app/widgets/custom_popover.dart';

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




/*
class TColorPreviewController extends GetxController {
  OverlayEntry? _overlayEntry;

  // متغيرات تفاعلية لمراقبة حركات الأنميشن
  final RxDouble opacity = 0.0.obs;
  final RxDouble scale = 0.7.obs;

  void showPreview(
    BuildContext context,
    String text,
    Color color,
    bool selected,
  ) {
    hidePreview(); // تنظيف أي نافذة سابقة

    // حساب موقع الـ Chip لتحديد مكان الفقاعة بدقة
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Obx(
        () => AnimatedOpacity(
          opacity: opacity.value,
          duration: const Duration(milliseconds: 150),
          child: Stack(
            children: [
              // 🌆 1. طبقة البكسلات الشفافة الممتدة على كامل حجم الشاشة
              Positioned.fill(
                child: IgnorePointer(
                  // تضمن ألا تحجب الخلفية نقرات المستخدم المستقبلية
                  child: CustomPaint(painter: TPixelPainter()),
                ),
              ),

              // 🎈 2. فقاعة المعاينة المكبرة المتموضعة بدقة فوق الـ Chip
              Positioned(
                left: offset.dx - (80 - renderBox.size.width) / 2,
                top: offset.dy - 85,
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedScale(
                    scale: scale.value,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutBack,
                    child: TCustomPopover(
                      text: text,
                      extractedColor: color,
                      selected: selected,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // تشغيل الأنميشن في الـ Frame القادم بسلاسة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      opacity.value = 1.0;
      scale.value = 1.0;
    });
  }

  void hidePreview() {
    if (_overlayEntry != null) {
      opacity.value = 0.0;
      scale.value = 0.7;

      final entryToRemove = _overlayEntry;
      _overlayEntry = null;

      Future.delayed(const Duration(milliseconds: 150), () {
        entryToRemove?.remove();
      });
    }
  }

  @override
  void onClose() {
    hidePreview();
    super.onClose();
  }
}
*/



/*
class TColorPreviewController extends GetxController {
  OverlayEntry? _overlayEntry;

  // متغيرات لمراقبة الشفافية والحجم بشكل تفاعلي ناعم
  final RxDouble opacity = 0.0.obs;
  final RxDouble scale = 0.7.obs;

  /// إظهار فقاعة المعاينة فوق الـ Chip المحددة بدقة
  void showPreview(
    BuildContext context,
    String text,
    Color color,
    bool selected,
  ) {
    hidePreview(); // تنظيف أي نافذة سابقة فوراً

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // توسيط الفقاعة فوق الـ Chip
        left: offset.dx - (80 - renderBox.size.width) / 2,
        top: offset.dy - 85,
        child: Material(
          color: Colors.transparent,
          child: Obx(
            () => AnimatedScale(
              scale: scale.value,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack, // تأثير الارتداد المرن المميز
              child: AnimatedOpacity(
                opacity: opacity.value,
                duration: const Duration(milliseconds: 100),
                child: TCustomPopover(
                  text: text,
                  extractedColor: color,
                  selected: selected,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // تشغيل أنيميشن الدخول في الـ Frame القادم لضمان السلاسة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      opacity.value = 1.0;
      scale.value = 1.0;
    });
  }

  /// إخفاء الفقاعة فوراً عند رفع الإصبع
  void hidePreview() {
    if (_overlayEntry != null) {
      opacity.value = 0.0;
      scale.value = 0.7;

      // إزالة الـ Entry من الشاشة بعد انتهاء تأثير التلاشي
      final entryToRemove = _overlayEntry;
      _overlayEntry = null;

      Future.delayed(const Duration(milliseconds: 100), () {
        entryToRemove?.remove();
      });
    }
  }

  @override
  void onClose() {
    hidePreview();
    super.onClose();
  }
}
*/