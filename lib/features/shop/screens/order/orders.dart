import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/features/shop/screens/order/orders_list.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';

class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color(0xFFF8F9FB), // لون خلفية هادئ وعصري
      appBar: TAppbar(title: Text("طلباتي"), showBackArrow: true),
      body: Padding(
        padding: EdgeInsets.all(TSizes.defaultSpace),
        child: OrdersList(),
      ),
    );
  }
}
