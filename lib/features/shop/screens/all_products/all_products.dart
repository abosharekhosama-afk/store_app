import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/common/widgets/productes_cart/sort_products.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/all_product_controller.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class AllProducts extends StatelessWidget {
  const AllProducts({
    super.key,
    required this.title,
    this.query,
    this.futureMethod,
  });

  final String title;
  final Query? query;
  final Future<List<ProductModel>>? futureMethod;

  @override
  Widget build(BuildContext context) {
    Get.put(AllProductController());

    return Scaffold(
      appBar: TAppbar(title: Text(title), showBackArrow: true),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: const TSortProducts(),
      ),
    );
  }
}









/*
class AllProducts extends StatelessWidget {
  // ... المتغيرات الحالية ...
  const AllProducts({
    super.key,
    required this.title,
    this.query,
    this.futureMethod,
  });

  final String title;
  final Query? query;
  final Future<List<ProductModel>>? futureMethod;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllProductController());

    return Scaffold(
      appBar: TAppbar(title: Text(title), showBackArrow: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
        child: FutureBuilder(
          future: futureMethod ?? controller.fetchProductsByQuery(query),
          builder: (context, snapshot) {
            final widget = TCloudHelperFunctions.checkMultiRecordState(
              snapshot: snapshot,
              loader: const VerticalProductShimmer(),
            );
            if (widget != null) return widget;

            return SingleChildScrollView(
              controller: controller.scrollController, // ربط السكرول هنا
              child: Column(
                children: [
                  TSortProducts(products: controller.products),

                  // مؤشر تحميل عند جلب بيانات إضافية
                  Obx(
                    () => controller.isLoading.value
                        ? const Padding(
                            padding: EdgeInsets.all(TSizes.defaultSpace),
                            child: CircularProgressIndicator(),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
*/








/*
class AllProducts extends StatelessWidget {
  const AllProducts({
    super.key,
    required this.title,
    this.query,
    this.futureMethod,
  });

  final String title;
  final Query? query;
  final Future<List<ProductModel>>? futureMethod;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllProductController());
    return Scaffold(
      appBar: TAppbar(title: Text(title), showBackArrow: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: futureMethod ?? controller.fetchProductsByQuery(query),
            builder: (context, snapshot) {
              const loader = VerticalProductShimmer();

              final widget = TCloudHelperFunctions.checkMultiRecordState(
                snapshot: snapshot,
                loader: loader,
              );
              if (widget != null) return widget;

              final products = snapshot.data!;
              return TSortProducts(products: products);
            },
          ),
        ),
      ),
    );
  }
}
*/