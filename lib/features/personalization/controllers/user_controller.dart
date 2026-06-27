import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled2_ecom/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:untitled2_ecom/data/repositories/user/user_reposity.dart';
import 'package:untitled2_ecom/features/authentication/screens/login/logine.dart';
import 'package:untitled2_ecom/features/personalization/models/user_model.dart';
import 'package:untitled2_ecom/features/personalization/screens/profile/widget/re_authenticate_user_login_form.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/network_manager.dart';
import 'package:untitled2_ecom/utils/popups/full_screen_loader.dart';
import 'package:untitled2_ecom/utils/popups/loaders.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();
  Rx<UserModel> user = UserModel.empty().obs;
  final profileLoding = false.obs;

  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  final userRepository = Get.put(UserReposity());
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();
  final imageUploading = false.obs;
  var isLoading = false.obs;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    // TODO: implement onInit

    super.onInit();
    fetchUserRecord();
  }

  Future<void> fetchUserRecord() async {
    try {
      profileLoding.value = true;

      // تأكيد أولي للتأكد من أن الـ UID ليس فارغاً
      final uid = AuthenticationRepository.instance.authUser?.uid;

      if (uid == null || uid.isEmpty) {
        print(
          "تنبيه: الـ UID الخاص بالمستخدم الحالي فارغ! لم يتم تسجيل الدخول بالكامل بعد.",
        );
        user.value = UserModel.empty();
        return;
      }

      final userFromData = await userRepository.fetchUserDetails();
      user.value = userFromData;
      user.refresh();
    } catch (e) {
      // طباعة الخطأ الفعلي لمعرفته بدقة
      print("Error caught in fetchUserRecord: $e");
      user.value = UserModel.empty();
      user.refresh();
    } finally {
      profileLoding.value = false;
    }
  }

  /*  Future<void> fetchUserRecord() async {
    try {
      profileLoding.value = true;
      final userFromData = await userRepository.fetchUserDetails();
      user.value = userFromData;
      // 🔥 الحل السحري: إجبار GetX على إشعار كافة الواجهات بالتحديث الجديد
      user.refresh();
      print("User Profile Image URL value: ${user.value.username}");
    } catch (e) {
      user.value = UserModel.empty();
      // 🔥 الحل السحري: إجبار GetX على إشعار كافة الواجهات بالتحديث الجديد
      user.refresh();
    } finally {
      profileLoding.value = false;
    }
  }*/

  /*
  Future<void> saveUserRecord(UserCredential? userCredential) async {
    try {
      await fetchUserRecord();
      if (user.value.id.isEmpty) {
        if (userCredential != null) {
          final nameParts = UserModel.nameParts(
            userCredential.user!.displayName ?? "",
          );
          final username = UserModel.generateUsername(
            userCredential.user!.displayName ?? "",
          );

          final user = UserModel(
            id: userCredential.user!.uid,
            firstName: nameParts[0],
            lastName: nameParts.length > 1
                ? nameParts.sublist(1).join(" ")
                : "",
            username: username,
            email: userCredential.user!.email ?? "",
            phoneNumber: userCredential.user!.phoneNumber ?? "",
            profilePicture: userCredential.user!.photoURL ?? "",

          );
          await userRepository.saveUserRecord(user);
        }
      }
    } catch (e) {
      TLoaders.warningSnackBar(
        title: "Data not saved",
        message:
            "something went wrong while saving your information. you can re-save your data in your profile.",
      );
    }
  }
*/
  // 1. دالة التحديث الديناميكية في الفايرستور (Clean Single Responsibility)
  Future<void> updateSingleField(String fieldKey, String newValue) async {
    if (newValue.trim().isEmpty) {
      TLoaders.warningSnackBar(
        title: 'تنبيه',
        message: 'لا يمكن ترك الحقل فارغاً',
      );
      return;
    }

    try {
      isLoading.value = true;

      // التحديث في قاعدة البيانات
      await _db
          .collection(UserModel.getUserCollectionName)
          .doc(user.value.id)
          .update({fieldKey: newValue.trim()});

      // تحديث الكائن محلياً فوراً ليرى المستخدم التعديل بلحظتها (Reactive UI)
      if (fieldKey == UserModel.getPhoneNumber) {
        user.value.phoneNumber = newValue.trim();
      }
      if (fieldKey == UserModel.getBankName) {
        user.value.bankName = newValue.trim();
      }
      if (fieldKey == UserModel.getBankNoumber) {
        user.value.bankNoumber = newValue.trim();
      }

      user.refresh(); // إجبار GetX على إعادة بث التحديث لكل واجهات الـ Obx

      Get.back(); // إغلاق البوتم شيت
      TLoaders.successSnackBar(
        title: 'تم التحديث',
        message: 'تم حفظ البيانات بنجاح محاسبيّاً.',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'خطأ خادم', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 2. تصميم البوتم شيت الاحترافي المبتكر (Modern Premium BottomSheet)
  void showEditBottomSheet({
    required String title,
    required String hint,
    required String initialValue,
    required IconData icon,
    required Function(String) onSave,
  }) {
    final TextEditingController fieldController = TextEditingController(
      text: initialValue,
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: TColors.softWhite, // داكن فخم متناسق مع عمق التطبيق
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // مؤشر السحب العلوي الأنيق
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TColors.darkGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // العنوان مدمج مع أيقونة معبرة هادئة
              Row(
                children: [
                  Icon(icon, color: TColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Text(title),
                ],
              ),
              const SizedBox(height: 24),

              // حقل الإدخال بتصميم النيون والزجاج العائم
              TextFormField(
                controller: fieldController,
                style: const TextStyle(
                  color: TColors.textPrimary,
                  fontSize: 16,
                ),
                validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    color: TColors.textHint,
                    fontSize: 14,
                  ),
                  fillColor: TColors.softWhite,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  prefixIcon: Icon(icon, color: TColors.primary, size: 20),
                ),
              ),
              const SizedBox(height: 32),

              // أزرار التحكم الفاخرة الممتدة
              Row(
                children: [
                  // زر إلغاء الأمر
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF334155)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // زر الحفظ والأتمتة السحابية
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          onSave(fieldController.text);
                        }
                      },

                      child: const Text(
                        'حفظ التعديل',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // مساحة أمان للوحة مفاتيح هواتف الـ iOS والـ Android الحديثة
              SizedBox(height: MediaQuery.of(Get.context!).viewInsets.bottom),
            ],
          ),
        ),
      ),
      isScrollControlled:
          true, // يسمح للبوتم شيت بالتمدد التلقائي عند ظهور لوحة المفاتيح
      barrierColor: Colors.black.withOpacity(0.6), // تعتيم سينمائي ناعم للخلفية
    );
  }

  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: EdgeInsets.all(TSizes.md),
      title: "حذف الحساب",
      middleText:
          "هل أنت متأكد أنك تريد حذف حسابك نهائيًا؟ هذا الإجراء غير قابل للتراجع وسيتم حذف جميع بياناتك.",
      confirm: ElevatedButton(
        onPressed: () async => deleteUserAccount(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text("حذف"),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text("إلغاء"),
      ),
    );
  }

  void deleteUserAccount() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "جارٍ معالجة الطلب",
        TImages.docerAnimation,
      );
      final auth = AuthenticationRepository.instance;
      final provider = auth.authUser!.providerData
          .map((e) => e.providerId)
          .first;
      if (provider.isNotEmpty) {
        if (provider == "google.com") {
          await auth.signInWithGoogle();
          await auth.deleteAccount();
          TFullScreenLoader.stopLoading();
          Get.offAll(() => const LogineScreen());
        } else if (provider == "password") {
          TFullScreenLoader.stopLoading();
          Get.to(() => const ReAuthLoginForm());
        }
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: "يا للهول", message: e.toString());
    }
  }

  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "جارٍ معالجة الطلب...",
        TImages.docerAnimation,
      );

      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      if (!reAuthFormKey.currentState!.validate()) {
        // نفس مبدا العمل
        TFullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance.reAuthenticateEmailAndPassword(
        verifyEmail.text.trim(),
        verifyPassword.text.trim(),
      );
      await AuthenticationRepository.instance.deleteAccount();
      TFullScreenLoader.stopLoading();
      Get.offAll(() => const LogineScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: "يا للهول", message: e.toString());
    }
  }

  Future<void> uploadUserProfilePicture() async {
    try {
      // 1. اختيار الصورة من المعرض
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // ممتاز لتقليل الحجم
      );

      if (image == null) return;

      // 2. بدء حالة التحميل
      imageUploading.value = true;

      // 🌟 التعديل الجوهري: جلب الـ uid الخاص بالمستخدم الحالي المسجل في Firebase Auth
      // (قم بتعديل سطر جلب الـ UID بناءً على الكنترولر المسؤول عن تسجيل الدخول لديك، مثلاً AuthenticationRepository)
      final String currentUserId =
          AuthenticationRepository.instance.authUser?.uid ?? "";

      if (currentUserId.isEmpty) {
        throw "لم يتم العثور على بيانات مستخدم مسجل دخول.";
      }

      // 3. رفع الصورة إلى Firebase Storage مسار يحتوي على الـ UID
      String path = 'Users/$currentUserId/Profile/';
      final String downloadUrl = await userRepository.uploadImage(path, image);

      // 4. تحديث الحقل في Firestore
      Map<String, dynamic> newImage = {
        UserModel.getProfilePicture: downloadUrl,
      };
      await userRepository.updateSingleField(newImage);

      // 5. تحديث الحالة المحلية لتظهر الصورة فوراً للمستخدم
      user.value.profilePicture = downloadUrl;
      user.refresh();

      TLoaders.successSnackBar(
        title: 'مبارك',
        message: 'تم تحديث الصورة بنجاح',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'خطأ في الرفع', message: e.toString());
    } finally {
      imageUploading.value = false;
    }
  }

  /*
  Future<void> uploadUserProfilePicture() async {
    try {
      // 1. اختيار الصورة من المعرض
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // لتقليل حجم الصورة وسرعة الرفع
      );

      if (image == null) return;

      // 2. بدء حالة التحميل بناءً على نوع الصورة
      imageUploading.value = true;

      // 3. رفع الصورة إلى Firebase Storage
      // نستخدم المسار بناءً على النوع
      String path = 'Users/Images/Profile/';
      final String downloadUrl = await userRepository.uploadImage(path, image);

      // 4. تحديث الحقل في Firestore
      Map<String, dynamic> newImage = {
        UserModel.getProfilePicture: downloadUrl,
      };
      await userRepository.updateSingleField(newImage);

      // 5. تحديث الحالة المحلية لتظهر الصورة فوراً للمستخدم
      user.value.profilePicture = downloadUrl;

      user.refresh();

      TLoaders.successSnackBar(
        title: 'مبارك',
        message: 'تم تحديث الصورة بنجاح',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'خطأ', message: e.toString());
    } finally {
      imageUploading.value = false;
    }
  }
*/
}
