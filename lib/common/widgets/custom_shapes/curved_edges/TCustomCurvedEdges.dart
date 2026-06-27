/*
/// كلاس مخصص لرسم الانحناء السفلي المتناسق بدقة لـ سيلفر آب بار
class TModernCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30);

    // المنحنى الأيسر
    final firstFirstCurve = Offset(0, size.height);
    final firstLastCurve = Offset(30, size.height);
    path.quadraticBezierTo(
      firstFirstCurve.dx,
      firstFirstCurve.dy,
      firstLastCurve.dx,
      firstLastCurve.dy,
    );

    // الخط المستقيم الأوسط
    path.lineTo(size.width - 30, size.height);

    // المنحنى الأيمن
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

/// الرسمة الهندسية المخصصة للحلقات المتموجة المتطابقة المركز
class TConcentricRingsPainter extends CustomPainter {
  final Color baseColor;
  final int ringCount;
  final double strokeWidth;

  TConcentricRingsPainter({
    required this.baseColor,
    this.ringCount = 4,
    this.strokeWidth = 4.0,
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
  bool shouldRepaint(covariant TConcentricRingsPainter oldDelegate) => false;
}

/// كرة ثلاثية الأبعاد مضيئة مطابقة للصورة تماماً
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
          center: const Alignment(-0.3, -0.4),
          radius: 0.85,
          colors: [
            Colors.white.withOpacity(0.4),
            const Color(0xFF0072FF).withOpacity(0.9),
            const Color(0xFF001A4E),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0072FF).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
*/


















/*
/// ويدجت الهيدر العصري الحامل للخلفية الرقمية والدوائر المتموجة ثلاثية الأبعاد
class TModernHeaderDesign extends StatelessWidget {
  const TModernHeaderDesign({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    // التدرج اللوني الفخم للخلفية الأساسية الممتدة خلف الـ Safe Area كما في الصورة
    final BoxDecoration headerGradient = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          backgroundColor ??
              const Color(0xFF043B8F), // أزرق ملكي داكن من الأعلى
          backgroundColor ??
              const Color(0xFF012260), // أزرق ليلي عميق جداً من الأسفل
        ],
      ),
    );

    return Container(
      decoration: headerGradient,
      child: Stack(
        children: [
          // 1. نظام الحلقات المتداخلة في الزاوية العلوية اليسرى
          Positioned(
            top: -40,
            left: -30,
            child: SizedBox(
              width: 260,
              height: 260,
              child: CustomPaint(
                painter: TConcentricRingsPainter(
                  baseColor: const Color(
                    0xFF4BE6FF,
                  ).withOpacity(0.35), // أزرق فيروزي مضيء
                ),
              ),
            ),
          ),

          // 2. نظام الحلقات المتداخلة في الزاوية العلوية اليمنى (تحت البطارية والساعة)
          Positioned(
            top: 10,
            right: 40,
            child: SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: TConcentricRingsPainter(
                  baseColor: const Color(0xFF4BE6FF).withOpacity(0.25),
                  ringCount: 3,
                  strokeWidth: 4,
                ),
              ),
            ),
          ),

          // 3. نظام الحلقات المتداخلة السفلي المتمدد عند الإغلاق والانفتاح
          Positioned(
            bottom: -60,
            right: 20,
            child: SizedBox(
              width: 320,
              height: 320,
              child: CustomPaint(
                painter: TConcentricRingsPainter(
                  baseColor: const Color(0xFF4BE6FF).withOpacity(0.18),
                  ringCount: 5,
                  strokeWidth: 7,
                ),
              ),
            ),
          ),

          // 4. الكرات المضيئة ثلاثية الأبعاد (3D Orb Glowing Effect) المنثورة في الخلفية
          // الكرة اليسرى السفلية المعلقة
          Positioned(bottom: 40, left: 15, child: const T3DSphereOrb(size: 65)),
          // الكرة الوسطى الطافية خلف مربع البحث والتصنيفات
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width * 0.4,
            child: const T3DSphereOrb(size: 45),
          ),
          // الكرة اليمنى السفلية الكبيرة
          Positioned(
            bottom: -10,
            right: -10,
            child: const T3DSphereOrb(size: 90),
          ),

          // محتوى الواجهة الخاص بك (AppBar, الأزرار, السيرش، أو الكاتيجوري)
          child,
        ],
      ),
    );
  }
}

/// رسام ذكي مخصص لبناء دوائر متموجة مفرغة متطابقة المركز بدقة متناهية
class TConcentricRingsPainter extends CustomPainter {
  final Color baseColor;
  final int ringCount;
  final double strokeWidth;

  TConcentricRingsPainter({
    required this.baseColor,
    this.ringCount = 5,
    this.strokeWidth = 5.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    // نحدد نصف القطر الأقصى بناءً على حجم الكانتينر المتاح
    double maxRadius = size.width / 2;
    double radiusStep = maxRadius / ringCount;

    for (int i = 0; i < ringCount; i++) {
      final double currentRadius = maxRadius - (i * radiusStep);
      // تلاشي تدريجي للشفافية كلما ابتعدت الحلقات إلى الخارج لتعطي طابعاً انسيابياً كالصورة تماماً
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
    return oldDelegate.baseColor != baseColor ||
        oldDelegate.ringCount != ringCount ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// ويدجت تصمم كرة ثلاثية الأبعاد مضيئة تعتمد على تراكب التدرج الشعاعي والخطي البصري
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
        // مزيج التدرج الدائري الداخلي لتوليد وهم البُعد الثالث الكروي (3D Sphere Illusion)
        gradient: RadialGradient(
          center: const Alignment(
            -0.3,
            -0.4,
          ), // نقطة سقوط الضوء في الأعلى واليسار ليعطي لمعاناً واقعياً
          radius: 0.85,
          colors: [
            const Color(0xFF86F3FF), // بؤرة الضوء شديدة السطوع
            const Color(0xFF0072FF), // التدرج الأزرق الحيوي للكرة
            const Color(
              0xFF002366,
            ), // الظل العميق المخفي في الأطراف المنعزلة للكرة
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          // توهج ناعم يحيط بالكرة لتبدو وكأنها تضيء الخلفية من خلفها
          BoxShadow(
            color: const Color(0xFF0072FF).withOpacity(0.35),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
*/