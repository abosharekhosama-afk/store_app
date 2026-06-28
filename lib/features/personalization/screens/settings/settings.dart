import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/common/widgets/custom_shapes/curved_edges/t_modern_header_design.dart';
import 'package:untitled2_ecom/common/widgets/list_tile/settings_menu_tile.dart';
import 'package:untitled2_ecom/common/widgets/list_tile/user_profile_tile.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/data/repositories/brands/brand_repository.dart';
import 'package:untitled2_ecom/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:untitled2_ecom/features/personalization/screens/Notification/notification_screen.dart';
import 'package:untitled2_ecom/features/personalization/screens/address/addresses.dart';
import 'package:untitled2_ecom/features/personalization/screens/profile/profile.dart';
import 'package:untitled2_ecom/features/shop/controllers/dummy_data.dart';
import 'package:untitled2_ecom/features/shop/screens/cart/cart.dart';
import 'package:untitled2_ecom/features/shop/screens/order/orders.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';
import 'package:untitled2_ecom/features/personalization/screens/WalletScreen.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            forceMaterialTransparency: false,
            pinned: true,
            floating: false,
            //expandedHeight: 180,
            automaticallyImplyLeading: false,
            toolbarHeight: kToolbarHeight,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor:
                  Colors.transparent, // جعل خلفية شريط الحالة شفافة تماماً
              statusBarIconBrightness:
                  Brightness.light, // لأجهزة أندرويد: أيقونات بيضاء
              statusBarBrightness:
                  Brightness.dark, // لأجهزة آيفون (iOS): نصوص وأيقونات بيضاء
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: ClipPath(
                clipper: TModernCurvedClipper(),
                child: TModernHeaderDesign(
                  isCollapsed: false,
                  statusBarHeight: MediaQuery.of(context).padding.top,
                  child: Column(
                    children: [
                      TAppbar(
                        showBackArrow: false,
                        showBlur: false,
                        title: Text(
                          "الحساب",
                          style: Theme.of(context).textTheme.headlineMedium!
                              .apply(color: TColors.white),
                        ),
                      ),

                      //SizedBox(height: TSizes.spaceBtwSections),
                    ],
                  ),
                ),
              ),
            ),

            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: TUserProfileTile(onPressed: () => Get.to(() => Profile())),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  sectionHeading(
                    labelText: "إعدادات الحساب",
                    showButtton: false,
                    padding: EdgeInsets.zero,
                  ),
                  SizedBox(height: TSizes.spaceBtwItems),
                  TSettingsMenuTile(
                    icon: Iconsax.safe_home,
                    title: "عناويني",
                    subTitle: "ادارة العناوين",
                    onTap: () => Get.to(() => UserAddressesScreen()),
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.shopping_cart,
                    title: "سلتي",
                    onTap: () => Get.to(() => Cart()),
                    subTitle: "عربة المنتجات",
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.bag_tick,
                    title: "طلباتي",
                    subTitle: "تتبع حالة الطلبات",
                    onTap: () => Get.to(() => Orders()),
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.bank,
                    title: "الحساب البنكي",
                    subTitle: "مراجعة العمليات المالية",
                    onTap: () => Get.to(() => WalletScreen()),
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.notification,
                    title: "الإشعارات",
                    onTap: () => Get.to(() => NotificationScreen()),
                    subTitle: "الاشعارات الواردة",
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.security_card,
                    title: "خصوصية الحساب",
                    subTitle: TTexts.signupScreenSubTitle,
                  ),

                  SizedBox(height: TSizes.spaceBtwItems),
                  sectionHeading(
                    labelText: "بيانات المساعدة",
                    showButtton: false,
                    padding: EdgeInsets.zero,
                  ),

                  TSettingsMenuTile(
                    icon: Iconsax.document_upload,
                    title: "تحميل بيانات الماركات",
                    subTitle: TTexts.signupScreenSubTitle,
                    onTap: () => BrandRepository.instance.uploadDummyData(
                      TDummyData.brands,
                    ),
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.document_upload,
                    title: "تحميل بيانات الماركات والمنتجات حسب الفئة",
                    subTitle: TTexts.signupScreenSubTitle,
                    onTap: () => BrandRepository.instance
                        .uploadDummyDataForBranndAndProductForCategory(
                          TDummyData.brandCategory,
                          TDummyData.productCategory,
                        ),
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.location,
                    title: "الموقع الجغرافي",
                    subTitle: TTexts.signupScreenSubTitle,
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.security_user,
                    title: "الوضع الآمن",
                    subTitle: TTexts.signupScreenSubTitle,
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.image,
                    title: "جودة صورة عالية الدقة",
                    subTitle: TTexts.signupScreenSubTitle,
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () =>
                          AuthenticationRepository.instance.logout(),
                      child: Text("تسجيل الخروج"),
                    ),
                  ),
                  SizedBox(height: TSizes.spaceBtwSections * 3),
                ],
              ),
            ),
          ),
        ],

        /*
         SingleChildScrollView(
          child: Column(
            children: [
              TModernHeaderDesign(
                isCollapsed: false,
                statusBarHeight: MediaQuery.of(context).padding.top,
                child: Column(
                  children: [
                    TAppbar(
                      showBackArrow: false,
                      showBlur: false,
                      title: Text(
                        "الحساب",
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium!.apply(color: TColors.white),
                      ),
                    ),
                    //SizedBox(height: TSizes.spaceBtwSections),
                    TUserProfileTile(onPressed: () => Get.to(() => Profile())),
                    SizedBox(height: TSizes.spaceBtwSections),
                  ],
                ),
              ),
        
              Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    sectionHeading(
                      labelText: "إعدادات الحساب",
                      showButtton: false,
                      padding: EdgeInsets.zero,
                    ),
                    SizedBox(height: TSizes.spaceBtwItems),
                    TSettingsMenuTile(
                      icon: Iconsax.safe_home,
                      title: "عناويني",
                      subTitle: "ادارة العناوين",
                      onTap: () => Get.to(() => UserAddressesScreen()),
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.shopping_cart,
                      title: "سلتي",
                      onTap: () => Get.to(() => Cart()),
                      subTitle: "عربة المنتجات",
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.bag_tick,
                      title: "طلباتي",
                      subTitle: "تتبع حالة الطلبات",
                      onTap: () => Get.to(() => Orders()),
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.bank,
                      title: "الحساب البنكي",
                      subTitle: "مراجعة العمليات المالية",
                      onTap: () => Get.to(() => WalletScreen()),
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.notification,
                      title: "الإشعارات",
                      onTap: () => Get.to(() => NotificationScreen()),
                      subTitle: "الاشعارات الواردة",
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.security_card,
                      title: "خصوصية الحساب",
                      subTitle: TTexts.signupScreenSubTitle,
                    ),
        
                    SizedBox(height: TSizes.spaceBtwItems),
                    sectionHeading(
                      labelText: "بيانات المساعدة",
                      showButtton: false,
                      padding: EdgeInsets.zero,
                    ),
        
                    TSettingsMenuTile(
                      icon: Iconsax.document_upload,
                      title: "تحميل بيانات الماركات",
                      subTitle: TTexts.signupScreenSubTitle,
                      onTap: () => BrandRepository.instance.uploadDummyData(
                        TDummyData.brands,
                      ),
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.document_upload,
                      title: "تحميل بيانات الماركات والمنتجات حسب الفئة",
                      subTitle: TTexts.signupScreenSubTitle,
                      onTap: () => BrandRepository.instance
                          .uploadDummyDataForBranndAndProductForCategory(
                            TDummyData.brandCategory,
                            TDummyData.productCategory,
                          ),
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.location,
                      title: "الموقع الجغرافي",
                      subTitle: TTexts.signupScreenSubTitle,
                      trailing: Switch(value: true, onChanged: (value) {}),
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.security_user,
                      title: "الوضع الآمن",
                      subTitle: TTexts.signupScreenSubTitle,
                      trailing: Switch(value: false, onChanged: (value) {}),
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.image,
                      title: "جودة صورة عالية الدقة",
                      subTitle: TTexts.signupScreenSubTitle,
                      trailing: Switch(value: false, onChanged: (value) {}),
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            AuthenticationRepository.instance.logout(),
                        child: Text("تسجيل الخروج"),
                      ),
                    ),
                    SizedBox(height: TSizes.spaceBtwSections * 2.5),
                  ],
                ),
              ),
            ],
          ),
        ),
      */
      ),
    );
  }
}
