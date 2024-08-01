import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../object_drawable.dart';
import '../sized2ddrawable.dart';
import 'shape_drawable.dart';

/// A drawable of a polygon made with nodes (vertices) from user input.
class NodePolygonDrawable extends Sized2DDrawable implements ShapeDrawable {
  /// The paint to be used for the polygon drawable.
  @override
  Paint paint;

  /// Creates a new [NodePolygonDrawable] with the given [size], [paint] and [vertices].
  NodePolygonDrawable({
    required this.vertices,
    required super.size,
    required super.position,
    Paint? paint,
    super.rotationAngle,
    super.scale,
    super.assists,
    super.assistPaints,
    super.locked,
    super.hidden,
    Offset? shiftOffset,
    this.polygonCloseRadius,
  })  : paint = paint ?? ShapeDrawable.defaultPaint,
        _shiftOffset = shiftOffset;

  /// {@macro polygon_close_radius}
  final double? polygonCloseRadius;

  /// List of vertices (coordinates) from which the polygon will be constructed.
  final List<Offset> vertices;

  /// Helper field allowing to work with the object as a geometric
  /// shape (move, rotate, resize). Only used internally.
  final Offset? _shiftOffset;

  /// Getter for padding of drawable.
  ///
  /// Add padding equal to the stroke width of the paint.
  @protected
  @override
  EdgeInsets get padding => EdgeInsets.all(paint.strokeWidth / 2);

  /// Draws the polygon on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    if (vertices.isEmpty) return; // Nothing to draw.
    final path = Path() // Draw a polygon on specific position.
      ..moveTo(vertices.first.dx, vertices.first.dy)
      ..addPolygon(vertices, isClosed);

    /// Moves the polygon if it was manually moved/rotated.
    final shiftedPath = _shiftOffset == null ? path : path.shift(_shiftOffset);

    /// Scales the polygon if it was manually scaled.
    final scalingMatrix4 = Float64List.fromList(
        [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 / scale]);
    final scaledPath = shiftedPath.transform(scalingMatrix4);
    canvas.drawPath(scaledPath, paint);
  }

  /// Determines if it is a closed polygon
  /// (i.e. if the first vertex is the same as the last vertex).
  bool get isClosed {
    if (vertices.isEmpty) return false;
    return vertices.first == vertices.last;
  }

  /// A helper method that allows to assign a vertex of the polygon
  /// to the first one, if it is within the specified [polygonCloseRadius].
  bool _shouldBeClosed(Offset? vertex) {
    if (polygonCloseRadius == null) return false;
    if (vertex == null || vertices.isEmpty) return false;
    final distance = (vertices.first - vertex).distance;

    return distance <= polygonCloseRadius!;
  }

  /// It is mainly used in the PolygonDrawWidget for the initial calculation of
  /// the new position (of [this] polygon when the new vertex has been added).
  NodePolygonDrawable updateWith({
    List<Offset>? vertices,
    Offset? vertex,
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Paint? paint,
    bool? locked,
    Size? size,
    Offset? shiftOffset,
    double? polygonCloseRadius,
  }) {
    final newVertex = _shouldBeClosed(vertex) ? this.vertices.first : vertex;
    final drawable = copyWith(
      paint: paint ?? this.paint,
      vertices: newVertex != null
          ? [...this.vertices, newVertex]
          : vertices ?? this.vertices,
    );
    return NodePolygonDrawable(
      position: position ?? drawable.centroid,
      size: size ?? drawable.getSize(),
      vertices: drawable.vertices,
      paint: drawable.paint,
      scale: scale ?? this.scale,
      locked: locked ?? this.locked,
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      rotationAngle: rotation ?? rotationAngle,
      shiftOffset: shiftOffset ?? _shiftOffset,
      polygonCloseRadius: polygonCloseRadius ?? this.polygonCloseRadius,
    );
  }

  /// Creates a copy of [this] but with the given fields replaced with the new values.
  @override
  NodePolygonDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Size? size,
    Paint? paint,
    bool? locked,
    List<Offset>? vertices,
    double? polygonCloseRadius,
  }) {
    final isPanEnd = position == null && (assists?.isEmpty ?? false);
    final newPosition = centroid;
    final shift = (position ?? Offset.zero) - newPosition;
    return NodePolygonDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      position: position != null ? newPosition + shift : this.position,
      polygonCloseRadius: polygonCloseRadius ?? this.polygonCloseRadius,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      size: size ?? this.size,
      paint: paint ?? this.paint,
      locked: locked ?? this.locked,
      vertices: vertices ?? this.vertices,
      shiftOffset: isPanEnd
          ? _shiftOffset
          : position != null
              ? shift / (scale ?? 1)
              : this.position,
    );
  }

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    if (vertices.isEmpty) {
      final superSize = super.getSize();
      return Size(superSize.width, superSize.height);
    } else {
      return Size(width * scale, height * scale);
    }
  }

  /// Geometric center of a [NodePolygonDrawable], which might not be very
  /// accurate (since polygon can has a lot [vertices]), but should be pretty
  /// fast to calculate in the runtime.
  /// https://en.wikipedia.org/wiki/Centroid#Of_a_polygon
  Offset get centroid {
    final verticesList = List.of(vertices);
    if (isClosed) verticesList.removeLast();
    final dxSum = verticesList.map((vertex) => vertex.dx * scale).sum;
    final dySum = verticesList.map((vertex) => vertex.dy * scale).sum;
    final dx = dxSum / verticesList.length;
    final dy = dySum / verticesList.length;

    return Offset(dx, dy);
  }

  /// Height of the polygon. It calculates the distance between the highest
  /// vertex and the lowest vertex (their 'Y' coordinate).
  double get height {
    final dys = vertices.map((vertex) => vertex.dy);
    final maximum = dys.reduce(max);
    final minimum = dys.reduce(min);

    return maximum - minimum;
  }

  /// Width of the polygon. It calculates the distance between two
  /// horizontal edge points (their 'X' coordinate).
  double get width {
    final dxs = vertices.map((vertex) => vertex.dx);
    final maximum = dxs.reduce(max);
    final minimum = dxs.reduce(min);

    return maximum - minimum;
  }

  /// Compares two [NodePolygonDrawable]s for equality.
  @override
  bool operator ==(Object other) {
    if (other is! NodePolygonDrawable) return false;
    final isSame = other.scale == scale &&
        other.position == position &&
        other.size == size &&
        other._shiftOffset == _shiftOffset &&
        other.assists.length == assists.length &&
        (const ListEquality().equals(vertices, other.vertices)) &&
        other.paint == paint;

    return isSame;
  }

  @override
  String toString() => '''NodePolygonDrawable(
vertices: $vertices,
size: $size,
hidden: $hidden,
locked: $locked,
assists: $assists,
assistPaints: ${assistPaints.entries},
position: $position,
rotationAngle: $rotationAngle,
scale: $scale,
paint: $paint,
shiftOffset: $_shiftOffset,
)''';

  @override
  int get hashCode => Object.hash(
        hidden,
        locked,
        Object.hashAll(assists),
        Object.hashAll(assistPaints.entries),
        rotationAngle,
        scale,
        paint,
        position,
        size,
        vertices,
      );
}
