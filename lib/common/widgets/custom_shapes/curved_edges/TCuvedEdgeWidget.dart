import 'package:flutter/cupertino.dart';
import 'package:untitled2_ecom/common/widgets/custom_shapes/curved_edges/curved_edget.dart';

class TCuvedEdgeWidget extends StatelessWidget {
  const TCuvedEdgeWidget({super.key, this.child});

  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return ClipPath(clipper: TCustomCurvedEdges(), child: child);
  }
}
