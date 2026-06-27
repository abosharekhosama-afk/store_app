import 'package:flutter/material.dart';

class TCustomPopover extends StatelessWidget {
  const TCustomPopover({
    super.key,
    required this.text,
    required this.extractedColor,
    required this.selected,
  });

  final String text;
  final Color extractedColor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🌟 تصميم جسم الحاوية الرئيسي للفقاعة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              24,
            ), // حواف دائرية ناعمة وكبيرة كالصورة
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8), // ظلال ممتدة لأسفل تعطي إحساس الطفو
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // الدائرة الملونة الكبيرة المكبرة داخل الفقاعة
              Container(
                width: 44, // حجم أكبر وأوضح
                height: 44,
                decoration: BoxDecoration(
                  color: extractedColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: extractedColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ), // إطار أبيض داخلي جمالي
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 22)
                    : null,
              ),
              const SizedBox(width: 14),

              // اسم اللون بخط واضح، عريض، ومطابق تماماً للتصميم العربي
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18, // حجم خط عريض ومريح للقراءة
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  fontFamily: 'Inter', // أو اسم الخط المعتمد في تطبيقك
                ),
              ),
            ],
          ),
        ),

        // 🌟 سهم الفقاعة المتناسق والمقوس قليلاً لأسفل
        Padding(
          padding: const EdgeInsets.only(
            right: 8.0,
          ), // إزاحة خفيفة ليتناسب مع اتجاه التصميم
          child: CustomPaint(
            size: const Size(20, 10), // أبعاد أعرض لتبدو انسيابية وليست حادة
            painter: _TrianglePainter(),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    // رسم مثلث انسيابي عريض مريح للعين
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}







/*
class TCustomPopover extends StatelessWidget {
  const TCustomPopover({
    super.key,
    required this.text,
    required this.extractedColor,
    required this.selected,
  });

  final String text;
  final Color extractedColor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // عرض مكبر للون
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: extractedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12, width: 1),
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),
              // اسم اللون الكامل والمنسق
              Text(
                text.capitalizeFirst ?? text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
        // المثلث السفلي الصغير للفقاعة (الذيل المتجه نحو الـ Chip)
        CustomPaint(
          size: const Size(12, 6),
          painter:
              _TrianglePainter(), // الآن الكود سيعرف الكلاس فوراً بدون مشاكل!
        ),
      ],
    );
  }
}

// 🌟 الكلاس المضاف المسؤل عن الرسم
class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
*/