import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';

import 'quadrilateral_corners.dart';

/// In geometry a quadrilateral is a four-sided polygon, having
/// four edges (sides) and four [corners] (vertices).
class Quadrilateral {
  const Quadrilateral({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  final Offset bottomLeft;
  final Offset bottomRight;
  final Offset topLeft;
  final Offset topRight;

  @override
  bool operator ==(Object other) =>
      other is Quadrilateral &&
      super == other &&
      other.topRight == topRight &&
      other.topLeft == topLeft &&
      other.bottomRight == bottomRight &&
      other.bottomLeft == bottomLeft;

  @override
  int get hashCode => hashValues(topRight, topLeft, bottomRight, bottomLeft);

  @override
  String toString() =>
      '''topLeft: $topLeft, topRight: $topRight, bottomRight: $bottomRight, bottomLeft: $bottomLeft''';

  List<Offset> get corners =>
      List<Offset>.unmodifiable([topLeft, topRight, bottomRight, bottomLeft]);

  List<Offset> localCorners(double padding) {
    final List<double> distances = [];
    for (final corner in corners) {
      distances.add((Offset.zero - corner).distance);
    }

    final paddedOffset = Offset(padding, padding);
    final corner = QuadrilateralCornersX.fromMinimum(distances);
    final value = corner.cornerValue(this);
    final local = Offset.zero - value + paddedOffset;
    return List<Offset>.unmodifiable([
      topLeft + local,
      topRight + local,
      bottomRight + local,
      bottomLeft + local,
    ]);
  }

  Offset centroid([double padding = 0]) {
    final dxs = corners.map((corner) => corner.dx).sum;
    final dys = corners.map((corner) => corner.dy).sum;
    final dx = dxs / corners.length;
    final dy = dys / corners.length;
    
    return Offset(dx - padding, dy - padding);
  }

  double get height {
    final dys = corners.map((corner) => corner.dy);
    final maximum = dys.reduce(max);
    final minimum = dys.reduce(min);

    return maximum - minimum;
  }

  double get width {
    final dxs = corners.map((corner) => corner.dx);
    final maximum = dxs.reduce(max);
    final minimum = dxs.reduce(min);

    return maximum - minimum;
  }

  Size get size => Size(width, height);

  Quadrilateral copyWith({
    Offset? topLeft,
    Offset? topRight,
    Offset? bottomRight,
    Offset? bottomLeft,
  }) =>
      Quadrilateral(
        topLeft: topLeft ?? this.topLeft,
        topRight: topRight ?? this.topRight,
        bottomRight: bottomRight ?? this.bottomRight,
        bottomLeft: bottomLeft ?? this.bottomLeft,
      );

  static Quadrilateral fromRect(Rect rect) => Quadrilateral(
        topLeft: rect.topLeft,
        topRight: rect.topRight,
        bottomRight: rect.bottomRight,
        bottomLeft: rect.bottomLeft,
      );
}
