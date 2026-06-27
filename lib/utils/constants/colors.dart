import 'package:flutter/material.dart';

/*
class TColors {
  TColors._();

  // 1. الألوان الأساسية للهوية (Modern Beige & Latte Identity)
  // جعلنا البيج هو الـ Primary ليعطي الشعور بالفخامة والهدوء
  static const Color primary = Color(
    0xFFD4BDAC,
  ); // اللون البيج الحديث (Latte) - الأساسي
  static const Color secondary = Color(
    0xFF2D2E32,
  ); // الأسود الفحمي - للتباين والعناصر القوية
  static const Color accent = Color(
    0xFFE5D9CC,
  ); // سكري دافئ قليلاً للعناصر التفاعلية

  // 2. درجات الأبيض والسكري (The Clean Base)
  static const Color white = Color(0xFFFFFFFF);
  static const Color softWhite = Color(0xFFF9F8F6); // خلفية التطبيق (سكري ناعم)
  static const Color cream = Color(0xFFF2EFE9); // للحاويات والبطاقات
  static const Color beige = Color(0xFFE8E2D9); // للظلال الناعمة والحدود

  // 3. ألوان النصوص (Minimalist Typography)
  static const Color textPrimary = Color(
    0xFF1A1A1A,
  ); // أسود مطفي للنصوص الرئيسية
  static const Color textSecondary = Color(
    0xFF7A7A7A,
  ); // رمادي حجري للنصوص الفرعية
  static const Color textWhite = Colors.white; // للأزرار الغامقة
  static const Color textHint = Color(0xFFA5A5A5); // للملاحظات

  // 4. الحاويات والبطاقات (Containers & Cards)
  static const Color lightContainer = Colors.white;
  static const Color darkContainer = Color(
    0xFF1E293B,
  ); // كحلي رمادي عميق للوضع الداكن
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardNeutral = Color(0xFFF5F5F5);

  // 5. ألوان الحدود (Modern Minimal Borders)
  static const Color borderPrimary = Color(0xFFE8E8E8); // رمادي فاتح جداً
  static const Color borderSecondary = Color(0xFFCBD5E1); // رمادي أزرق باهت
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFFD1D1D1);

  // 6. ألوان الحالة الهادئة (Soft Status Colors)
  static const Color error = Color(0xFFBC5A5A); // أحمر طوبي مطفي
  static const Color success = Color(0xFF8BA889); // أخضر زيتوني هادئ
  static const Color warning = Color(0xFFD4A373); // خردلي دافئ

  // 7. الطابع الزجاجي (High-End Glassmorphism)
  static Color glassBackground = Colors.white.withOpacity(0.4);
  static Color glassBorder = Colors.white.withOpacity(0.5);
  static Color lightGlass = const Color(0xFFF2EFE9).withOpacity(0.3);

  // 8. درجات الرمادي والوضع الداكن (Neutral Shades)
  static const Color black = Color(0xFF1A1A1A);
  static const Color dark = Color(0xFF0F172A); // خلفية الوضع الداكن
  static const Color darkerGrey = Color(0xFF334155);
  static const Color darkGrey = Color(0xFF475569);
  static const Color grey = Color(0xFF94A3B8);
  static const Color softGrey = Color(0xFFF1F5F9);
  static const Color lightGrey = Color(0xFFF8FAFC);

  // إضافات للتسهيل
  static const Color light = lightContainer;
}
*/

class TColors {
  // 1. الألوان الأساسية (Modern Pink Brand Identity)
  // وردي توتي عميق (Deep Berry Pink) - يعطي هيبة وفخامة للبراند
  static const Color eggshell = Color(0xFFFCFCFC);
  static const Color cornsilk = Color(0xFFFFFAE3);
  static const Color primary = Color(0xFFF7567C);
  //0xFF9D4B6C
  // وردي كريمي دافئ (Warm Blush) - مثالي للأزرار الثانوية والعناصر الناعمة
  static const Color secondary = Color(0xFFE5B5B5);

  // وردي "نيون مطفي" (Soft Rose Gold) - للتميزات واللفتات الجمالية
  static const Color accent = Color(0xFF9D4B6C);
  //0xFFFF8FA3
  // 2. درجات الخلفيات (Clean & Spacious)
  static const Color white = Color(0xFFFFFFFF);
  // خلفية بيضاء بلمحة وردية باردة جداً (Rose Water) لتعزيز الهوية
  static const Color softWhite = Color(0xFFFDF8F9);
  static const Color lightContainer = Color(0xFFF9F1F3);
  // لون الحاويات في الوضع الداكن (Aubergine Night) متناسق مع الوردي
  static const Color darkContainer = Color(0xFF2D1F24);
  static const Color borderLight = Color(0xFFF1E4E8);

  // 3. الطابع الزجاجي (Advanced Glassmorphism)
  // شفافية وردية خفيفة جداً
  static Color glassBackground = const Color(0xFFFDF8F9).withOpacity(0.6);
  static Color glassBorder = const Color(0xFFEBCDD5).withOpacity(0.5);

  // 4. ألوان النصوص (Rich Typography)
  // أسود باذنجاني عميق جداً (بدلاً من الأزرق ليتناسب مع الوردي)
  static const Color textPrimary = Color(0xFF351F27);
  static const Color textSecondary = Color(0xFF7D646B);
  static const Color textHint = Color(0xFFAD949B);
  static const Color textWhite = Colors.white;

  // 5. الحدود (Clean & Minimal Borders)
  static const Color borderPrimary = Color(0xFFEBCDD5);
  static const Color borderSecondary = Color(0xFFD9B8C1);
  static const Color borderDark = Color(0xFF5A4048);

  // 6. ألوان الحالة (Modern Status Shades)
  static const Color error = Color(0xFFE11D48);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // 7. درجات الظلال والرمادي (Neutral Palette)
  // تم تعديل الرماديات لتكون بلمحة "Warm Grey" لتناسب لوحة الألوان الوردية
  static const Color black = Color(0xFF1A0F13);
  static const Color darkerGrey = Color(0xFF4A3A3F);
  static const Color darkGrey = Color(0xFF705C62);
  static const Color grey = Color(0xFF9E898F);
  static const Color softGrey = Color(0xFFF3EBED);
  static const Color lightGrey = Color(0xFFFAF5F6);
  static const Color dark = Color(0xFF1F1216);
  static const Color light = Color(0xFFFDF8F9);

  static const Color cardLight = lightContainer;
}

/*
class TColors {
  // 1. الألوان الأساسية (Modern Luxury Identity)
  // الأزرق الليلي هو "الأسود الجديد" في التصميم العصري
  static const Color primary = Color(0xFF0F172A);
  // لون النحاس المطفي أو الذهب الخافت للتمييز (Buttons, Active Icons)
  static const Color secondary = Color(0xFFC2A378);
  // لون "التيفاني الناعم" لإعطاء لمسة حيوية هادئة
  static const Color accent = Color(0xFF38BDF8);

  // 2. درجات الخلفيات (Clean & Spacious)
  static const Color white = Color(0xFFFFFFFF);
  // خلفية "الرمادي الثلجي" المريحة جداً للعين
  static const Color softWhite = Color(0xFFF8FAFC);
  // لون الحاويات في الوضع الفاتح
  static const Color lightContainer = Color(0xFFF1F5F9);
  // لون الحاويات في الوضع الداكن (Slate Blue Dark)
  static const Color darkContainer = Color(0xFF1E293B);
  static const Color borderLight = Color(
    0xFFE8E8E8,
  ); // حدود رقيقة جداً تكاد لا تُ
  // 3. الطابع الزجاجي (Advanced Glassmorphism)
  // استخدام شفافية الـ Blue-Grey تعطي عمقاً أكبر من الأبيض الصافي
  static Color glassBackground = const Color(0xFFF8FAFC).withOpacity(0.6);
  static Color glassBorder = const Color(0xFFE2E8F0).withOpacity(0.5);

  // 4. ألوان النصوص (Rich Typography)
  // بدلاً من الأسود الصافي، نستخدم Slate 900 لعمق بصري أفضل
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;

  // 5. الحدود (Clean & Minimal Borders)
  static const Color borderPrimary = Color(0xFFE2E8F0);
  static const Color borderSecondary = Color(0xFFCBD5E1);
  static const Color borderDark = Color(0xFFD1D1D1);

  // 6. ألوان الحالة (Modern Status Shades)
  // ألوان مشبعة قليلاً لتبدو حية على الخلفيات الداكنة والفاتحة
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  // 7. درجات الظلال والرمادي (Neutral Palette)
  static const Color black = Color(0xFF020617);
  static const Color darkerGrey = Color(0xFF334155);
  static const Color darkGrey = Color(0xFF475569);
  static const Color grey = Color(0xFF94A3B8);
  static const Color softGrey = Color(0xFFF1F5F9);
  static const Color lightGrey = Color(0xFFF8FAFC);
  static const Color dark = Color(0xFF0F172A);
  static const Color light = Color(0xFFF8FAFC);

  static const Color cardLight = lightContainer;
}
*/
/*
class TColors {
  // 1. الألوان الأساسية الهادئة (Neutral Brand Identity)
  static const Color primary = Color(
    0xFF2D2E32,
  ); // أسود فحمى هادئ للنصوص والعناصر الرئيسية
  static const Color secondary = Color(
    0xFFD4BDAC,
  ); // لون "لاتيه" ناعم (بيج دافئ) للتمييز
  static const Color accent = Color(0xFFE5D9CC); // لون سكري غامق قليلاً

  // 2. درجات الأبيض والسكري (The Clean Base)
  static const Color white = Color(0xFFFFFFFF);
  static const Color softWhite = Color(
    0xFFF9F8F6,
  ); // أبيض بلمسة سكرية (خلفية التطبيق الأساسية)
  static const Color cream = Color(0xFFF2EFE9); // لون كريمي للحاويات
  static const Color beige = Color(
    0xFFE8E2D9,
  ); // لون بيج فاتح جداً للحدود أو الظلال

  // 3. الطابع الزجاجي الاحترافي (High-End Glassmorphism)
  // السر في الشفافية العالية جداً مع ضبابية قوية
  static Color glassBackground = Colors.white.withOpacity(0.4);
  static Color glassBorder = Colors.white.withOpacity(0.5);
  static Color lightGlass = const Color(0xFFF2EFE9).withOpacity(0.3);

  // 4. ألوان النصوص (Minimalist Typography)
  static const Color textPrimary = Color(0xFF1A1A1A); // أسود شبه مطفي
  static const Color textSecondary = Color(
    0xFF7A7A7A,
  ); // رمادي حجري للنصوص الفرعية
  static const Color textHint = Color(0xFFA5A5A5); // للملاحظات الباهتة
  // 4. ألوان النصوص (Minimalist Typography)
  static const Color textWhite =
      Colors.white; // <--- هنا يوجد اللون الأبيض للنصوص
  // 5. الحاويات والبطاقات (Cards & Sections)
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardNeutral = Color(0xFFF5F5F5);
  // 5. الحاويات والبطاقات (Containers & Cards)
  static const Color lightContainer = Colors.white;
  static const Color darkContainer = Color(
    0xFF1E293B,
  ); // <--- هذا هو اللون المطلوب
  // 6. الحدود (Modern Minimal Borders)
  static const Color borderLight = Color(
    0xFFE8E8E8,
  ); // حدود رقيقة جداً تكاد لا تُرى
  static const Color borderDark = Color(0xFFD1D1D1);
  // 6. ألوان الحدود (Modern Minimal Borders)
  static const Color borderPrimary = Color(0xFFE8E8E8); // رمادي فاتح جداً ونظيف
  static const Color borderSecondary = Color(0xFFCBD5E1);
  // 7. ألوان الحالة (Soft Status Colors)
  // حتى ألوان الحالة جعلناها هادئة لتناسب التصميم
  static const Color error = Color(0xFFBC5A5A);
  static const Color success = Color(0xFF8BA889);
  static const Color warning = Color(0xFFD4A373);

  // 8. درجات الرمادي الحيادي (Neutral Shades)
  static const Color black = Color(
    0xFF1A1A1A,
  ); // الأسود الأساسي للنصوص والعناصر القوية
  static const Color darkerGrey = Color(0xFF334155);
  static const Color darkGrey = Color(0xFF475569);
  static const Color grey = Color(0xFF94A3B8);
  static const Color softGrey = Color(0xFFF1F5F9);
  static const Color lightGrey = Color(0xFFF8FAFC);
  static const Color dark = Color(0xFF0F172A);

  static const Color light = lightContainer;
}
*/

/*
class TColors {
  // 1. الألوان الأساسية للعلامة التجارية (Brand Identity)
  // تم اختيار درجات وردية مشبعة وعصرية (Vibrant Rose)
  static const Color primary = Color(0xFFF43F5E); // Rose 500 - عصري وجذاب
  static const Color secondary = Color(0xFFFF859B); // وردي فاتح للمسات الثانوية
  static const Color accent = Color(0xFFFB7185); // Rose 400

  // 2. ألوان الطابع الزجاجي (Glassmorphism Elements)
  // هذه الألوان تستخدم مع BackdropFilter لعمل تأثير الزجاج
  static Color glassBackground = Colors.white.withOpacity(0.6);
  static Color glassBorder = Colors.white.withOpacity(0.3);
  static Color glassShadow = const Color(0xFFF43F5E).withOpacity(0.1);

  // 3. ألوان النصوص (Typography)
  // نستخدم درجات Slate الغامقة جداً بدلاً من الأسود لراحة العين
  static const Color textPrimary = Color(0xFF1E1B4B); // كحلي وردي عميق جداً
  static const Color textSecondary = Color(0xFF64748B); // رمادي متوسط للشروحات
  static const Color textWhite = Colors.white;

  // 4. ألوان الخلفيات (Backgrounds)
  // الخلفية "Eggshell" المريحة (ليست بيضاء تماماً)
  static const Color light = Color(0xFFFAFAFA);
  static const Color dark = Color(0xFF0F172A); // كحلي عميق للـ Dark Mode
  static const Color primaryBackground = Color(
    0xFFFFF1F2,
  ); // خلفية وردية خفيييفة جداً

  // 5. الحاويات والبطاقات (Containers)
  static const Color lightContainer = Colors.white;
  static const Color darkContainer = Color(0xFF1E293B);

  // 6. ألوان الحدود (Borders)
  static const Color borderPrimary = Color(0xFFE2E8F0);
  static const Color borderSecondary = Color(0xFFFDA4AF); // حدود وردية فاتحة

  // 7. ألوان الحالة (Status)
  static const Color error = Color(0xFFE11D48);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0EA5E9);

  // 8. درجات الرمادي الحيادي (Neutral Shades)
  static const Color black = Color(0xFF000000);
  static const Color darkerGrey = Color(0xFF334155);
  static const Color darkGrey = Color(0xFF475569);
  static const Color grey = Color(0xFF94A3B8);
  static const Color softGrey = Color(0xFFF1F5F9);
  static const Color lightGrey = Color(0xFFF8FAFC);
}
*/
/*
class TColors {
  // App theme colors
  static const Color eggshell = Color(0xFFFCFCFC);
  static const Color cornsilk = Color(0xFFFFFAE3);
  static const Color brightPink = Color(0xFFF7567C);

  //static const Color primary = Color(0xFFFFE400);
  static const Color primary = brightPink;
  //static const Color secondary = Color(0xFF272727);
  static const Color secondary = cornsilk;
  static const Color secondaryLight = Color(0xC9346DAE);
  /*static const Color primaryBackground = Color(
    0xFFCCFBF1,
  ); // Primary Color Background*/
  static const Color primaryBackground = eggshell; // Prima
  /*static const Color secondaryBackground = Color(
    0xFFFFE4E6,
  ); // Secondary Color Background*/
  static const Color secondaryBackground = cornsilk;

  //static const Color accent = Color(0xFF001BFF);
  static const Color accent = brightPink;

  // Dashboard Specific Colors
  static const Color dashboardAppbarBackground = Color(0xFF4b68ff);

  // Text colors
  static const Color textPrimary = Color(
    0xFF222A3D,
  ); // Theme Nightingale Gray 80
  /*static const Color textSecondary = Color(
    0xFF4B5363,
  );*/
  static const Color textSecondary = brightPink; // Theme Nightingale Gray 60
  static const Color textDarkPrimary = Color(
    0xFFFFFFFF,
  ); // Theme Nightingale Gray White
  static const Color textDarkSecondary = Color(
    0xFFD1D5DB,
  ); // Theme Nightingale Gray 30
  static const Color textWhite = Colors.white;

  static const Color disabledTextLight = Color(
    0xFFD1D5DB,
  ); // Theme Nightingale Gray 30
  static const Color disabledBackgroundLight = Color(
    0xFFF3F4F6,
  ); // Theme Nightingale Gray ?

  static const Color disabledTextDark =
      textSecondary; // Theme Nightingale Gray 60
  static const Color disabledBackgroundDark = Color(
    0xFF222A3D,
  ); // Theme Nightingale Gray 80

  // Background colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(
    0xFF02040A,
  ); // Theme Nightingale Gray 100

  // Background Container colors
  /*static const Color lightContainer = Color(
    0xFFF3F4F6,
  ); // Theme Nightingale Gray 10*/
  static const Color lightContainer = eggshell;
  static const Color darkContainer = Color(
    0xFF13192B,
  ); // Theme Nightingale Gray 90
  static const Color cardBackgroundColor = Color(
    0xFFF7F5F1,
  ); // Theme Nightingale Gray 90

  // Button colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonDisabled = disabledBackgroundLight;

  // -- Social Button Colors
  static const Color googleBackgroundColor = Color(0xFFDFEFFF);
  static const Color googleForegroundColor = Color(0xFF167EE6);
  static const Color facebookBackgroundColor = Color(0xFF1877F2);

  // -- ON-BOARDING COLORS
  static const Color onBoardingPage1Color = Colors.white;
  static const Color onBoardingPage2Color = Color(0xfffddcdf);
  static const Color onBoardingPage3Color = Color(0xffffdcbd);

  // Icon colors
  static const Color iconPrimaryLight = Color(
    0xFF284C76,
  ); // Theme Nightingale Gray 80
  static const Color iconSecondaryLight = Color(
    0xFF9CA3AF,
  ); // Theme Nightingale Gray 40
  static const Color iconPrimaryDark = Color(
    0xFFFFFFFF,
  ); // Theme Nightingale Gray White
  static const Color iconSecondaryDark = Color(
    0xFF9CA3AF,
  ); // Theme Nightingale Gray 40

  // Border colors
  static const Color borderPrimary = primary;
  static const Color borderSecondary = secondary;
  static const Color borderLight = Color(0xFFD1D5DB); // Gray 30
  static const Color borderDark = Color(0xFF9CA3AF); // Gray 40

  // Error and validation colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color teal90 = Color(0xFF004D40);
  static const Color teal80 = Color(0xFF00695C);
  static const Color teal20 = Color(0xFF99F6E4);
  static const Color dark = Color(0xff272727);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color grey10 = Color(0xFFF3F4F6);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color light = Color(0xFFF6F6F6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color red = Color(0xfff43F5E);

  static const Color softWhite = Color(0xFFF9F8F6);
}
*/
