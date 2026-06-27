import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/chip/choice_chip.dart';
import 'package:untitled2_ecom/common/widgets/contaniners/rounded_container.dart';
import 'package:untitled2_ecom/common/widgets/texts/TProductsTitleText.dart';
import 'package:untitled2_ecom/common/widgets/texts/section_heading.dart';
import 'package:untitled2_ecom/common/widgets/texts/text_price_detail.dart';
import 'package:untitled2_ecom/common/widgets/texts/textproductdetail.dart';
import 'package:untitled2_ecom/features/shop/controllers/product/variation_controller.dart';
import 'package:untitled2_ecom/features/shop/models/product_model.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/utils/helpers/exports.dart';

class TProductAttributs extends StatelessWidget {
  const TProductAttributs({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);
    final controller = VariationController.instance;
    return Obx(
      () => Column(
        children: [
          if (controller.selectedVariation.value.id.isNotEmpty) ...[
            const SizedBox(height: TSizes.spaceBtwItems),
            TRoundedContainer(
              padding: EdgeInsets.all(TSizes.md),
              backgroundColor: dark ? TColors.cardLight : TColors.grey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      sectionHeading(
                        labelText: "الخيار",
                        showButtton: false,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: TSizes.spaceBtwItems),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TTextPriceDetail(
                            labele: "السعر",
                            oldPrice:
                                "${controller.selectedVariation.value.price}",
                            newPrice: controller.getVariationPrice(),
                          ),
                          TTextProductDetail(
                            title: "المخزون",
                            subTitle: controller.variationStockStats.value,
                          ),
                        ],
                      ),
                    ],
                  ),
                  TproductText(
                    title: controller.selectedVariation.value.description ?? "",
                    smallSize: true,
                    maxLine: 4,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: TSizes.spaceBtwItems),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: product.productAttribute!
                .map(
                  (attribute) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionHeading(
                        labelText: attribute.name ?? "",
                        showButtton: false,
                        padding: EdgeInsets.all(0),
                      ),
                      SizedBox(height: TSizes.spaceBtwItems / 2),
                      Obx(
                        () => Wrap(
                          spacing: 8,
                          children: attribute.values!.map((value) {
                            final isSelected =
                                controller.selectedAttributes[attribute.name] ==
                                value;
                            final available = controller
                                .getAttributesAvailableInVariation(
                                  product.productVariation!,
                                  attribute.name!,
                                )
                                .contains(value);
                            return TChoiceChip(
                              text: value,
                              selected: isSelected,
                              onSelected: available
                                  ? (selected) {
                                      if (selected && available) {
                                        controller.onAttributeSelected(
                                          product,
                                          attribute.name ?? "",
                                          value,
                                        );
                                      }
                                    }
                                  : null,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),

          /*  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeading(
                labelText: "المقاس",
                showButtton: false,
                padding: EdgeInsets.all(0),
              ),
              SizedBox(height: TSizes.spaceBtwItems / 2),
              Wrap(
                spacing: 8,
                children: [
                  TChoiceChip(
                    text: "EU 34",
                    selected: false,
                    onSelected: (p0) {},
                  ),
                  TChoiceChip(text: "EU 36", selected: true, onSelected: (p0) {}),
                  TChoiceChip(text: "EU 38", selected: true, onSelected: (p0) {}),
                ],
              ),
            ],
          ),
        */
        ],
      ),
    );
  }
}
