import 'dart:math';
import 'package:flutter/material.dart';

class TBarPixelPainter extends CustomPainter {
  final bool isDark;
  TBarPixelPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(
      123,
    ); // Seed ثابت للحفاظ على نمط توزيع البكسلات المميز
    final paint = Paint()..style = PaintingStyle.fill;

    const double pixelSize = 6.0; // حجم بكسل صغير متناسق مع حجم شريط التنقل

    for (double i = 0; i < size.width; i += pixelSize) {
      for (double j = 0; j < size.height; j += pixelSize) {
        // نسبة ظهور البكسلات (رسم بكسل عشوائي في 15% من مساحة البار لخلق تأثير متلاشي غير مزعج للعين)
        if (random.nextDouble() > 0.85) {
          // حساب الشفافية ديناميكياً لتدرج ناعم جداً
          double opacity = 0.02 + random.nextDouble() * 0.09;

          if (isDark) {
            // تدرجات الوضع الداكن: خلط بين بكسلات رمادية مائلة للأزرق وبكسلات بيضاء شفافة
            paint.color = random.nextBool()
                ? Colors.blueGrey.withOpacity(opacity)
                : Colors.white.withOpacity(opacity * 0.8);
          } else {
            // تدرجات الوضع الفاتح: خلط بين بكسلات رمادية داكنة وبكسلات بيضاء ناصعة
            paint.color = random.nextBool()
                ? Colors.grey.withOpacity(opacity * 1.2)
                : Colors.white.withOpacity(opacity * 2.0);
          }

          // رسم البكسل مع ترك فجوة ميكرومترية (0.5 بكسل) للحصول على تأثير الشبكة الفاخرة
          canvas.drawRect(
            Rect.fromLTWH(i, j, pixelSize - 0.5, pixelSize - 0.5),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
