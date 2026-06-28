import 'package:get/get_navigation/get_navigation.dart';
import 'package:untitled2_ecom/features/shop/screens/home/home.dart';
import 'package:untitled2_ecom/features/shop/screens/store_unused/store.dart';
import 'package:untitled2_ecom/routes/routes.dart';

class AppRoutes {
  static final pages = [
    GetPage(name: TRoutes.home, page: () => const Home()),
    GetPage(name: TRoutes.store, page: () => const Store()),
  ];
}
