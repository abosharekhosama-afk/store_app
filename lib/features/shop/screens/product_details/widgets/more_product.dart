import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/product_controller.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/features/shop/screens/product_details/widgets/similar_product_card.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class MoreProduct extends StatelessWidget {
  const MoreProduct({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    final List<ProductModel> products = controller.activeSimilarProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const sectionHeading(
          labelText: "قد يعجبك أيضاً",
          showButtton: false,
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        // تم ضبط الارتفاع ليكون 285 بكسل وهو متناسق جداً مع أبعاد الكارد الجديدة (180 عرض × 170 ارتفاع صورة)
        SizedBox(
          height: 285,
          child: ListView.separated(
            itemCount: products.length,
            scrollDirection: Axis.horizontal,
            physics:
                const BouncingScrollPhysics(), // يعطي نعومة وارتداد عند السحب الفائق على الشاشة
            separatorBuilder: (context, index) =>
                const SizedBox(width: TSizes.spaceBtwItems),
            itemBuilder: (context, index) =>
                TSimilarProductCard(product: products[index]),
          ),
        ),
      ],
    );
  }
}

/*
class MoreProduct extends StatelessWidget {
  const MoreProduct({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    // 🌟 تم نقل الجلب إلى الواجهة العليا؛ هنا نقرأ القائمة المفلترة مباشرة بأمان
    final List<ProductModel> products = controller.activeSimilarProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const sectionHeading(
          labelText: "قد يعجبك أيضاً",
          showButtton: false,
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        SizedBox(
          height: 285,
          child: ListView.separated(
            itemCount: products.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            separatorBuilder: (context, index) =>
                const SizedBox(width: TSizes.spaceBtwItems),
            itemBuilder: (context, index) =>
                TSimilarProductCard(product: products[index]),
          ),
        ),
      ],
    );
  }
}
*/

/*
class MoreProduct extends StatelessWidget {
  const MoreProduct({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    //controller.fetchSimelarProducts(product.categoryId, product.id, product);
    final List<ProductModel> products = controller.simaelerProducts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const sectionHeading(
          labelText: "قد يعجبك أيضاً",
          showButtton: true, // تفعيل الزر لعرض الكل
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        SizedBox(
          height: 285, // الارتفاع المناسب للبطاقة
          child: ListView.separated(
            itemCount: products.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            separatorBuilder: (context, index) =>
                const SizedBox(width: TSizes.spaceBtwItems),
            itemBuilder: (context, index) =>
                TSimilarProductCard(product: products[index]),
          ),
        ),
      ],
    );
  }
}
*/
