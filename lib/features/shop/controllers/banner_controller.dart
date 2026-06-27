import 'package:get/get.dart';
import 'package:untitled2_ecom/data/repositories/banners/banner_repository.dart';
import 'package:untitled2_ecom/features/shop/models/banner_model.dart';
import 'package:untitled2_ecom/utils/popups/loaders.dart';

class BannerController extends GetxController {
  static BannerController get instance => Get.find();

  final caroursalCurrentIndex = 0.obs;
  final _bannerRepository = Get.put(BannerRepository());
  RxList<BannerModel> allbanner = <BannerModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    fetchBanners();
    super.onInit();
  }

  void updatePageIndicator(index) {
    caroursalCurrentIndex.value = index;
  }

  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;

      final banners = await _bannerRepository.fetchBanners();
      allbanner.assignAll(banners);
    } catch (e) {
      TLoaders.errorSnackBar(title: "On Snap!", message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
