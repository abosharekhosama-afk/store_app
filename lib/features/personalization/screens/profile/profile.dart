import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/common/widgets/images/circular_image.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/shimmer.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/features/personalization/controllers/user_controller.dart';
import 'package:untitled2_ecom/features/personalization/models/user_model.dart';
import 'package:untitled2_ecom/features/personalization/screens/profile/change_name.dart';
import 'package:untitled2_ecom/features/personalization/screens/profile/widget/profile_menu.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = UserController.instance;
    final controller = UserController.instance;

    return Scaffold(
      appBar: TAppbar(title: Text(TTexts.profile), showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage = controller.user.value.profilePicture;
                      final image = networkImage.isNotEmpty
                          ? networkImage
                          : TImages.user;
                      return controller.imageUploading.value
                          ? TShimmerEffect(width: 80, height: 80, radius: 80)
                          : TCircularImage(
                              image: image,
                              width: 80,
                              height: 80,
                              isNetworkImage: networkImage.isNotEmpty,
                            );
                    }),
                    TextButton(
                      onPressed: () => controller.uploadUserProfilePicture(),
                      child: Text("تغيير صورة الملف الشخصي"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),
              sectionHeading(
                labelText: "معلومات الملف الشخصي",
                showButtton: false,
                padding: EdgeInsets.zero,
              ),
              Obx(() {
                // يمكنك إضافة شرط عرض شيمر (Shimmer) إذا كانت البيانات لا تزال تُحمل

                return Column(
                  children: [
                    TProfileMenu(
                      title: "الاسم",
                      value: controller.user.value.fullName,
                      onPreessed: () => Get.to(ChangeName()),
                    ),
                    TProfileMenu(
                      title: "اسم المستخدم",
                      value: controller.user.value.username,
                      onPreessed: () {},
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems / 2),
                    const Divider(),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    sectionHeading(
                      labelText: "المعلومات الشخصية",
                      showButtton: false,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    TProfileMenu(
                      title: "رقم المستخدم",
                      value: controller.user.value.id,
                      onPreessed: () {},
                      icon: Iconsax.copy,
                    ),
                    TProfileMenu(
                      title: TTexts.tEmail,
                      value: controller.user.value.email,
                      onPreessed: () {},
                    ),
                    TProfileMenu(
                      title: "رقم الهاتف",
                      value: controller.user.value.phoneNumber.isNotEmpty
                          ? controller.user.value.phoneNumber
                          : "إضافة رقم هاتف",
                      onPreessed: () => controller.showEditBottomSheet(
                        title: "تعديل رقم الهاتف",
                        hint: "أدخل رقم الهاتف الجديد",
                        initialValue: controller.user.value.phoneNumber,
                        icon: Icons.phone_android_rounded,
                        onSave: (newValue) => controller.updateSingleField(
                          UserModel.getPhoneNumber,
                          newValue,
                        ),
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwItems / 2),
                    const Divider(),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    // 📌 القسم الجديد: الحساب البنكي المطور
                    sectionHeading(
                      labelText: "بيانات الحساب البنكي (لتلقي المستحقات)",
                      showButtton: false,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    TProfileMenu(
                      title: "اسم البنك",
                      value: controller.user.value.bankName.isNotEmpty
                          ? controller.user.value.bankName
                          : "لم يحدد بعد",
                      onPreessed: () => controller.showEditBottomSheet(
                        title: "تعديل اسم البنك",
                        hint: "مثال: بنك فلسطين، البنك العربي...",
                        initialValue: controller.user.value.bankName,
                        icon: Icons.account_balance_rounded,
                        onSave: (newValue) => controller.updateSingleField(
                          UserModel.getBankName,
                          newValue,
                        ),
                      ),
                    ),
                    TProfileMenu(
                      title: "رقم الحساب البنكي",
                      value: controller.user.value.bankNoumber.isNotEmpty
                          ? controller.user.value.bankNoumber
                          : "لم يحدد بعد",
                      onPreessed: () => controller.showEditBottomSheet(
                        title: "رقم الحساب البنكي",
                        hint: "أدخل رقم الحساب أو الـ IBAN",
                        initialValue: controller.user.value.bankNoumber,
                        icon: Icons.numbers_rounded,
                        onSave: (newValue) => controller.updateSingleField(
                          UserModel.getBankNoumber,
                          newValue,
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),
              Center(
                child: TextButton(
                  onPressed: () => controller.deleteAccountWarningPopup(),
                  child: Text(
                    "إغلاق الحساب",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
