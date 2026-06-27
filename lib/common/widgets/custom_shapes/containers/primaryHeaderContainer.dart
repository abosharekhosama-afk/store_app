import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class TPrimaryHeaderContainer extends StatelessWidget {
  const TPrimaryHeaderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // الحاوية الآن تمرر الـ child مباشرة لأن الخلفية والمنحنيات يتم رسمها في الـ SliverAppBar ديناميكياً
    return child;
  }
}
