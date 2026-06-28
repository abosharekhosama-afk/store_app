import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/data/repositories/address/address_repository.dart';
import 'package:untitled2_ecom/features/personalization/models/address_model_new.dart';
import 'package:untitled2_ecom/features/personalization/screens/address/widget/address_form_view.dart';
import 'package:untitled2_ecom/features/personalization/screens/address/widget/single_address.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/order_controller_new.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/cloud_helper_functions.dart';
import 'package:untitled2_ecom/utils/helpers/network_manager.dart';
import 'package:untitled2_ecom/utils/popups/full_screen_loader.dart';
import 'package:untitled2_ecom/utils/popups/loaders.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  final addressRepository = Get.put(AddressRepository());
  final RxList<AddressModelNew> addressList = <AddressModelNew>[].obs;
  final Rx<AddressModelNew> selctedAddress = AddressModelNew.empty().obs;
  final RxBool isLoading = false.obs;
  RxBool refreshData = true.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // قيم مختارة قابلة للمراقبة
  var selectedCity = "".obs;
  var selectedDistrict = "".obs;
  var selectedStreet = "".obs;
  var selectedMarks = "".obs;

  TextEditingController buildingNumberController = TextEditingController();
  TextEditingController addressDetailsController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();

  // قوائم يتم تحديثها بناءً على الاختيار
  var districtsList = <String>[].obs;
  var streetsList = <String>[].obs;
  var landmarksList = <String>[].obs; // قائمة المعالم

  RxMap<String, Map<String, Map<String, dynamic>>> palestineAddressData =
      <String, Map<String, Map<String, dynamic>>>{}.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getAllUserAddresses();
    loadAndBuildMap();
  }

  // جلب البيانات وبناء الخريطة المتداخلة
  Future<void> loadAndBuildMap() async {
    try {
      final data = await addressRepository.fetchAllShippingData();

      Map<String, Map<String, Map<String, dynamic>>> tempMap = {};

      for (var item in data) {
        String gov = item['governorate'];
        String city = item['city'];
        String street = item['street'];

        tempMap.putIfAbsent(gov, () => {});
        tempMap[gov]!.putIfAbsent(city, () => {});
        tempMap[gov]![city]![street] = {
          "landmarks": List<String>.from(item['landmarks']),
          "fee": item['deliveryFee'],
        };
      }
      palestineAddressData.value = tempMap;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'خطأ في التحميل', message: e.toString());
    } finally {}
  }

  void onCityChanged(String? city) {
    if (city == null) return;
    selectedCity.value = city;
    selectedDistrict.value = "";
    selectedStreet.value = "";

    // جلب المناطق التابعة للمحافظة
    districtsList.assignAll(palestineAddressData[city]?.keys.toList() ?? []);
    streetsList.clear();
  }

  void onDistrictChanged(String? district) {
    if (district == null || selectedCity.isEmpty) return;
    selectedDistrict.value = district;
    selectedStreet.value = "";
    selectedMarks.value = "";

    // جلب مفاتيح الشوارع من الخريطة
    var streets =
        palestineAddressData[selectedCity.value]?[district]?.keys.toList() ??
        [];
    streetsList.assignAll(streets.cast<String>());

    landmarksList.clear(); // مسح المعالم عند تغيير المنطقة
  }

  void onStreetChanged(String? street) {
    if (street == null || selectedDistrict.isEmpty) return;
    selectedStreet.value = street;
    selectedMarks.value = "";

    // الوصول إلى قائمة المعالم داخل الخريطة
    var data =
        palestineAddressData[selectedCity.value]?[selectedDistrict
            .value]?[street];

    if (data != null && data['landmarks'] != null) {
      List<String> marks = List<String>.from(data['landmarks']);
      landmarksList.assignAll(marks);
    } else {
      landmarksList.clear();
    }
  }

  void onMarksChanged(String? mark) {
    if (mark != null) selectedMarks.value = mark;
  }

  Future<List<AddressModelNew>> getAllUserAddresses() async {
    try {
      isLoading.value = true;
      final addresses = await addressRepository.fetchUserAddresses();
      selctedAddress.value = addresses.firstWhere(
        (element) => element.selectedAddress,
        orElse: () => AddressModelNew.empty(),
      );
      isLoading.value = false;
      addressList.value = addresses;
      return addresses;
    } catch (e) {
      isLoading.value = false;
      TLoaders.errorSnackBar(
        title: "لم يتم العثور على العناوين",
        message: e.toString(),
      );
      return [];
    }
  }

  Future selectAddress(AddressModelNew newSelectedAddress) async {
    try {
      // إظهار لودر دائري بسيط
      TFullScreenLoader.openLoadingDialog(
        "يتم تحديث العنوان...",
        TImages.docerAnimation,
      );

      // 1. إلغاء تحديد العنوان السابق في قاعدة البيانات
      if (selctedAddress.value.id.isNotEmpty) {
        await addressRepository.updateSelectedAddress(
          selctedAddress.value.id,
          false,
        );
      }

      // 2. تحديث العنوان الجديد في قاعدة البيانات
      await addressRepository.updateSelectedAddress(
        newSelectedAddress.id,
        true,
      );

      // 3. تحديث الحالة المحلية (هنا يكمن الحل)
      // نقوم بتحديث الخاصية داخل الكائن المختار حالياً
      selctedAddress.value.selectedAddress = false; // القديم
      newSelectedAddress.selectedAddress = true; // الجديد
      selctedAddress.value = newSelectedAddress; // تحديث المرجع

      // 4. تحديث القائمة بالكامل لكي يشعر Obx بالتغيير في الواجهة
      addressList.refresh();

      TFullScreenLoader.stopLoading();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "خطأ", message: e.toString());
    }
  }

  Future addNewAddresses() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "Storing Address...",
        TImages.docerAnimation,
      );

      if (!formKey.currentState!.validate()) {
        // نفس مبدا العمل
        TFullScreenLoader.stopLoading();
        return;
      }

      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      final address = AddressModelNew(
        id: "",
        street: selectedStreet.value,
        city: selectedCity.value,
        district: selectedDistrict.value,
        postalCode: postalCodeController.text.trim(),
        country: "PS",
        selectedAddress: true,
        buildingNumber: buildingNumberController.text.trim(),
        address: addressDetailsController.text.trim(),
        dateTime: DateTime.now(),
      );

      final id = await addressRepository.addAddresses(address);
      address.id = id;
      await selectAddress(address);
      TFullScreenLoader.stopLoading();

      TLoaders.successSnackBar(
        title: "Congratulations",
        message: "Your address has been saved successfully.",
      );
      refreshData.toggle();
      resetFormFieldes();
      Navigator.of(Get.context!).pop();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
        title: "Address not found",
        message: e.toString(),
      );
    }
  }

  void resetFormFieldes() {
    selectedCity.value = "";
    selectedDistrict.value = "";
    selectedStreet.value = "";
    postalCodeController.clear();
    addressDetailsController.clear();
    formKey.currentState?.reset();
  }

  Future<dynamic> selectNewAddressPopup(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true, // للسماح للـ BottomSheet بالتوسع
      builder: (context) => Container(
        padding: const EdgeInsets.all(TSizes.lg),
        height: MediaQuery.of(context).size.height * 0.7, // تحديد طول معين
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const sectionHeading(
              labelText: "Select Address",
              showButtton: false,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            Expanded(
              // ضروري جداً هنا لتجنب خطأ الـ Layout
              child: FutureBuilder(
                future: getAllUserAddresses(),
                builder: (context, snapshot) {
                  // استخدم الهيلبر الخاص بك للتحقق من الحالة
                  final response = TCloudHelperFunctions.checkMultiRecordState(
                    snapshot: snapshot,
                  );
                  if (response != null) return response;

                  final data = snapshot.data as List<AddressModelNew>;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (_, index) => SingleAddress(
                      address: data[index],
                      otTap: () async {
                        await selectAddress(data[index]);
                        // استدعاء دالة تحديث الحساب فوراً ليتم الحساب بناءً على مكان العميل الجديد
                        OrderController.instance.calculateShippingCost();
                        Get.back();
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: TSizes.defaultSpace),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const AddressFormWidget()),
                child: const Text("Add new address"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
