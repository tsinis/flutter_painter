import 'package:flutter/rendering.dart';

import '../drawables/shape/quadrilateral_drawable.dart';
import 'shape_factory.dart';

/// A [QuadrilateralDrawable] factory.
class QuadrilateralFactory extends ShapeFactory<QuadrilateralDrawable> {
  List<Offset>? coordinates;

  /// Creates an instance of [QuadrilateralFactory].
  QuadrilateralFactory({this.coordinates});

  /// Creates and returns a [QuadrilateralDrawable] of zero size and the passed [position] and [paint].
  @override
  QuadrilateralDrawable create(Offset position, [Paint? paint]) =>
      QuadrilateralDrawable(
        size: Size.zero,
        position: position,
        paint: paint,
      );
}
