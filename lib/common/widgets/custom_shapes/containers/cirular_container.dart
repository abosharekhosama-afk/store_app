import 'package:flutter/cupertino.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';

class TCircularContainer extends StatelessWidget {
  const TCircularContainer({
    super.key,
    this.width = 400,
    this.heigth = 400,
    this.redius = 400,
    this.padding = const EdgeInsets.all(0),
    this.child,
    this.backgroundColor = TColors.white,
    this.margin = const EdgeInsets.all(0),
  });

  final double? width;
  final double? heigth;
  final double redius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Widget? child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: heigth,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(redius),
        color: backgroundColor,
      ),
      child: child,
    );
  }
}
