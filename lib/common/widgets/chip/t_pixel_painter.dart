import 'package:flutter/material.dart';
import 'dart:math'; // استيراد مكتبة الرياضيات لتوليد تدرجات بكسل عشوائية ناعمة
import 'dart:ui' as ui;

/*
class TPixelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(123); // Seed ثابت للحفاظ على نفس نمط التوزيع
    final paint = Paint()..style = PaintingStyle.fill;

    // حجم البكسل المتناسق مع أبعاد الشاشة
    const double pixelSize = 10.0;

    // نقطة تمركز الكثافة البكسلية (قريبة من مكان ظهور الفقاعة والـ Chips)
    final double centerX = size.width * 0.35;
    final double centerY = size.height * 0.5;
    final double maxDistance = sqrt(centerX * centerX + centerY * centerY);

    for (double i = 0; i < size.width; i += pixelSize) {
      for (double j = 0; j < size.height; j += pixelSize) {
        // حساب مسافة البكسل الحالي عن مركز الكثافة
        double dx = i - centerX;
        double dy = j - centerY;
        double distance = sqrt(dx * dx + dy * dy);
        double proximityToCenter =
            1.0 - (distance / maxDistance).clamp(0.0, 1.0);

        // 🌟 معادلة الكثافة: تم زيادة القيم لتكون البكسلات أكثر تلاحماً وكثافة
        double spawnChance = 0.50 + (proximityToCenter * 0.49);

        if (random.nextDouble() < spawnChance) {
          // الشفافية تتأثر أيضاً بالقرب من المركز لتعطي عمقاً بصرياً
          double baseOpacity = 0.05 + (proximityToCenter * 0.12);
          double finalOpacity =
              (baseOpacity * (0.6 + random.nextDouble() * 0.4)).clamp(
                0.01,
                0.20,
              );

          // 🌟 إضافة تدرج الألوان المتنوعة الخفيفة الموجودة بالصورة (رمادي، أبيض، ولمسات باستيل دافئة)
          double colorPicker = random.nextDouble();
          if (colorPicker < 0.50) {
            paint.color = Colors.grey.withOpacity(finalOpacity);
          } else if (colorPicker < 0.85) {
            paint.color = Colors.white.withOpacity(finalOpacity * 1.6);
          } else if (colorPicker < 0.92) {
            // لمسة باستيل زرقاء/سماوية خفيفة جداً كما في خلفية الصورة
            paint.color = const Color(
              0xFFB3E5FC,
            ).withOpacity(finalOpacity * 0.8);
          } else {
            // لمسة باستيل صفراء/عاجية خفيفة
            paint.color = const Color(
              0xFFFFF9C4,
            ).withOpacity(finalOpacity * 0.8);
          }

          // رسم البكسل بمحاذاة تامة وبدون فواصل لإعطاء تأثير الماتريكس المتصل
          canvas.drawRect(Rect.fromLTWH(i, j, pixelSize, pixelSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BlurryPixelWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // الخلفية الأصلية
        // يمكنك وضع أي محتوى هنا، مثلاً شاشة اختيار الألوان
        Container(color: Colors.white),

        // طبقة البكسلات المتلاحمة
        CustomPaint(
          size: MediaQuery.of(context).size,
          painter: TPixelPainter(),
        ),

        // طبقة التغبيش (Blur) لجميع المحتوى
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(color: Colors.white.withOpacity(0.0)),
          ),
        ),
      ],
    );
  }
}
*/

class TPixelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(123);
    final paint = Paint()..style = PaintingStyle.fill;
    // حجم البكسل - جعلناه 12 ليحاكي المربعات الظاهرة في الصورة بدقة
    const double pixelSize = 12.0;

    final double centerX = size.width * 0.35;
    final double centerY = size.height * 0.5;
    final double maxDistance = sqrt(centerX * centerX + centerY * centerY);

    for (double i = 0; i < size.width; i += pixelSize) {
      for (double j = 0; j < size.height; j += pixelSize) {
        double dx = i - centerX;
        double dy = j - centerY;
        double distance = sqrt(dx * dx + dy * dy);
        double proximityToCenter =
            1.0 - (distance / maxDistance).clamp(0.0, 1.0);

        // نسبة ظهور البكسل (احتمالية عالية لملء الشاشة بكثافة)
        double spawnChance = 0.65 + (proximityToCenter * 0.30);

        if (random.nextDouble() < spawnChance) {
          // رفعنا الحد الأدنى والتحكم في الشفافية لتصبح الألوان واضحة وتغطي ما تحتها
          double baseOpacity = 0.08 + (proximityToCenter * 0.15);
          double finalOpacity =
              (baseOpacity * (0.7 + random.nextDouble() * 0.3)).clamp(
                0.04,
                0.30,
              );

          double colorPicker = random.nextDouble();
          if (colorPicker < 0.45) {
            paint.color = Colors.grey.withOpacity(finalOpacity);
          } else if (colorPicker < 0.75) {
            paint.color = Colors.white.withOpacity(finalOpacity * 1.8);
          } else if (colorPicker < 0.88) {
            // لمسة الباستيل الزرقاء
            paint.color = const Color(
              0xFFB3E5FC,
            ).withOpacity(finalOpacity * 1.3);
          } else {
            // لمسة الباستيل الصفراء الدائمة في التصميم
            paint.color = const Color(
              0xFFFFF9C4,
            ).withOpacity(finalOpacity * 1.3);
          }

          canvas.drawRect(Rect.fromLTWH(i, j, pixelSize, pixelSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BlurryPixelWidget extends StatelessWidget {
  final Widget
  child; // المحتوى الأصلي للشاشة الخاص بك (مثلاً أزرار اختيار الألوان)

  const BlurryPixelWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. الطبقة السفلية: المحتوى الأصلي للشاشة
        child,

        // 2. طبقة التغبيش القوي والعزل (BackdropFilter)
        // تم وضعه هنا ليقوم بتغبيش الـ child فقط، دون التأثير على حدة البكسلات
        Positioned.fill(
          child: BackdropFilter(
            // زيادة الـ sigma إلى 18 لإخفاء معالم الشاشة تماماً ومحو تفاصيلها المزعجة
            filter: ui.ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
            child: Container(
              // دمج التغبيش مع طبقة بيضاء خفيفة جداً لتعطي مظهر الزجاج الضبابي (Frosted Glass)
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ),

        // 3. الطبقة العلوية: البكسلات الملونة الحادة
        // بما أنها فوق التغبيش، ستظهر مربعات البكسل واضحة ونظيفة تماماً كما في الصورة
        Positioned.fill(child: CustomPaint(painter: TPixelPainter())),
      ],
    );
  }
}


/*
class TPixelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(123); // Seed ثابت للحفاظ على جمالية التوزيع
    final paint = Paint()..style = PaintingStyle.fill;

    // حجم البكسل المتناسق مع أبعاد الشاشة
    const double pixelSize = 10.0;

    // نقطة تمركز الكثافة البكسلية (قريبة من مكان ظهور الفقاعة والـ Chips)
    final double centerX = size.width * 0.35;
    final double centerY = size.height * 0.5;
    final double maxDistance = sqrt(centerX * centerX + centerY * centerY);

    for (double i = 0; i < size.width; i += pixelSize) {
      for (double j = 0; j < size.height; j += pixelSize) {
        // حساب مسافة البكسل الحالي عن مركز الكثافة
        double dx = i - centerX;
        double dy = j - centerY;
        double distance = sqrt(dx * dx + dy * dy);
        double proximityToCenter =
            1.0 - (distance / maxDistance).clamp(0.0, 1.0);

        // 🌟 معادلة الكثافة: البكسلات تكون متلاحمة جداً قرب المركز وتتلاشى للخارج
        double spawnChance = 0.40 + (proximityToCenter * 0.45);

        if (random.nextDouble() < spawnChance) {
          // الشفافية تتأثر أيضاً بالقرب من المركز لتعطي عمقاً بصرياً
          double baseOpacity = 0.02 + (proximityToCenter * 0.09);
          double finalOpacity =
              (baseOpacity * (0.6 + random.nextDouble() * 0.4)).clamp(
                0.01,
                0.15,
              );

          // 🌟 إضافة تدرج الألوان المتنوعة الخفيفة الموجودة بالصورة (رمادي، أبيض، ولمسات باستيل دافئة)
          double colorPicker = random.nextDouble();
          if (colorPicker < 0.50) {
            paint.color = Colors.grey.withOpacity(finalOpacity);
          } else if (colorPicker < 0.85) {
            paint.color = Colors.white.withOpacity(finalOpacity * 1.6);
          } else if (colorPicker < 0.92) {
            // لمسة باستيل زرقاء/سماوية خفيفة جداً كما في خلفية الصورة
            paint.color = const Color(
              0xFFB3E5FC,
            ).withOpacity(finalOpacity * 0.8);
          } else {
            // لمسة باستيل صفراء/عاجية خفيفة
            paint.color = const Color(
              0xFFFFF9C4,
            ).withOpacity(finalOpacity * 0.8);
          }

          // رسم البكسل بمحاذاة تامة وبدون فواصل لإعطاء تأثير الماتريكس المتصل
          canvas.drawRect(Rect.fromLTWH(i, j, pixelSize, pixelSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
*/

/*
class TPixelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(
      42,
    ); // تثبيت الـ Seed ليعطي نمط بكسلات ثابت وأنيق في كل مرة
    final paint = Paint()..style = PaintingStyle.fill;

    const double pixelSize = 12.0; // حجم البكسل المثالي والمطابق للتصميم

    for (double i = 0; i < size.width; i += pixelSize) {
      for (double j = 0; j < size.height; j += pixelSize) {
        // توليد قيمة عشوائية لتحديد ما إذا كنا سنرسم بكسل في هذا الموقع أم نتركه فارغاً
        // هذا يعطي التأثير المتلاشي والمبعثر الرائع على كامل الشاشة
        if (random.nextDouble() > 0.85) {
          // تدرجات مختلفة من الشفافية الناعمة جداً (بين 0.01 و 0.08) حتى لا تحجب محتوى التطبيق
          double opacity = 0.01 + random.nextDouble() * 0.07;

          // خلط بين مربعات رمادية ومربعات بيضاء ناصعة خفيفة كما بالصورة
          paint.color = random.nextBool()
              ? Colors.grey.withOpacity(opacity)
              : Colors.white.withOpacity(opacity * 1.5);

          canvas.drawRect(
            Rect.fromLTWH(i, j, pixelSize - 1, pixelSize - 1),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
*/

/*
class TPixelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random();
    final paint = Paint()..style = PaintingStyle.fill;

    // حجم البكسل الواحد (يمكنك تصغيره أو تكبيره حسب الرغبة، مثلاً 8 أو 12 بكسل)
    const double pixelSize = 10.0;

    // حلقات تكرارية (Loops) للمرور على كامل طول وعرض مساحة الخلفية المتاحة
    for (double i = 0; i < size.width; i += pixelSize) {
      for (double j = 0; j < size.height; j += pixelSize) {
        // 🌟 السر هنا: توليد درجة شفافية عشوائية ومختلفة لكل بكسل (بين 0.02 و 0.18)
        // هذا يعطي تأثير مربعات الموزاييك أو البكسلات المتداخلة الناعمة كالموجودة في التصميم
        double randomOpacity = 0.02 + random.nextDouble() * 0.16;

        // تحديد لون البكسل الحالي مع الشفافية المحسوبة ديناميكياً
        paint.color = Colors.grey.withOpacity(randomOpacity);

        // رسم المربع الصغير (البكسل) على الشاشة
        canvas.drawRect(
          Rect.fromLTWH(
            i,
            j,
            pixelSize - 1,
            pixelSize - 1,
          ), // طرح 1 بكسل لترك فاصل شبكي ناعم جداً
          paint,
        );
      }
    }
  }

  // نضع false لمنع إعادة الرسم المستمرة للحفاظ على أداء المعالج والبطارية
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
*/