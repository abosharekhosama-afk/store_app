import 'package:flutter/material.dart';

class TColorMap {
  // القاموس الشامل المدمج (قائمتك التفصيلية + الإضافات الفرعية)
  static const Map<String, Color> _baseColors = {
    // --- الرماديات والأبيض والأسود ---
    'اسود': Color(0xFF000000), 'black': Color(0xFF000000),
    'ابيض': Color(0xFFFFFFFF), 'white': Color(0xFFFFFFFF),
    'رمادي': Color(0xFF808080),
    'gray': Color(0xFF808080),
    'grey': Color(0xFF808080),
    'فضي': Color(0xFFC0C0C0), 'silver': Color(0xFFC0C0C0),
    'darkgrey': Color(0xFFA9A9A9), 'lightgrey': Color(0xFFD3D3D3),
    'whitesmoke': Color(0xFFF5F5F5), 'gainsboro': Color(0xFFDCDCDC),
    'فحمي': Color(0xFF36454F), 'charcoal': Color(0xFF36454F),
    'سكني': Color(0xFF708090), 'slate': Color(0xFF708090),
    'اوف وايت': Color(0xFFFDFBF7), 'offwhite': Color(0xFFFDFBF7),

    // --- تدرجات الأحمر ---
    'احمر': Color(0xFFFF0000), 'red': Color(0xFFFF0000),
    'darkred': Color(0xFF8B0000),
    'قرمزي': Color(0xFFDC143C), 'crimson': Color(0xFFDC143C),
    'طوبي': Color(0xFFB22222), 'firebrick': Color(0xFFB22222),
    'خمري': Color(0xFF800000), 'maroon': Color(0xFF800000),
    'tomato': Color(0xFFFF6347), 'indianred': Color(0xFFCD5C5C),
    'bloodred': Color(0xFF660000),
    'ياقوتي': Color(0xFFE0115F), 'ruby': Color(0xFFE0115F),
    'رماني': Color(0xFF9B111E),

    // --- تدرجات الأزرق ---
    'ازرق': Color(0xFF0000FF), 'blue': Color(0xFF0000FF),
    'كحلي': Color(0xFF000080), 'navy': Color(0xFF000080),
    'ملكي': Color(0xFF4169E1), 'royalblue': Color(0xFF4169E1),
    'سماوي': Color(0xFF87CEEB), 'skyblue': Color(0xFF87CEEB),
    'سيان': Color(0xFF00FFFF), 'cyan': Color(0xFF00FFFF),
    'جنزاري': Color(0xFF008080), 'teal': Color(0xFF008080),
    'فيروزي': Color(0xFF40E0D0), 'turquoise': Color(0xFF40E0D0),
    'azure': Color(0xFFF0FFFF), 'aliceblue': Color(0xFFF0F8FF),
    'حبري': Color(0xFF191970), 'midnightblue': Color(0xFF191970),

    // --- تدرجات الأخضر ---
    'اخضر': Color(0xFF008000), 'green': Color(0xFF008000),
    'ليموني': Color(0xFF00FF00), 'lime': Color(0xFF00FF00),
    'forestgreen': Color(0xFF228B22),
    'زيتوني': Color(0xFF808000), 'olive': Color(0xFF808000),
    'زمردي': Color(0xFF50C878), 'emerald': Color(0xFF50C878),
    'springgreen': Color(0xFF00FF7F), 'seagreen': Color(0xFF2E8B57),
    'فستقي': Color(0xFF93C572), 'pistachio': Color(0xFF93C572),

    // --- تدرجات الأصفر والبرتقالي ---
    'اصفر': Color(0xFFFFFF00), 'yellow': Color(0xFFFFFF00),
    'ذهبي': Color(0xFFFFD700), 'gold': Color(0xFFFFD700),
    'برتقالي': Color(0xFFFFA500), 'orange': Color(0xFFFFA500),
    'كهرماني': Color(0xFFFFBF00), 'amber': Color(0xFFFFBF00),
    'مرجاني': Color(0xFFFF7F50), 'coral': Color(0xFFFF7F50),
    'خوخي': Color(0xFFFFDAB9), 'peach': Color(0xFFFFDAB9),
    'خردلي': Color(0xFFFFDB58), 'mustard': Color(0xFFFFDB58),

    // --- تدرجات البني والبيج ---
    'بني': Color(0xFFA52A2A), 'brown': Color(0xFFA52A2A),
    'شوكولاتة': Color(0xFFD2691E), 'chocolate': Color(0xFFD2691E),
    'بيج': Color(0xFFF5F5DC), 'beige': Color(0xFFF5F5DC),
    'قهوة': Color(0xFF6F4E37), 'coffee': Color(0xFF6F4E37),
    'نحاسي': Color(0xFFD2B48C), 'tan': Color(0xFFD2B48C),
    'كاكي': Color(0xFFF0E68C), 'khaki': Color(0xFFF0E68C),
    'عاجي': Color(0xFFFFFFF0), 'ivory': Color(0xFFFFFFF0),
    'كريمي': Color(0xFFFFFDD0),

    // --- تدرجات الوردي والبنفسجي ---
    'وردي': Color(0xFFFFC0CB),
    'زهري': Color(0xFFFFC0CB),
    'pink': Color(0xFFFFC0CB),
    'hotpink': Color(0xFFFF69B4),
    'فوشي': Color(0xFFFF00FF),
    'fuchsia': Color(0xFFFF00FF),
    'magenta': Color(0xFFFF00FF),
    'بنفسجي': Color(0xFF800080), 'purple': Color(0xFF800080),
    'ليلكي': Color(0xFFEE82EE), 'violet': Color(0xFFEE82EE),
    'خزامى': Color(0xFFE6E6FA), 'lavender': Color(0xFFE6E6FA),
    'برقوقي': Color(0xFFDDA0DD), 'plum': Color(0xFFDDA0DD),
    'قرنفلي': Color(0xFFE6A8D7),

    // --- ألوان إضافية مخصصة ---
    'برونزي': Color(0xFFCD7F32), 'bronze': Color(0xFFCD7F32),
    'ميتاليك': Color(0xFFA8A9AD), 'metallic': Color(0xFFA8A9AD),
  };

  /// الدالة الرئيسية القياسية المستدعاة في الـ ChoiceChip

  /// الدالة الرئيسية الصارمة: لا تُرجع لوناً إلا إذا كان لوناً حقيقياً معتمداً ومؤكداً
  static Color? getColor(String value) {
    if (value.trim().isEmpty) return null;
    String cleanValue = value.trim().toLowerCase();

    // 1. فحص كود الهيكسا المباشر (مثل: #FFFFFF أو FF0000)
    // إذا كان كود هيكسا صحيح برمجياً، نُعيد اللون فوراً
    final Color? directColor = _parseDirectHex(cleanValue);
    if (directColor != null) return directColor;

    // 2. معالجة وتوحيد النص العربي (حذف الهمزات والتاء المربوطة وال التعريف)
    cleanValue = _normalizeArabic(cleanValue);

    // 3. مطابقة تامة وصارمة مع قاموس الألوان المعتمد لديك (_baseColors)
    if (_baseColors.containsKey(cleanValue)) {
      return _baseColors[cleanValue];
    }

    // 4. بديل متطور (فقط إذا كنت تستخدم الصفات المركبة مثل "فاتح" و "غامق"):
    // نتحقق أولاً: هل النص يحتوي على أي كلمة مفتاحية للون معتمد؟ (مثل "أزرق"، "أحمر"، "blue")
    bool containsKnownColorKeyword = _baseColors.keys.any(
      (colorName) => cleanValue.contains(colorName),
    );

    if (containsKnownColorKeyword) {
      return _generateDynamicColor(
        cleanValue,
      ); // تشغيل المحرك فقط للألوان المركبة المؤكدة
    }
    // 4. 🌟 [التعديل الجوهري والأمان الكامل]:
    // إذا لم تكن القيمة كود Hex، ولم تكن موجودة في قاموس الألوان المعتمد،
    // نرفضها تماماً ونُرجع null، مع إيقاف المحرك الديناميكي اللانهائي عن معالجة النصوص العادية والمقاسات.
    return null;
  }

  /*
  static Color? getColor(String value) {
    if (value.trim().isEmpty) return null;
    String cleanValue = value.trim().toLowerCase();

    // 1. فحص كود الهيكسا المباشر
    final Color? directColor = _parseDirectHex(cleanValue);
    if (directColor != null) return directColor;

    // 2. معالجة وتوحيد النص العربي (حذف الهمزات والتاء المربوطة وال التعريف)
    cleanValue = _normalizeArabic(cleanValue);

    // 3. مطابقة تامة ومباشرة من القاموس الضخم الجديد
    if (_baseColors.containsKey(cleanValue)) return _baseColors[cleanValue];

    // 4. الانتقال للمحرك الديناميكي اللانهائي في حال وجود صفات مركبة
    return _generateDynamicColor(cleanValue);
  }
*/
  /// محرك التعديل اللانهائي لحساب مئات التراكيب بالوقت الفعلي
  static Color _generateDynamicColor(String text) {
    Color foundBaseColor = const Color(0xFF808080); // البديل الافتراضي
    bool isMatched = false;

    // العثور على أطول كلمة مفتاحية متطابقة لمنع التداخل (مثل تمييز 'darkgrey' عن 'grey')
    String bestMatchKey = '';
    for (var key in _baseColors.keys) {
      if (text.contains(key) && key.length > bestMatchKey.length) {
        bestMatchKey = key;
        foundBaseColor = _baseColors[key]!;
        isMatched = true;
      }
    }

    // إذا لم يطابق أي كلمة في القاموس، يتم إنتاج لون ثابت فريد من الـ Hash للحروف
    if (!isMatched) {
      return _generateFallbackColorFromString(text);
    }

    int r = foundBaseColor.red;
    int g = foundBaseColor.green;
    int b = foundBaseColor.blue;

    // معالجة الصفات وتعديل قيم الـ RGB رياضياً
    if (text.contains('فاتح') ||
        text.contains('ناصع') ||
        text.contains('light')) {
      r = (r + (255 - r) * 0.35).round().clamp(0, 255);
      g = (g + (255 - g) * 0.35).round().clamp(0, 255);
      b = (b + (255 - b) * 0.35).round().clamp(0, 255);
    } else if (text.contains('غامق') ||
        text.contains('داكن') ||
        text.contains('محروق') ||
        text.contains('dark')) {
      r = (r * 0.65).round().clamp(0, 255);
      g = (g * 0.65).round().clamp(0, 255);
      b = (b * 0.65).round().clamp(0, 255);
    } else if (text.contains('ميتاليك') || text.contains('metallic')) {
      r = ((r + 192) / 2).round().clamp(0, 255);
      g = ((g + 192) / 2).round().clamp(0, 255);
      b = ((b + 192) / 2).round().clamp(0, 255);
    } else if (text.contains('مطفأ') || text.contains('ماط')) {
      r = (r * 0.82).round().clamp(0, 255);
      g = (g * 0.82).round().clamp(0, 255);
      b = (b * 0.82).round().clamp(0, 255);
    }

    // حساب تدرج الأرقام الديناميكي (مثل: جنزاري درجة 4)
    final RegExp numRegex = RegExp(r'\d+');
    final Match? match = numRegex.firstMatch(text);
    if (match != null) {
      int level = int.parse(match.group(0)!);
      double factor = (level.clamp(1, 20) * 4) / 100;
      if (level % 2 == 0) {
        r = (r * (1 - factor)).round().clamp(0, 255);
        g = (g * (1 - factor)).round().clamp(0, 255);
        b = (b * (1 - factor)).round().clamp(0, 255);
      } else {
        r = (r + (255 - r) * factor).round().clamp(0, 255);
        g = (g + (255 - g) * factor).round().clamp(0, 255).round();
        b = (b + (255 - b) * factor).round().clamp(0, 255).round();
      }
    }

    return Color.fromARGB(255, r, g, b);
  }

  /// دالة الحماية لمنع الـ Null وتوليد لَوْن ثابت اعتماداً على الحروف المجهولة
  static Color _generateFallbackColorFromString(String text) {
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final int r = (hash & 0xFF0000) >> 16;
    final int g = (hash & 0x00FF00) >> 8;
    final int b = hash & 0x0000FF;
    return Color.fromARGB(
      255,
      r.clamp(40, 210),
      g.clamp(40, 210),
      b.clamp(40, 210),
    );
  }

  static Color? _parseDirectHex(String hexColorString) {
    try {
      String hex = hexColorString.replaceAll('#', '').trim();
      if (hex.startsWith('0x')) hex = hex.substring(2);
      if (hex.length == 6) hex = 'FF$hex';
      if (hex.length == 8) return Color(int.parse('0x$hex'));
    } catch (_) {}
    return null;
  }

  static String _normalizeArabic(String text) {
    String result = text.trim().toLowerCase();
    if (result.startsWith("ال")) result = result.substring(2);
    result = result.replaceAll(RegExp(r'[أإآ]'), 'ا');
    result = result.replaceAll('ة', 'ه');
    return result;
  }
}







/*
class TColorMap {
  // القاموس المطور الشامل للألوان الجوهرية والدرجات الدارجة في السوق العربي والعالمي
  static const Map<String, Color> _baseColors = {
    // --- الألوان الأساسية القياسية ---
    'اسود': Color(0xFF000000),
    'أسود': Color(0xFF000000),
    'black': Color(0xFF000000),
    'ابيض': Color(0xFFFFFFFF),
    'أبيض': Color(0xFFFFFFFF),
    'white': Color(0xFFFFFFFF),
    'رمادي': Color(0xFF808080),
    'سكني': Color(0xFF708090),
    'رصاصي': Color(0xFF7F8C8D),
    'grey': Color(0xFF808080),
    'فضي': Color(0xFFC0C0C0), 'silver': Color(0xFFC0C0C0),
    'احمر': Color(0xFFFF0000),
    'أحمر': Color(0xFFFF0000),
    'red': Color(0xFFFF0000),
    'ازرق': Color(0xFF0000FF),
    'أزرق': Color(0xFF0000FF),
    'blue': Color(0xFF0000FF),
    'اخضر': Color(0xFF008000),
    'أخضر': Color(0xFF008000),
    'green': Color(0xFF008000),
    'اصفر': Color(0xFFFFFF00),
    'أصفر': Color(0xFFFFFF00),
    'yellow': Color(0xFFFFFF00),
    'برتقالي': Color(0xFFFFA500), 'orange': Color(0xFFFFA500),
    'بني': Color(0xFFA52A2A), 'brown': Color(0xFFA52A2A),
    'بيج': Color(0xFFF5F5DC), 'beige': Color(0xFFF5F5DC),
    'بنفسجي': Color(0xFF800080), 'purple': Color(0xFF800080),
    'وردي': Color(0xFFFFC0CB),
    'زهري': Color(0xFFFFC0CB),
    'pink': Color(0xFFFFC0CB),
    'ذهبي': Color(0xFFFFD700), 'gold': Color(0xFFFFD700),
    'كحلي': Color(0xFF000080), 'navy': Color(0xFF000080),
    'فيروزي': Color(0xFF40E0D0), 'turquoise': Color(0xFF40E0D0),

    // ✨ تم إضافة الألوان الفرعية والدارجة التي طلبتها لضمان دقة 100% ✨
    'قرنفلي': Color(0xFFE6A8D7), // لون زهرة القرنفل الجذاب
    'رماني': Color(
      0xFF9B111E,
    ), // اللون الرماني (الأحمر الداكن المستوحى من الرمان)
    'اوف وايت': Color(0xFFFDFBF7), // أوف وايت ناعم ومثالي للدهانات والمطابخ
    'اوفوايت': Color(0xFFFDFBF7),
    'offwhite': Color(0xFFFDFBF7),
    'خمري': Color(0xFF800000),
    'طوبي': Color(0xFFB22222),
    'عسلي': Color(0xFFCD7F32),
    'خردلي': Color(0xFFFFDB58),
    'فستقي': Color(0xFF93C572),
    'سماوي': Color(0xFF87CEEB),
    'كريمي': Color(0xFFFFFDD0),
  };

  /// الدالة الرئيسية المربوطة بالـ TChoiceChip
  static Color? getColor(String value) {
    if (value.trim().isEmpty) return null;
    String cleanValue = value.trim().toLowerCase();

    // 1. فك تشفر الـ Hex المباشر إن وجد
    final Color? directColor = _parseDirectHex(cleanValue);
    if (directColor != null) return directColor;

    // 2. تنظيف العبارة من ال التعريف والهمزات
    cleanValue = _normalizeArabic(cleanValue);

    // 3. مطابقة مباشرة إذا كان النص هو الكلمة نفسها تماماً
    if (_baseColors.containsKey(cleanValue)) return _baseColors[cleanValue];

    // 4. تشغيل محرك التعديل اللانهائي للألوان المركبة والصفات والأرقام
    return _generateDynamicColor(cleanValue);
  }

  /// المحرك الذكي لتعديل الـ RGB وحساب التدرجات لأي لون مركب
  static Color _generateDynamicColor(String text) {
    Color foundBaseColor = const Color(
      0xFF808080,
    ); // لون افتراضي (رمادي) في حال عدم مطابقة أي كلمة
    bool isMatched = false;

    // البحث عن الجذر اللوني داخل النص
    for (var key in _baseColors.keys) {
      if (text.contains(key)) {
        foundBaseColor = _baseColors[key]!;
        isMatched = true;
        break;
      }
    }

    // [حزام الأمان] - إذا لم يعثر على الكلمة نهائياً (مثلاً لون مخترع أو غير مسجل)
    // يقوم المحرك بتوليد لون ثابت وفريد معتمد على القيمة الرقمية للحروف (Hash) لكي لا يظهر مربع شفاف!
    if (!isMatched) {
      return _generateFallbackColorFromString(text);
    }

    int r = foundBaseColor.red;
    int g = foundBaseColor.green;
    int b = foundBaseColor.blue;

    // تطبيق التعديلات اللانهائية بناءً على الصفات المصاحبة للون
    if (text.contains('فاتح') || text.contains('ناصع')) {
      r = (r + (255 - r) * 0.35).round().clamp(0, 255);
      g = (g + (255 - g) * 0.35).round().clamp(0, 255);
      b = (b + (255 - b) * 0.35).round().clamp(0, 255);
    } else if (text.contains('غامق') ||
        text.contains('داكن') ||
        text.contains('محروق')) {
      r = (r * 0.65).round().clamp(0, 255);
      g = (g * 0.65).round().clamp(0, 255);
      b = (b * 0.65).round().clamp(0, 255);
    } else if (text.contains('ميتاليك')) {
      r = ((r + 192) / 2).round().clamp(0, 255);
      g = ((g + 192) / 2).round().clamp(0, 255);
      b = ((b + 192) / 2).round().clamp(0, 255);
    } else if (text.contains('مطفأ') || text.contains('ماط')) {
      r = (r * 0.82).round().clamp(0, 255);
      g = (g * 0.82).round().clamp(0, 255);
      b = (b * 0.82).round().clamp(0, 255);
    }

    // معالجة الترقيم الديناميكي (مثال: رماني درجة 3)
    final RegExp numRegex = RegExp(r'\d+');
    final Match? match = numRegex.firstMatch(text);
    if (match != null) {
      int level = int.parse(match.group(0)!);
      double factor = (level.clamp(1, 20) * 4) / 100;
      if (level % 2 == 0) {
        r = (r * (1 - factor)).round().clamp(0, 255);
        g = (g * (1 - factor)).round().clamp(0, 255);
        b = (b * (1 - factor)).round().clamp(0, 255);
      } else {
        r = (r + (255 - r) * factor).round().clamp(0, 255);
        g = (g + (255 - g) * factor).clamp(0, 255).round();
        b = (b + (255 - b) * factor).clamp(0, 255).round();
      }
    }

    return Color.fromARGB(255, r, g, b);
  }

  /// توليد لون فريد وتلقائي من الحروف (Fallback) لمنع الـ Null تماماً في التطبيق
  static Color _generateFallbackColorFromString(String text) {
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final int r = (hash & 0xFF0000) >> 16;
    final int g = (hash & 0x00FF00) >> 8;
    final int b = hash & 0x0000FF;
    return Color.fromARGB(
      255,
      r.clamp(30, 220),
      g.clamp(30, 220),
      b.clamp(30, 220),
    );
  }

  static Color? _parseDirectHex(String hexColorString) {
    try {
      String hex = hexColorString.replaceAll('#', '').trim();
      if (hex.startsWith('0x')) hex = hex.substring(2);
      if (hex.length == 6) hex = 'FF$hex';
      if (hex.length == 8) return Color(int.parse('0x$hex'));
    } catch (_) {}
    return null;
  }

  static String _normalizeArabic(String text) {
    String result = text.trim().toLowerCase();
    if (result.startsWith("ال")) result = result.substring(2);
    result = result.replaceAll(RegExp(r'[أإآ]'), 'ا');
    result = result.replaceAll('ة', 'ه');
    return result;
  }
}
*/




/*
class TColorMap {
  // 1. القاموس الأساسي للألوان الجوهرية في العالم (الروافد الأساسية)
  static const Map<String, Color> _baseColors = {
    'اسود': Color(0xFF000000),
    'أسود': Color(0xFF000000),
    'black': Color(0xFF000000),
    'ابيض': Color(0xFFFFFFFF),
    'أبيض': Color(0xFFFFFFFF),
    'white': Color(0xFFFFFFFF),
    'رمادي': Color(0xFF808080),
    'سكني': Color(0xFF708090),
    'grey': Color(0xFF808080),
    'gray': Color(0xFF808080),
    'فضي': Color(0xFFC0C0C0),
    'silver': Color(0xFFC0C0C0),
    'احمر': Color(0xFFFF0000),
    'أحمر': Color(0xFFFF0000),
    'red': Color(0xFFFF0000),
    'ازرق': Color(0xFF0000FF),
    'أزرق': Color(0xFF0000FF),
    'blue': Color(0xFF0000FF),
    'اخضر': Color(0xFF008000),
    'أخضر': Color(0xFF008000),
    'green': Color(0xFF008000),
    'اصفر': Color(0xFFFFFF00),
    'أصفر': Color(0xFFFFFF00),
    'yellow': Color(0xFFFFFF00),
    'برتقالي': Color(0xFFFFA500),
    'orange': Color(0xFFFFA500),
    'بني': Color(0xFFA52A2A),
    'brown': Color(0xFFA52A2A),
    'بيج': Color(0xFFF5F5DC),
    'beige': Color(0xFFF5F5DC),
    'بنفسجي': Color(0xFF800080),
    'purple': Color(0xFF800080),
    'وردي': Color(0xFFFFC0CB),
    'زهري': Color(0xFFFFC0CB),
    'pink': Color(0xFFFFC0CB),
    'ذهبي': Color(0xFFFFD700),
    'gold': Color(0xFFFFD700),
    'كحلي': Color(0xFF000080),
    'navy': Color(0xFF000080),
    'فيروزي': Color(0xFF40E0D0),
    'turquoise': Color(0xFF40E0D0),
  };

  /// الدالة الرئيسية التي يستدعيها الـ TChoiceChip لديك
  static Color? getColor(String value) {
    if (value.trim().isEmpty) return null;
    String cleanValue = value.trim().toLowerCase();

    // أولاً: إذا كان النص عبارة عن كود Hex مباشر (مثال: #FF5733) نقوم بفك شفرته فوراً
    final Color? directColor = _parseDirectHex(cleanValue);
    if (directColor != null) return directColor;

    // ثانياً: تنظيف النص من ال التعريف والهمزات لتسهيل المطابقة الذكية
    cleanValue = _normalizeArabic(cleanValue);

    // ثالثاً: البحث إذا كان اللون أساسياً وموجوداً بشكل مباشر في القاموس
    if (_baseColors.containsKey(cleanValue)) return _baseColors[cleanValue];

    // رابعاً: [المحرك الديناميكي اللانهائي] - تفكيك مسميات الألوان المركبة
    return _generateDynamicColor(cleanValue);
  }

  /// محرك التعديل الرياضي لإنتاج آلاف الدرجات لونيّاً بالوقت الفعلي (On the fly)
  static Color? _generateDynamicColor(String text) {
    Color? foundBaseColor;
    String matchedKey = '';

    // 1. العثور على اللون الأساسي داخل الجملة (مثال: "أحمر" داخل جملة "أحمر ميتاليك فاتح")
    for (var key in _baseColors.keys) {
      if (text.contains(key)) {
        foundBaseColor = _baseColors[key];
        matchedKey = key;
        break;
      }
    }

    if (foundBaseColor == null) return null;

    // استخراج مكونات اللون الأساسي RGB
    int r = foundBaseColor.red;
    int g = foundBaseColor.green;
    int b = foundBaseColor.blue;

    // 2. فحص الصفات وتعديل قيم RGB رياضياً لإنتاج الدرجة المطلوبة فوراً
    if (text.contains('فاتح') || text.contains('سماوي')) {
      r = (r + (255 - r) * 0.4).round().clamp(0, 255);
      g = (g + (255 - g) * 0.4).round().clamp(0, 255);
      b = (b + (255 - b) * 0.4).round().clamp(0, 255);
    } else if (text.contains('غامق') ||
        text.contains('داكن') ||
        text.contains('محروق')) {
      r = (r * 0.6).round().clamp(0, 255);
      g = (g * 0.6).round().clamp(0, 255);
      b = (b * 0.6).round().clamp(0, 255);
    } else if (text.contains('ميتاليك') || text.contains('فضي')) {
      // إضافة مسحة رمادية فضية ميتاليك ممتازة لمجال الألمنيوم والمطابخ
      r = ((r + 192) / 2).round().clamp(0, 255);
      g = ((g + 192) / 2).round().clamp(0, 255);
      b = ((b + 192) / 2).round().clamp(0, 255);
    } else if (text.contains('مطفأ') ||
        text.contains('ماط') ||
        text.contains('خشن')) {
      // تقليل السطوع قليلاً ليعطي انطباع اللون المطفي (Matte)
      r = (r * 0.8).round().clamp(0, 255);
      g = (g * 0.8).round().clamp(0, 255);
      b = (b * 0.8).round().clamp(0, 255);
    } else if (text.contains('ملكي') || text.contains('فاقع')) {
      // زيادة تركيز اللون وتشبيعه
      r = (r == 0) ? 0 : (r + 30).clamp(0, 255);
      g = (g == 0) ? 0 : (g + 30).clamp(0, 255);
      b = (b == 0) ? 0 : (b + 30).clamp(0, 255);
    }

    // 3. دعم أرقام التدرجات (مثال: "بيج درجة 5" أو "أخضر 12")
    // يقوم السكربت بالتقاط الرقم وتعديل اللون بناءً على قيمته رياضياً!
    final RegExp numRegex = RegExp(r'\d+');
    final Match? match = numRegex.firstMatch(text);
    if (match != null) {
      int level = int.parse(match.group(0)!);
      double factor = (level.clamp(1, 100) * 2.5) / 100; // تحجيم التأثير

      if (level % 2 == 0) {
        r = (r * (1 - factor)).round().clamp(0, 255);
        g = (g * (1 - factor)).round().clamp(0, 255);
        b = (b * (1 - factor)).round().clamp(0, 255);
      } else {
        r = (r + (255 - r) * factor).round().clamp(0, 255);
        g = (g + (255 - g) * factor).round().clamp(0, 255);
        b = (b + (255 - b) * factor).round().clamp(0, 255);
      }
    }

    return Color.fromARGB(255, r, g, b);
  }

  /// تحويل نصوص الـ Hex إلى كائن Color حقيقي
  static Color? _parseDirectHex(String hexColorString) {
    try {
      String hex = hexColorString.replaceAll('#', '').trim();
      if (hex.startsWith('0x')) hex = hex.substring(2);
      if (hex.length == 6) hex = 'FF$hex';
      if (hex.length == 8) return Color(int.parse('0x$hex'));
    } catch (_) {}
    return null;
  }

  /// تنظيف النصوص العربية
  static String _normalizeArabic(String text) {
    String result = text.trim().toLowerCase();
    if (result.startsWith("ال")) result = result.substring(2);
    result = result.replaceAll(RegExp(r'[أإآ]'), 'ا');
    result = result.replaceAll('ة', 'ه');
    return result;
  }
}
*/


/*
class TColorMap {
  static Color? getColor(String value) {
    final String colorValue = value.trim().toLowerCase();

    final Map<String, Color> colorMap = {
      // --- الرماديات والأبيض والأسود (50+ لون) ---
      'black': const Color(0xFF000000),
      'اسود': const Color(0xFF000000),
      'أسود': const Color(0xFF000000),
      'white': const Color(0xFFFFFFFF),
      'ابيض': const Color(0xFFFFFFFF),
      'أبيض': const Color(0xFFFFFFFF),
      'grey': const Color(0xFF808080),
      'gray': const Color(0xFF808080),
      'رمادي': const Color(0xFF808080),
      'silver': const Color(0xFFC0C0C0), 'فضي': const Color(0xFFC0C0C0),
      'darkgrey': const Color(0xFFA9A9A9), 'lightgrey': const Color(0xFFD3D3D3),
      'whitesmoke': const Color(0xFFF5F5F5),
      'gainsboro': const Color(0xFFDCDCDC),
      'charcoal': const Color(0xFF36454F), 'فحمي': const Color(0xFF36454F),
      'slate': const Color(0xFF708090), 'سكني': const Color(0xFF708090),

      // --- تدرجات الأحمر (Reds) ---
      'red': const Color(0xFFFF0000),
      'احمر': const Color(0xFFFF0000),
      'أحمر': const Color(0xFFFF0000),
      'darkred': const Color(0xFF8B0000),
      'crimson': const Color(0xFFDC143C),
      'قرمزي': const Color(0xFFDC143C),
      'firebrick': const Color(0xFFB22222), 'طوبي': const Color(0xFFB22222),
      'maroon': const Color(0xFF800000), 'خمري': const Color(0xFF800000),
      'tomato': const Color(0xFFFF6347), 'indianred': const Color(0xFFCD5C5C),
      'bloodred': const Color(0xFF660000),
      'ruby': const Color(0xFFE0115F),
      'ياقوتي': const Color(0xFFE0115F),

      // --- تدرجات الأزرق (Blues) ---
      'blue': const Color(0xFF0000FF),
      'ازرق': const Color(0xFF0000FF),
      'أزرق': const Color(0xFF0000FF),
      'navy': const Color(0xFF000080), 'كحلي': const Color(0xFF000080),
      'royalblue': const Color(0xFF4169E1), 'ملكي': const Color(0xFF4169E1),
      'skyblue': const Color(0xFF87CEEB), 'سماوي': const Color(0xFF87CEEB),
      'cyan': const Color(0xFF00FFFF), 'سيان': const Color(0xFF00FFFF),
      'teal': const Color(0xFF008080), 'جنزاري': const Color(0xFF008080),
      'turquoise': const Color(0xFF40E0D0), 'فيروزي': const Color(0xFF40E0D0),
      'azure': const Color(0xFFF0FFFF), 'aliceblue': const Color(0xFFF0F8FF),
      'midnightblue': const Color(0xFF191970), 'حبري': const Color(0xFF191970),

      // --- تدرجات الأخضر (Greens) ---
      'green': const Color(0xFF008000),
      'اخضر': const Color(0xFF008000),
      'أخضر': const Color(0xFF008000),
      'lime': const Color(0xFF00FF00), 'ليموني': const Color(0xFF00FF00),
      'forestgreen': const Color(0xFF228B22),
      'olive': const Color(0xFF808000),
      'زيتوني': const Color(0xFF808000),
      'emerald': const Color(0xFF50C878), 'زمردي': const Color(0xFF50C878),
      'springgreen': const Color(0xFF00FF7F),
      'seagreen': const Color(0xFF2E8B57),
      'pistachio': const Color(0xFF93C572), 'فستقي': const Color(0xFF93C572),

      // --- تدرجات الأصفر والبرتقالي (Yellows & Oranges) ---
      'yellow': const Color(0xFFFFFF00),
      'اصفر': const Color(0xFFFFFF00),
      'أصفر': const Color(0xFFFFFF00),
      'gold': const Color(0xFFFFD700), 'ذهبي': const Color(0xFFFFD700),
      'orange': const Color(0xFFFFA500), 'برتقالي': const Color(0xFFFFA500),
      'amber': const Color(0xFFFFBF00), 'كهرماني': const Color(0xFFFFBF00),
      'coral': const Color(0xFFFF7F50), 'مرجاني': const Color(0xFFFF7F50),
      'peach': const Color(0xFFFFDAB9), 'خوخي': const Color(0xFFFFDAB9),
      'mustard': const Color(0xFFFFDB58), 'خردلي': const Color(0xFFFFDB58),

      // --- تدرجات البني والبيج (Browns & Tan) ---
      'brown': const Color(0xFFA52A2A), 'بني': const Color(0xFFA52A2A),
      'chocolate': const Color(0xFFD2691E), 'شوكولاتة': const Color(0xFFD2691E),
      'beige': const Color(0xFFF5F5DC), 'بيج': const Color(0xFFF5F5DC),
      'coffee': const Color(0xFF6F4E37), 'قهوة': const Color(0xFF6F4E37),
      'tan': const Color(0xFFD2B48C), 'نحاسي': const Color(0xFFD2B48C),
      'khaki': const Color(0xFFF0E68C), 'كاكي': const Color(0xFFF0E68C),
      'ivory': const Color(0xFFFFFFF0), 'عاجي': const Color(0xFFFFFFF0),

      // --- تدرجات الوردي والبنفسجي (Pinks & Purples) ---
      'pink': const Color(0xFFFFC0CB),
      'وردي': const Color(0xFFFFC0CB),
      'زهري': const Color(0xFFFFC0CB),
      'hotpink': const Color(0xFFFF69B4),
      'fuchsia': const Color(0xFFFF00FF),
      'فوشي': const Color(0xFFFF00FF),
      'purple': const Color(0xFF800080), 'بنفسجي': const Color(0xFF800080),
      'violet': const Color(0xFFEE82EE), 'ليلكي': const Color(0xFFEE82EE),
      'magenta': const Color(0xFFFF00FF),
      'lavender': const Color(0xFFE6E6FA),
      'خزامى': const Color(0xFFE6E6FA),
      'plum': const Color(0xFFDDA0DD), 'برقوقي': const Color(0xFFDDA0DD),

      // --- ألوان إضافية مخصصة ---
      'bronze': const Color(0xFFCD7F32), 'برونزي': const Color(0xFFCD7F32),
      'metallic': const Color(0xFFA8A9AD), 'ميتاليك': const Color(0xFFA8A9AD),
    };

    // 1. البحث في الخريطة
    if (colorMap.containsKey(colorValue)) return colorMap[colorValue];

    // 2. معالج الـ Hex Code (لأي لون غير موجود في الماب)
    try {
      String hex = colorValue.replaceAll('#', '').trim();
      if (hex.startsWith('0x')) hex = hex.substring(2);
      if (hex.length == 6) hex = 'FF$hex';
      if (hex.length == 8) return Color(int.parse('0x$hex'));
    } catch (e) {
      return null;
    }

    return null;
  }
}
*/