import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/custom_shapes/containers/cirular_container.dart';
import 'package:untitled2_ecom/features/shop/controllers/TColorPreviewController.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/helpers/color_map.dart';

class TChoiceChip extends StatelessWidget {
  const TChoiceChip({
    super.key,
    required this.text,
    required this.selected,
    this.onSelected,
    this.color,
  });

  final String text;
  final bool selected;
  final Color? color;
  final void Function(bool)? onSelected;

  @override
  Widget build(BuildContext context) {
    // حقن الكنترولر بأسلوب GetX الذكي (يجلب الكنترولر إن كان موجوداً أو ينشئه)
    final controller = Get.put(TColorPreviewController());

    final extractedColor = TColorMap.getColor(text);
    final isColor = extractedColor != null;

    return GestureDetector(
      // عند بدء الضغط المطول: نمرر السياق والبيانات للكنترولر ليرسم الفقاعة
      onLongPressStart: isColor
          ? (_) =>
                controller.showPreview(context, text, extractedColor, selected)
          : null,
      // عند رفع الإصبع أو إلغاء الضغط: نأمر الكنترولر بإخفائها فوراً
      onLongPressEnd: isColor ? (_) => controller.hidePreview() : null,
      onLongPressCancel: isColor ? () => controller.hidePreview() : null,

      child: ChoiceChip(
        showCheckmark: isColor ? true : false,
        label: isColor ? const SizedBox() : Text(text),
        selected: selected,
        onSelected: onSelected,
        selectedColor: isColor ? extractedColor : null,
        labelStyle: TextStyle(color: selected ? TColors.white : null),
        avatar: (isColor && !text.isTxtFileName)
            ? TCircularContainer(
                width: 50,
                heigth: 50,
                backgroundColor: extractedColor,
              )
            : null,
        shape: isColor ? const CircleBorder() : null,
        backgroundColor: isColor ? extractedColor : Colors.white,
        labelPadding: isColor ? const EdgeInsets.all(0) : null,
        padding: isColor ? const EdgeInsets.all(0) : null,
      ),
    );
  }
}





/*
class TChoiceChip extends StatefulWidget {
  const TChoiceChip({
    super.key,
    required this.text,
    required this.selected,
    this.onSelected,
    this.color,
  });

  final String text;
  final bool selected;
  final Color? color;
  final void Function(bool)? onSelected;

  @override
  State<TChoiceChip> createState() => _TChoiceChipState();
}

class _TChoiceChipState extends State<TChoiceChip>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // إعداد أنيميشن الدخول الناعم للفقاعة العائمة
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack, // حركة ارتدادية ناعمة ومميزة للتكبير
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  // إنشاء وإظهار فقاعة المعاينة فوق الـ Chip مباشرة
  void _showColorPreview(BuildContext context, Color color) {
    _removeOverlay(); // التأكد من تنظيف أي نافذة سابقة

    // تحديد مكان الـ Chip على الشاشة لحساب مكان ظهور الفقاعة بدقة
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // إحداثيات الظهور: فوق الـ Chip بـ 80 بكسل وتوسيطها أفقياً
        left: offset.dx - (80 - renderBox.size.width) / 2,
        top: offset.dy - 85,
        child: Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _animationController,
              child: _buildPreviewBubble(color),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  // بناء تصميم الفقاعة العائمة الناعم
  Widget _buildPreviewBubble(Color color) {
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
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12, width: 1),
                ),
              ),
              const SizedBox(width: 10),
              // اسم اللون الكامل والمنسق
              Text(
                widget.text.capitalizeFirst ?? widget.text,
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
        CustomPaint(size: const Size(12, 6), painter: _TrianglePainter()),
      ],
    );
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _animationController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final extractedColor = TColorMap.getColor(widget.text);
    final isColor = extractedColor != null;

    // ويدجت الـ ChoiceChip الأساسي مغلّف بـ GestureDetector لالتقاط الضغط المطول والإفلات
    return GestureDetector(
      onLongPressStart: isColor
          ? (_) => _showColorPreview(context, extractedColor)
          : null,
      onLongPressEnd: isColor ? (_) => _removeOverlay() : null,
      onLongPressMoveUpdate: isColor
          ? (_) {}
          : null, // استمرارية الحفاظ على النافذة أثناء حركة الإصبع الطفيفة
      child: ChoiceChip(
        showCheckmark: isColor ? true : false,
        label: isColor ? const SizedBox() : Text(widget.text),
        selected: widget.selected,
        onSelected: widget.onSelected,
        selectedColor: isColor ? extractedColor : null,
        labelStyle: TextStyle(color: widget.selected ? TColors.white : null),
        avatar: (isColor && !widget.text.isTxtFileName)
            ? TCircularContainer(
                width: 50,
                heigth: 50,
                backgroundColor: extractedColor,
              )
            : null,
        shape: isColor ? const CircleBorder() : null,
        backgroundColor: isColor ? extractedColor : Colors.white,
        labelPadding: isColor ? const EdgeInsets.all(0) : null,
        padding: isColor ? const EdgeInsets.all(0) : null,
      ),
    );
  }
}

// رسمة مخصصة للمثلث الصغير أسفل الفقاعة العائمة
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







/*
class TChoiceChip extends StatelessWidget {
  const TChoiceChip({
    super.key,
    required this.text,
    required this.selected,
    this.onSelected,
    this.color,
  });
  final String text;
  final bool selected;
  final Color? color;
  final void Function(bool)? onSelected;

  @override
  Widget build(BuildContext context) {
    final isColor = TColorMap.getColor(text) != null;
    return ChoiceChip(
      showCheckmark: isColor ? true : false,
      label: isColor ? SizedBox() : Text(text),
      selected: selected,
      onSelected: onSelected,
      selectedColor: isColor ? TColorMap.getColor(text) : null,
      labelStyle: TextStyle(color: selected ? TColors.white : null),
      avatar: (isColor && !text.isTxtFileName)
          ? TCircularContainer(
              width: 50,
              heigth: 50,
              backgroundColor: TColorMap.getColor(text)!,
            )
          : null,
      shape: isColor ? CircleBorder() : null,
      backgroundColor: isColor ? TColorMap.getColor(text) : Colors.white,
      labelPadding: isColor ? EdgeInsets.all(0) : null,
      padding: isColor ? EdgeInsets.all(0) : null,
    );
  }
}
*/