import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/features/personalization/controllers/address_controller.dart';
import 'package:untitled2_ecom/features/personalization/models/user_stor_model.dart';
import 'package:untitled2_ecom/utils/popups/loaders.dart'; // تأكد من المسار

class StoreController extends GetxController {
  static StoreController get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  // --- البيانات الجغرافية المعتمدة ---
  final RxMap<String, Map<String, Map<String, dynamic>>> addressData =
      AddressController.instance.palestineAddressData;

  // --- المتغيرات ---
  RxList<StoreModel> allStores = <StoreModel>[].obs;
  RxList<StoreModel> filteredStores = <StoreModel>[].obs;
  final isLoading = false.obs;

  // متغيرات الفلترة والبحث
  RxString selectedCity = "غزة".obs; // المحافظة (Country في الموديل)
  RxString selectedDistrict = "الكل".obs; // المنطقة (City في الموديل)
  RxString searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    // fetchStores();
    fetchStoresFromFirebase(); // الجلب الأولي بناءً على الفلاتر الافتراضية
  }

  // 1. جلب المتاجر من الفايربيز
  Future<void> fetchStores() async {
    try {
      isLoading.value = true;
      final snapshot = await _db
          .collection(StoreModel.getStoreCollectionName)
          .get();
      final list = snapshot.docs
          .map((doc) => StoreModel.fromSnapshot(doc))
          .toList();

      allStores.assignAll(list);
      filteredStores.assignAll(allStores);
      applyFilter(); // تطبيق الفلترة الأولية
      print("تم جلب ${list.length} من المتاجر بنجاح");
    } catch (e) {
      TLoaders.errorSnackBar(title: "خطأ", message: "تعذر جلب المتاجر: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// الدالة الرئيسية لجلب البيانات المفلترة من Firebase مباشرة
  Future<void> fetchStoresFromFirebase() async {
    try {
      isLoading.value = true;

      // 1. نبدأ بمرجع الكولكشن
      Query query = _db.collection(StoreModel.getStoreCollectionName);

      // 2. إضافة شرط المحافظة (يجب أن يطابق اسم الحقل في الفايربيز لديك)
      // ملاحظة: تأكد من مسار الحقل داخل addressModel (مثلاً: addressModel.country)
      query = query.where('addressModel.city', isEqualTo: selectedCity.value);

      // 3. إضافة شرط المدينة إذا لم تكن "الكل"
      if (selectedDistrict.value != "الكل") {
        query = query.where(
          'addressModel.district',
          isEqualTo: selectedDistrict.value,
        );
      }

      // 4. منطق البحث بالاسم (Firebase لا يدعم البحث الجزئي بـ contains بشكل مباشر)
      // نستخدم حيلة النطاق للبحث عن الكلمات التي تبدأ بـ النص المدخل
      if (searchQuery.value.isNotEmpty) {
        String search = searchQuery.value;
        query = query
            .where(
              StoreModel.getStoreCollectionName,
              isGreaterThanOrEqualTo: search,
            )
            .where(
              StoreModel.getStoreCollectionName,
              isLessThanOrEqualTo: '$search\uf8ff',
            );
      }

      // تنفيذ الاستعلام
      final snapshot = await query.get();

      final list = StoreModel.fromQuerySnapshot(snapshot);

      filteredStores.assignAll(list);
    } catch (e) {
      TLoaders.errorSnackBar(
        title: "خطأ",
        message: "تعذر جلب البيانات من السيرفر: $e",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 2. محرك البحث الذكي
  void searchStore(String query) {
    final trimmedQuery = query.trim();

    // تحديث قيمة المتغير المُرَاقب
    searchQuery.value = trimmedQuery;

    // استدعاء السيرفر مرة واحدة فقط للبحث عن الكلمة النهائية
    fetchStoresFromFirebase();
  }

  // 3. منطق الفلترة الهرمي (Hierarchical Filtering)
  void applyFilter() {
    // تصفية القائمة بناءً على الشروط الثلاثة معاً
    print("Total Stores: ${allStores.length}"); // هل تم جلب البيانات أصلاً؟
    var tempStores = allStores.where((store) {
      // أ- شرط البحث بالاسم
      bool matchesSearch = store.storName.toLowerCase().contains(
        searchQuery.value.toLowerCase(),
      );

      // ب- شرط المدينة (city)
      bool matchesCity = store.addressModel.city == selectedCity.value;

      // ج- شرط /المنطقة (district)
      bool matchesDistrict =
          (selectedDistrict.value == "الكل") ||
          (store.addressModel.district == selectedDistrict.value);

      return matchesSearch && matchesCity && matchesDistrict;
    }).toList();
    print("Filtered Stores: ${tempStores.length}"); // هل ناتج الفلترة صفر؟
    filteredStores.assignAll(tempStores);
  }

  // 5. دالة تغيير المدينة/المنطقة
  void updateDistrict(String district) {
    selectedDistrict.value = district;
    fetchStoresFromFirebase(); // إعادة الطلب من السيرفر عند البحث
    //applyFilter();
  }

  void updateCity(String city) {
    selectedCity.value = city;
    selectedDistrict.value = "الكل"; // مهم جداً لتحديث التابات فوراً
    fetchStoresFromFirebase(); // إعادة الطلب من السيرفر عند البحث
    applyFilter();
  }
}
