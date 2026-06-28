import 'package:flutter/material.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'dart:math';

class TModernHeaderDesign extends StatelessWidget {
  const TModernHeaderDesign({
    super.key,
    required this.child,
    required this.isCollapsed,
    required this.statusBarHeight,
  });

  final Widget child;
  final bool isCollapsed;
  final double statusBarHeight;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration dynamicBackground = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          TColors.accent,
          TColors.primary,
          TColors.primary,
          TColors.primary,
          TColors.cornsilk,
        ],
      ),
    );

    // 🌟 تغليف الهيدر بالكامل داخل الـ Clipper لقص البكسلات والخلفية معاً بشكل منحني انسيابي ومثالي
    return ClipPath(
      clipper: TModernCurvedClipper(),
      child: Container(
        decoration: dynamicBackground,
        child: Stack(
          children: [
            /// 1. 🌟 طبقة البكسلات الشاملة المتدرجة ممتدة على كامل المساحة المقصوصة
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: THeaderPixelGradientPainter()),
              ),
            ),

            /// 2. الدائرة الخلفية العملاقة الناعمة
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: isCollapsed ? -80 : -50,
              left: isCollapsed ? -80 : -40,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCollapsed ? 180 : 280,
                height: isCollapsed ? 180 : 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            /// 3. الدائرة الخطية الخارجية الكبرى
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: isCollapsed ? -100 : -70,
              left: isCollapsed ? -100 : -60,
              child: SizedBox(
                width: isCollapsed ? 220 : 340,
                height: isCollapsed ? 220 : 340,
                child: CustomPaint(
                  painter: TSingleRingPainter(
                    color: Colors.white.withOpacity(0.12),
                    strokeWidth: 1.5,
                  ),
                ),
              ),
            ),

            /// 4. الدائرة الخطية الداخلية الصغيرة
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: isCollapsed ? -30 : -10,
              left: isCollapsed ? -35 : -10,
              child: SizedBox(
                width: isCollapsed ? 100 : 160,
                height: isCollapsed ? 100 : 160,
                child: CustomPaint(
                  painter: TSingleRingPainter(
                    color: TColors.secondary.withOpacity(0.2),
                    strokeWidth: 1.0,
                  ),
                ),
              ),
            ),

            /// 5. التكوين الهندسي الحديث (يمين سفلي)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: isCollapsed ? -50 : -20,
              right: isCollapsed ? -30 : 10,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCollapsed ? 120 : 200,
                height: isCollapsed ? 120 : 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),

            // حلقة خطية خارجية كبرى يمين أسفل
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: isCollapsed ? -70 : -50,
              right: isCollapsed ? -50 : -20,
              child: SizedBox(
                width: isCollapsed ? 160 : 260,
                height: isCollapsed ? 160 : 260,
                child: CustomPaint(
                  painter: TSingleRingPainter(
                    color: Colors.white.withOpacity(0.15),
                    strokeWidth: 1.2,
                  ),
                ),
              ),
            ),

            /// 6. كرات ثلاثية الأبعاد مضيئة وثابتة الأبعاد
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: isCollapsed ? 25 : 170,
              left: isCollapsed ? 75 : 45,
              child: TModernSphereOrb(size: isCollapsed ? 25 : 45),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: isCollapsed ? 15 : 45,
              right: isCollapsed ? 110 : 45,
              child: TModernSphereOrb(size: isCollapsed ? 28 : 55),
            ),

            /// 7. محتوى الشاشة الداخلي الممرر (نصوص، صندوق البحث، أزرار التصنيفات)
            child,
          ],
        ),
      ),
    );
  }
}

/*
class TModernHeaderDesign extends StatelessWidget {
  const TModernHeaderDesign({
    super.key,
    required this.child,
    required this.isCollapsed,
    required this.statusBarHeight,
  });

  final Widget child;
  final bool isCollapsed;
  final double statusBarHeight;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration dynamicBackground = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          TColors.accent,
          TColors.primary,
          TColors.primary,
          TColors.primary,
          TColors.cornsilk,
        ],
      ),
    );

    return Container(
      decoration: dynamicBackground,
      // 🌟 أزلنا الـ CustomPaint من هنا ووضعناه داخل الـ Stack كـ Positioned
      child: Stack(
        children: [
          /// 🌟 طبقة البكسلات المتدرجة - تم قفل أبعادها بالكامل لعدم ضرب الـ Layout
          Positioned.fill(
            child: CustomPaint(painter: THeaderPixelGradientPainter()),
          ),

          /// 1. الدائرة الخلفية العملاقة الناعمة
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: isCollapsed ? -80 : -50,
            left: isCollapsed ? -80 : -40,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCollapsed ? 180 : 280,
              height: isCollapsed ? 180 : 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          /// 2. الدائرة الخطية الخارجية
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: isCollapsed ? -100 : -70,
            left: isCollapsed ? -100 : -60,
            child: SizedBox(
              // 🌟 استخدام SizedBox لحماية أبعاد الـ CustomPaint الداخلي
              width: isCollapsed ? 220 : 340,
              height: isCollapsed ? 220 : 340,
              child: CustomPaint(
                painter: TSingleRingPainter(
                  color: Colors.white.withOpacity(0.12),
                  strokeWidth: 1.5,
                ),
              ),
            ),
          ),

          /// 3. الدائرة الخطية الداخلية الصغيرة
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: isCollapsed ? -30 : -10,
            left: isCollapsed ? -35 : -10,
            child: SizedBox(
              // 🌟 حماية أبعاد الدائرة الصغيرة
              width: isCollapsed ? 100 : 160,
              height: isCollapsed ? 100 : 160,
              child: CustomPaint(
                painter: TSingleRingPainter(
                  color: TColors.secondary.withOpacity(0.2),
                  strokeWidth: 1.0,
                ),
              ),
            ),
          ),

          /// 4. التكوين الهندسي الحديث (يمين سفلي)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: isCollapsed ? -50 : -20,
            right: isCollapsed ? -30 : 10,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCollapsed ? 120 : 200,
              height: isCollapsed ? 120 : 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          // حلقة خطية خارجية كبرى
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: isCollapsed ? -70 : -50,
            right: isCollapsed ? -50 : -20,
            child: SizedBox(
              // 🌟 حماية الأبعاد هنا أيضاً
              width: isCollapsed ? 160 : 260,
              height: isCollapsed ? 160 : 260,
              child: CustomPaint(
                painter: TSingleRingPainter(
                  color: Colors.white.withOpacity(0.15),
                  strokeWidth: 1.2,
                ),
              ),
            ),
          ),

          /// 5. كرات ثلاثية الأبعاد مضيئة
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: isCollapsed ? 25 : 170,
            left: isCollapsed ? 75 : 45,
            child: TModernSphereOrb(size: isCollapsed ? 25 : 45),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: isCollapsed ? 15 : 45,
            right: isCollapsed ? 110 : 45,
            child: TModernSphereOrb(size: isCollapsed ? 28 : 55),
          ),

          // محتوى الشاشة الداخلي (AppBars, Search, Categories)
          child,
        ],
      ),
    );
  }
}
*/
/*
/// تصميم هيدر عصري ومبسط يعتمد على الدوائر المتداخلة والخطوط الناعمة بالطابع الحديث مع تأثير البكسل المتدرج
class TModernHeaderDesign extends StatelessWidget {
  const TModernHeaderDesign({
    super.key,
    required this.child,
    required this.isCollapsed,
    required this.statusBarHeight,
  });

  final Widget child;
  final bool isCollapsed;
  final double statusBarHeight;

  @override
  Widget build(BuildContext context) {
    // التدرج اللوني الأساسي الفخم للبراند (الخلفية الصلبة)
    final BoxDecoration dynamicBackground = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          TColors.accent, // الوردي التوتي في الأعلى
          TColors.primary,
          TColors.primary,
          TColors.primary,
          TColors.cornsilk, // لمسة كريمية ناعمة
        ],
      ),
    );

    return Container(
      decoration: dynamicBackground,
      child: CustomPaint(
        // 🌟 التعديل الجوهري: إضافة طبقة البكسلات المتدرجة فوق التدرج اللوني الأصلي للهيدر
        painter: THeaderPixelGradientPainter(),
        child: Stack(
          children: [
            /// 1. الدائرة الخلفية العملاقة الناعمة (يسار علوي) - تعطي توهج خلفي (Glow)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: isCollapsed ? -80 : -50,
              left: isCollapsed ? -80 : -40,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCollapsed ? 180 : 280,
                height: isCollapsed ? 180 : 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            /// 2. الدائرة الخطية الخارجية (Outlined) المحيطة بها بالأسلوب الحديث
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: isCollapsed ? -100 : -70,
              left: isCollapsed ? -100 : -60,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCollapsed ? 220 : 340,
                height: isCollapsed ? 220 : 340,
                child: CustomPaint(
                  painter: TSingleRingPainter(
                    color: Colors.white.withOpacity(0.12),
                    strokeWidth: 1.5,
                  ),
                ),
              ),
            ),

            /// 3. الدائرة الخطية الداخلية الصغيرة المتداخلة بالداخل
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: isCollapsed ? -30 : -10,
              left: isCollapsed ? -35 : -10,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCollapsed ? 100 : 160,
                height: isCollapsed ? 100 : 160,
                child: CustomPaint(
                  painter: TSingleRingPainter(
                    color: TColors.secondary.withOpacity(0.2),
                    strokeWidth: 1.0,
                  ),
                ),
              ),
            ),

            /// 4. التكوين الهندسي الحديث في الجهة اليمنى السفلية (خلف التصنيفات)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: isCollapsed ? -50 : -20,
              right: isCollapsed ? -30 : 10,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCollapsed ? 120 : 200,
                height: isCollapsed ? 120 : 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),

            // حلقة خطية خارجية كبرى تتقاطع مع الكاتيجوري لتعطي طابع Glassmorphic
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: isCollapsed ? -70 : -50,
              right: isCollapsed ? -50 : -20,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCollapsed ? 160 : 260,
                height: isCollapsed ? 160 : 260,
                child: CustomPaint(
                  painter: TSingleRingPainter(
                    color: Colors.white.withOpacity(0.15),
                    strokeWidth: 1.2,
                  ),
                ),
              ),
            ),

            /// 5. كرات ثلاثية الأبعاد مضيئة بأسلوب ناعم ومبسط
            // الكرة اليسرى المتفاعلة
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: isCollapsed ? 25 : 170,
              left: isCollapsed ? 75 : 45,
              child: TModernSphereOrb(size: isCollapsed ? 25 : 45),
            ),

            // الكرة اليمنى الأنيقة
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: isCollapsed ? 15 : 45,
              right: isCollapsed ? 110 : 45,
              child: TModernSphereOrb(size: isCollapsed ? 28 : 55),
            ),

            // محتوى الشاشة الداخلي (AppBars, Search, Categories)
            child,
          ],
        ),
      ),
    );
  }
}
*/

class THeaderPixelGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(789); // Seed ثابت لاستقرار توزيع المربعات
    final paint = Paint()..style = PaintingStyle.fill;

    // حجم البكسل المتناسق مع أبعاد الهيدر
    const double pixelSize = 8.0;

    for (double i = 0; i < size.width; i += pixelSize) {
      for (double j = 0; j < size.height; j += pixelSize) {
        // حساب النسبة من الأسفل (1.0 عند الحافة السفلية للهيدر، و 0.0 في الأعلى)
        double bottomPositionRatio = j / size.height;

        // 🌟 [معادلة الكثافة العكسية]: البكسلات تتكثف في الأسفل وتتلاشى صعوداً للأعلى
        double spawnThreshold = 0.20 + ((1.0 - bottomPositionRatio) * 0.70);

        if (random.nextDouble() > spawnThreshold) {
          // الشفافية تزداد عمقاً في الأسفل لتندمج مع المنحنى والألوان الفاتحة
          double baseOpacity = 0.02 + (bottomPositionRatio * 0.09);
          double finalOpacity =
              (baseOpacity * (0.5 + random.nextDouble() * 0.5)).clamp(
                0.01,
                0.14,
              );

          double colorPicker = random.nextDouble();
          if (colorPicker < 0.40) {
            paint.color = Colors.white.withOpacity(finalOpacity * 1.5);
          } else if (colorPicker < 0.75) {
            paint.color = Colors.grey.withOpacity(finalOpacity);
          } else if (colorPicker < 0.90) {
            // تداخل ناعم بلون مشتق من الـ cornsilk العاجي للتصميم
            paint.color = const Color(
              0xFFFFF9E6,
            ).withOpacity(finalOpacity * 1.2);
          } else {
            // لمسة باستيل زهرية خفيفة جداً تتماشى مع هيدر البراند الأساسي
            paint.color = const Color(
              0xFFFFE0B2,
            ).withOpacity(finalOpacity * 0.8);
          }

          canvas.drawRect(Rect.fromLTWH(i, j, pixelSize, pixelSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/*
class THeaderPixelGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(456); // تثبيت الـ Seed لاستقرار التصميم
    final paint = Paint()..style = PaintingStyle.fill;

    // 💡 حجم البكسل: 6.0 إلى 7.0 ممتاز جداً ليعطي مظهر الـ Retro/Modern المدمج
    const double pixelSize = 6.0;

    for (double i = 0; i < size.width; i += pixelSize) {
      for (double j = 0; j < size.height; j += pixelSize) {
        // حساب نسبة الارتفاع الحالي (من 0.0 في أعلى الهيدر إلى 1.0 في أسفله)
        double verticalPositionRatio = j / size.height;

        // 🌟 [التعديل الجوهري الأول]: تحديد احتمالية الظهور بناءً على الارتفاع
        // في الأعلى (verticalPositionRatio القريبة من 0): الاحتمالية تكون عالية جداً (قريبة من 95%) لتصطف البكسلات بجانب بعضها.
        // في الأسفل (verticalPositionRatio القريبة من 1): تقل الاحتمالية تدريجياً لتبدأ البكسلات بالتشظي والتفرق.
        double spawnThreshold = 0.15 + (verticalPositionRatio * 0.75);

        if (random.nextDouble() > spawnThreshold) {
          // 🌟 [التعديل الجوهري الثاني]: الشفافية (Opacity)
          // في الأعلى تكون البكسلات واضحة (تصل إلى 14% شفافية لتظهر التدرج بشكل ناصع)
          // كلما نزلنا لأسفل تخفت الشفافية حتى تنصهر تماماً مع تدرج الخلفية الأصلية
          double baseOpacity = 0.04 + (random.nextDouble() * 0.10);
          double fadeOpacity =
              baseOpacity * (1.0 - (verticalPositionRatio * 0.9));

          if (fadeOpacity > 0.002) {
            // مزيج ألوان البكسلات (أبيض ناصع، وأبيض عاجي دافئ متناسق مع الـ cornsilk)
            paint.color = random.nextBool()
                ? Colors.white.withOpacity(fadeOpacity)
                : const Color(0xFFFFF9E6).withOpacity(fadeOpacity * 0.85);

            // 🌟 [التعديل الجوهري الثالث]: إغلاق الفجوات (No Gaps)
            // رسم البكسل بأبعاده الكاملة (بدون طرح مسافات) ليجلس البكسل بجوار أخيه تماماً كالمصفوفة المتلاحمة
            canvas.drawRect(Rect.fromLTWH(i, j, pixelSize, pixelSize), paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
*/
/*
class THeaderPixelGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(
      456,
    ); // Seed ثابت للحفاظ على توزيع بكسلي فخم ومستقر
    final paint = Paint()..style = PaintingStyle.fill;

    const double pixelSize =
        7.0; // حجم البكسل الميكرو المتناسق مع أبعاد الهيدر الكبيرة

    for (double i = 0; i < size.width; i += pixelSize) {
      for (double j = 0; j < size.height; j += pixelSize) {
        // 🌟 معادلة التلاشي العمودي (Vertical Fade Ratio):
        // كلما زادت قيمة j (النزول لأسفل الهيدر)، يقل احتمال رسم البكسل وتقل شفافيته
        double verticalPositionRatio = j / size.height;

        // احتمال ظهور البكسل يقل كلما اتجهنا لأسفل
        double spawnProbability = 0.85 + (verticalPositionRatio * 0.12);

        if (random.nextDouble() > spawnProbability) {
          // الشفافية تتأثر أيضاً بالارتفاع؛ تكون أنصع بالأعلى وتخفت تدريجياً لتبدو كالضباب البكسلي
          double baseOpacity = 0.03 + (random.nextDouble() * 0.10);
          double fadeOpacity =
              baseOpacity * (1.0 - (verticalPositionRatio * 0.8));

          // حماية للتأكد من عدم تمرير قيم سالب للشفافية
          if (fadeOpacity > 0.005) {
            // مزيج رائع بين البكسلات البيضاء والذهبية الناعمة لتتناسق مع الـ cornsilk والـ نيون ناعم
            paint.color = random.nextBool()
                ? Colors.white.withOpacity(fadeOpacity)
                : const Color(
                    0xFFFFF8DC,
                  ).withOpacity(fadeOpacity * 0.7); // لمسة ذهبية ناعمة جداً

            // رسم البكسل مع فجوة ميكرومترية متناسقة
            canvas.drawRect(
              Rect.fromLTWH(i, j, pixelSize - 0.6, pixelSize - 0.6),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
*/
/// رسام لرسم حلقة دائرية خطية واحدة نقية جداً وبسيطة
class TSingleRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  TSingleRingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant TSingleRingPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

/// ويدجت الكرة ثلاثية الأبعاد بطابع عصري ومبسط ولمعان ناعم متناسق مع البراند
class TModernSphereOrb extends StatelessWidget {
  final double size;

  const TModernSphereOrb({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.4), // اتجاه الإضاءة الحديثة
          radius: 0.9,
          colors: [
            Colors.white.withOpacity(0.7), // نقطة الضوء القوية
            TColors.secondary.withOpacity(0.8), // التوهج الوردي الكريمي الناعم
            TColors.primary, // لون البراند الوردي الأساسي
            TColors.darkContainer, // العمق الباذنجاني الخفيف بالأطراف
          ],
          stops: const [0.0, 0.2, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.25),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }
}

class TModernCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30);

    final firstFirstCurve = Offset(0, size.height);
    final firstLastCurve = Offset(30, size.height);
    path.quadraticBezierTo(
      firstFirstCurve.dx,
      firstFirstCurve.dy,
      firstLastCurve.dx,
      firstLastCurve.dy,
    );

    path.lineTo(size.width - 30, size.height);

    final secondFirstCurve = Offset(size.width, size.height);
    final secondLastCurve = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(
      secondFirstCurve.dx,
      secondFirstCurve.dy,
      secondLastCurve.dx,
      secondLastCurve.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}


/*
/// كلاس قص المنحنى الانسيابي لأسفل التصميم
class TModernCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30);

    final firstFirstCurve = Offset(0, size.height);
    final firstLastCurve = Offset(30, size.height);
    path.quadraticBezierTo(
      firstFirstCurve.dx,
      firstFirstCurve.dy,
      firstLastCurve.dx,
      firstLastCurve.dy,
    );

    path.lineTo(size.width - 30, size.height);

    final secondFirstCurve = Offset(size.width, size.height);
    final secondLastCurve = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(
      secondFirstCurve.dx,
      secondFirstCurve.dy,
      secondLastCurve.dx,
      secondLastCurve.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReplipper(covariant CustomClipper<Path> oldClipper) => false;

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    throw UnimplementedError();
  }
}
*/



/*
/// تصميم هيدر عصري ومبسط يعتمد على الدوائر المتداخلة والخطوط الناعمة بالطابع الحديث
class TModernHeaderDesign extends StatelessWidget {
  const TModernHeaderDesign({
    super.key,
    required this.child,
    required this.isCollapsed,
    required this.statusBarHeight,
  });

  final Widget child;
  final bool isCollapsed;
  final double statusBarHeight;

  @override
  Widget build(BuildContext context) {
    // التدرج اللوني الأساسي المعتمد على هويتك البصرية الفخمة
    final BoxDecoration dynamicBackground = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          TColors.accent, // الوردي التوتي في الأعلى
          TColors.primary, // الوردي النيون المطفي في المنتصف
          TColors.primary, // الوردي النيون المطفي في المنتصف
          TColors.primary, // الوردي النيون المطفي في المنتصف
          TColors.primary, // الوردي النيون المطفي في المنتصف
          TColors.primary, // الوردي النيون المطفي في المنتصف
          TColors.cornsilk, // الوردي النيون المطفي في المنتصف
          // TColors.accent, // الوردي التوتي في الأعلى
          //TColors.dark, // الأسود الباذنجاني في الأسفل للعمق البصري
        ],
      ),
    );

    return Container(
      decoration: dynamicBackground,
      child: Stack(
        children: [
          /// 1. الدائرة الخلفية العملاقة الناعمة (يسار علوي) - تعطي توهج خلفي (Glow)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: isCollapsed ? -80 : -50,
            left: isCollapsed ? -80 : -40,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCollapsed ? 180 : 280,
              height: isCollapsed ? 180 : 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TColors.white.withOpacity(0.06),
              ),
            ),
          ),

          /// 2. الدائرة الخطية الخارجية (Outlined) المحيطة بها بالأسلوب الحديث
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: isCollapsed ? -100 : -70,
            left: isCollapsed ? -100 : -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCollapsed ? 220 : 340,
              height: isCollapsed ? 220 : 340,
              child: CustomPaint(
                painter: TSingleRingPainter(
                  color: TColors.white.withOpacity(0.12),
                  strokeWidth: 1.5,
                ),
              ),
            ),
          ),

          /// 3. الدائرة الخطية الداخلية الصغيرة المتداخلة بالداخل
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: isCollapsed ? -30 : -10,
            left: isCollapsed ? -35 : -10,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCollapsed ? 100 : 160,
              height: isCollapsed ? 100 : 160,
              child: CustomPaint(
                painter: TSingleRingPainter(
                  color: TColors.secondary.withOpacity(0.2),
                  strokeWidth: 1.0,
                ),
              ),
            ),
          ),

          /// 4. التكوين الهندسي الحديث في الجهة اليمنى السفلية (خلف التصنيفات)
          // الدائرة المصمتة المتوسطة الناعمة
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: isCollapsed ? -50 : -20,
            right: isCollapsed ? -30 : 10,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCollapsed ? 120 : 200,
              height: isCollapsed ? 120 : 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TColors.white.withOpacity(0.04),
              ),
            ),
          ),

          // حلقة خطية خارجية كبرى تتقاطع مع الكاتيجوري لتعطي طابع Glassmorphic
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: isCollapsed ? -70 : -50,
            right: isCollapsed ? -50 : -20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCollapsed ? 160 : 260,
              height: isCollapsed ? 160 : 260,
              child: CustomPaint(
                painter: TSingleRingPainter(
                  color: TColors.white.withOpacity(0.15),
                  strokeWidth: 1.2,
                ),
              ),
            ),
          ),

          /// 5. كرات ثلاثية الأبعاد مضيئة بأسلوب ناعم ومبسط (تتفاعل وتتحرك عند التمرير)
          // الكرة اليسرى المتفاعلة
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: isCollapsed ? 25 : 170,
            left: isCollapsed ? 75 : 45,
            child: TModernSphereOrb(size: isCollapsed ? 25 : 45),
          ),

          // الكرة اليمنى الأنيقة
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: isCollapsed ? 15 : 45,
            right: isCollapsed ? 110 : 45,
            child: TModernSphereOrb(size: isCollapsed ? 28 : 55),
          ),

          // محتوى الشاشة الداخلي (AppBars, Search, Categories)
          child,
        ],
      ),
    );
  }
}

/// رسام لرسم حلقة دائرية خطية واحدة نقية جداً وبسيطة
class TSingleRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  TSingleRingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant TSingleRingPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

/// ويدجت الكرة ثلاثية الأبعاد بطابع عصري ومبسط ولمعان ناعم متناسق مع البراند
class TModernSphereOrb extends StatelessWidget {
  final double size;

  const TModernSphereOrb({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.4), // اتجاه الإضاءة الحديثة
          radius: 0.9,
          colors: [
            TColors.white.withOpacity(0.7), // نقطة الضوء القوية
            TColors.secondary.withOpacity(0.8), // التوهج الوردي الكريمي الناعم
            TColors.primary, // لون البراند الوردي الأساسي
            TColors.darkContainer, // العمق الباذنجاني الخفيف بالأطراف
          ],
          stops: const [0.0, 0.2, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.25),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }
}

/// كلاس قص المنحنى الانسيابي لأسفل التصميم
class TModernCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30);

    final firstFirstCurve = Offset(0, size.height);
    final firstLastCurve = Offset(30, size.height);
    path.quadraticBezierTo(
      firstFirstCurve.dx,
      firstFirstCurve.dy,
      firstLastCurve.dx,
      firstLastCurve.dy,
    );

    path.lineTo(size.width - 30, size.height);

    final secondFirstCurve = Offset(size.width, size.height);
    final secondLastCurve = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(
      secondFirstCurve.dx,
      secondFirstCurve.dy,
      secondLastCurve.dx,
      secondLastCurve.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
*/

/*
/// الويدجت الذكية المسؤولة عن حساب المسافات وتحريك التصميم ديناميكياً مع الألوان الرسمية للبراند
class TModernHeaderDesign extends StatelessWidget {
  const TModernHeaderDesign({
    super.key,
    required this.child,
    required this.isCollapsed,
    required this.statusBarHeight,
  });

  final Widget child;
  final bool isCollapsed;
  final double statusBarHeight;

  @override
  Widget build(BuildContext context) {
    // بناء تدرج لوني فخم متناسق 100% مع ألوان تطبيقك الرسمية (وردي توتي -> نيون مطفي -> باذنجاني داكن)
    final BoxDecoration dynamicBackground = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          TColors.primary, // الوردي التوتي العميق الفخم في الأعلى (0xFFF7567C)
          TColors.accent, // الوردي النيون المطفي في المنتصف (0xFF9D4B6C)
          TColors
              .dark, // الأسود الباذنجاني العميق في الأسفل (0xFF1F1216) ليعطي بعداً ثالثاً ساحراً
        ],
      ),
    );

    return Container(
      decoration: dynamicBackground,
      child: Stack(
        children: [
          /// 1. نظام الحلقات المتداخلة (يسار علوي) - بلون الهوية الأبيض الشفاف
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            top: isCollapsed ? statusBarHeight - 50 : -40,
            left: isCollapsed ? -60 : -30,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isCollapsed ? 160 : 250,
              height: isCollapsed ? 160 : 250,
              child: CustomPaint(
                painter: TConcentricRingsPainter(
                  baseColor: TColors.white.withOpacity(0.18),
                  ringCount: 4,
                  strokeWidth: isCollapsed ? 2.5 : 4.5,
                ),
              ),
            ),
          ),

          /// 2. نظام الحلقات المتداخلة (يمين علوي) - يضبط نفسه بدقة تحت منطقة البطارية والساعة
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            top: isCollapsed ? statusBarHeight - 10 : statusBarHeight + 15,
            right: isCollapsed ? 10 : 30,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isCollapsed ? 90 : 130,
              height: isCollapsed ? 90 : 130,
              child: CustomPaint(
                painter: TConcentricRingsPainter(
                  baseColor: TColors.white.withOpacity(0.15),
                  ringCount: 3,
                  strokeWidth: isCollapsed ? 2.0 : 3.5,
                ),
              ),
            ),
          ),

          /// 3. نظام الحلقات السفلي الكبير - يرتفع بسلاسة خلف شريط التصنيفات
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            bottom: isCollapsed ? -40 : 10,
            right: isCollapsed ? -40 : -20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isCollapsed ? 180 : 290,
              height: isCollapsed ? 180 : 290,
              child: CustomPaint(
                painter: TConcentricRingsPainter(
                  baseColor: TColors.white.withOpacity(0.12),
                  ringCount: 4,
                  strokeWidth: isCollapsed ? 2.5 : 5.0,
                ),
              ),
            ),
          ),

          /// 4. الكرات ثلاثية الأبعاد (3D Spheres) المضيئة المصبوغة بهوية التطبيق المتناسقة
          // الكرة اليسرى الطافية
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            bottom: isCollapsed ? 20 : 120,
            left: isCollapsed ? 80 : 30,
            child: T3DSphereOrb(size: isCollapsed ? 30 : 55),
          ),
          // الكرة الوسطى (تختفي عند الانغلاق لتجنب الازدحام المروري للعناصر)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            bottom: isCollapsed ? -100 : 75,
            left: MediaQuery.of(context).size.width * 0.4,
            child: const T3DSphereOrb(size: 40),
          ),
          // الكرة اليمنى السفلية الكبيرة
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            bottom: isCollapsed ? 5 : 25,
            right: isCollapsed ? 120 : 20,
            child: T3DSphereOrb(size: isCollapsed ? 35 : 75),
          ),

          // محتوى الواجهة الممرر من شاشة الهوم (AppBar, Search, Categories)
          child,
        ],
      ),
    );
  }
}

/// رسام الحلقات المتطابقة المركز بدقة هندسية متناهية النقاء
class TConcentricRingsPainter extends CustomPainter {
  final Color baseColor;
  final int ringCount;
  final double strokeWidth;

  TConcentricRingsPainter({
    required this.baseColor,
    required this.ringCount,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    double maxRadius = size.width / 2;
    double radiusStep = maxRadius / ringCount;

    for (int i = 0; i < ringCount; i++) {
      final double currentRadius = maxRadius - (i * radiusStep);
      final double opacityFactor = (1.0 - (i / ringCount)).clamp(0.1, 1.0);

      final Paint ringPaint = Paint()
        ..color = baseColor.withOpacity(baseColor.opacity * opacityFactor)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..isAntiAlias = true;

      canvas.drawCircle(center, currentRadius, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TConcentricRingsPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.baseColor != baseColor;
  }
}

/// ويدجت الكرات ثلاثية الأبعاد الاحترافية مع بؤرة ضوء وردي كريمي وظل باذنجاني عميق متكامل مع البراند
class T3DSphereOrb extends StatelessWidget {
  final double size;

  const T3DSphereOrb({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(
            -0.35,
            -0.4,
          ), // سقوط الضوء من الزاوية العلوية اليسرى لمحاكاة الواقعية
          radius: 0.85,
          colors: [
            TColors.white.withOpacity(
              0.65,
            ), // بؤرة اللمعان الأبيض الشديد للضوء الساقط
            TColors
                .secondary, // الوردي الكريمي الناعم (0xFFE5B5B5) كإضاءة جانبية
            TColors.primary, // اللون الأساسي الحامل للكرة (0xFFF7567C)
            TColors
                .darkContainer, // الظل الباذنجاني الداكن جداً المنعزل بالأطراف (0xFF2D1F24)
          ],
          stops: const [0.0, 0.25, 0.65, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.35),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

/// كلاس قص المنحنى السفلي الحفاظي بدقة فائقة
class TModernCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30);

    final firstFirstCurve = Offset(0, size.height);
    final firstLastCurve = Offset(30, size.height);
    path.quadraticBezierTo(
      firstFirstCurve.dx,
      firstFirstCurve.dy,
      firstLastCurve.dx,
      firstLastCurve.dy,
    );

    path.lineTo(size.width - 30, size.height);

    final secondFirstCurve = Offset(size.width, size.height);
    final secondLastCurve = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(
      secondFirstCurve.dx,
      secondFirstCurve.dy,
      secondLastCurve.dx,
      secondLastCurve.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
*/