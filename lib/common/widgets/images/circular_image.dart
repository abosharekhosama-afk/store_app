import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/shimmer.dart'; // تأكد من المسار
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class TCircularImage extends StatelessWidget {
  const TCircularImage({
    super.key,
    this.fit = BoxFit.cover,
    required this.image,
    this.isNetworkImage = false,
    this.overlayColor,
    this.backgroundColor,
    this.width = 56,
    this.height = 56, // تم تصحيح الخطأ الإملائي من heigth إلى height
    this.padding = TSizes.sm,
    this.margin = 0.0,
  });

  final BoxFit? fit;
  final String image;
  final bool isNetworkImage;
  final Color? overlayColor;
  final Color? backgroundColor;
  final double width, height, padding, margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: isNetworkImage
            ? CachedNetworkImage(
                imageUrl: image,
                fit: fit,
                color: overlayColor,
                // عرض شيمر أثناء التحميل
                placeholder: (context, url) => TShimmerEffect(
                  width: width,
                  height: height,
                  radius: height,
                ),
                // عرض أيقونة خطأ في حال فشل التحميل أو انقطاع النت ولم تكن الصورة مخزنة
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            : Image(fit: fit, image: AssetImage(image), color: overlayColor),
      ),
    );
  }
}
