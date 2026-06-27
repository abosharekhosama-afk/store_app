import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/common/widgets/images/circular_image.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/shimmer.dart';
import 'package:untitled2_ecom/features/personalization/controllers/user_controller.dart';
import 'package:untitled2_ecom/features/personalization/screens/profile/profile.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';

class TUserProfileTile extends StatelessWidget {
  const TUserProfileTile({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return Obx(() {
      if (controller.profileLoding.value) {
        return const TShimmerEffect(width: double.infinity, height: 80);
      }
      final user = controller.user.value;
      final networkImage = user.profilePicture;
      final image = networkImage.isNotEmpty ? networkImage : TImages.user;
      // إذا كان هناك تحميل للبيانات لأول مرة (اختياري)
      if (controller.profileLoding.value) {
        return const TShimmerEffect(width: double.infinity, height: 80);
      }

      return ListTile(
        leading: controller.imageUploading.value
            ? TShimmerEffect(width: 80, height: 80, radius: 80)
            : TCircularImage(
                image: image,
                width: 50,
                height: 50,
                padding: 0,
                isNetworkImage: networkImage.isNotEmpty,
              ),

        title: Text(
          controller.user.value.fullName,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall!.apply(color: TColors.white),
        ),

        subtitle: Text(
          controller.user.value.email,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.apply(color: TColors.white),
        ),

        trailing: IconButton(
          onPressed: () => Get.to(() => Profile()),
          icon: Icon(Iconsax.edit, color: TColors.white),
        ),
        onTap: onPressed,
      );
    });
  }
}
