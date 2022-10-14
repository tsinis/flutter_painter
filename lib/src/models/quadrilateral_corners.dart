import 'dart:math';
import 'dart:ui';

import 'package:flutter_painter/src/models/quadrilateral.dart';

enum QuadrilateralCorners { topLeft, topRight, bottomRight, bottomLeft }

extension QuadrilateralCornersX on QuadrilateralCorners {
  static QuadrilateralCorners fromMinimum(List<double> distances) {
    final minimum = distances.reduce(min);
    return QuadrilateralCorners.values.elementAt(distances.indexOf(minimum));
  }

  Offset cornerValue(Quadrilateral quadrilateral) {
    switch (this) {
      case QuadrilateralCorners.topLeft:
        return quadrilateral.topLeft;
      case QuadrilateralCorners.topRight:
        return quadrilateral.topRight;
      case QuadrilateralCorners.bottomLeft:
        return quadrilateral.bottomLeft;
      case QuadrilateralCorners.bottomRight:
        return quadrilateral.bottomRight;
    }
  }
}
