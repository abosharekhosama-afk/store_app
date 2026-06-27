import 'package:flutter/material.dart';
import 'package:untitled2_ecom/common/widgets/layouts/grid_layout.dart';
import 'package:untitled2_ecom/common/widgets/shimmers/shimmer.dart';

class TBrandShimmer extends StatelessWidget {
  const TBrandShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return TGridLayout(
      itemCount: itemCount,
      mainAxisExtent: 80,
      itemBuilder: (p0, p1) => TShimmerEffect(width: 300, height: 80),
    );
  }
}
