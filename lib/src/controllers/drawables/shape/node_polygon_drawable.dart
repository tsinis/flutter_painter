import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../object_drawable.dart';
import '../sized2ddrawable.dart';
import 'shape_drawable.dart';

/// A drawable of a rectangle with a radius.
class NodePolygonDrawable extends Sized2DDrawable implements ShapeDrawable {
  /// The paint to be used for the line drawable.
  @override
  Paint paint;

  /// Creates a new [NodePolygonDrawable] with the given [size], [paint] and [borderRadius].
  NodePolygonDrawable({
    required this.vertices,
    required Size size,
    required Offset position,
    Paint? paint,
    double rotationAngle = 0,
    double scale = 1,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
  })  : paint = paint ?? ShapeDrawable.defaultPaint,
        super(
          size: size,
          position: position,
          rotationAngle: rotationAngle,
          scale: scale,
          assists: assists,
          assistPaints: assistPaints,
          locked: locked,
          hidden: hidden,
        );

  final List<Offset> vertices;

  /// Getter for padding of drawable.
  ///
  /// Add padding equal to the stroke width of the paint.
  @protected
  @override
  EdgeInsets get padding => EdgeInsets.all(paint.strokeWidth / 2);

  /// Draws the arrow on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    if (vertices.isEmpty) return;
    final path = Path()..moveTo(vertices.first.dx, vertices.first.dy);
    for (int i = 0; i < vertices.length; i++) {
      final end = i + 1 == vertices.length ? vertices.first : vertices[i + 1];
      path.lineTo(end.dx, end.dy);
      // if (showHandlers) {
      //   final start = vertices.elementAt(i);
      //   final dx = start.dx;
      //   final dy = start.dy;
      //   canvas.drawCircle(
      //     Offset(dx, dy),
      //     handlersSize,
      //     Paint()..color = handlersColor,
      //   );
      // }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

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
  }) {
    final newDrawable = copyWith(
      vertices: (vertex != null ? [...this.vertices, vertex] : vertices) ??
          this.vertices,
    );
    final newSize = size ?? newDrawable.getSize();
    final newPosition = position ?? newDrawable.centroid(paint?.strokeWidth);
    return NodePolygonDrawable(
      vertices: newDrawable.vertices,
      position: newPosition,
      size: newSize,
      paint: paint ?? this.paint,
      scale: scale ?? this.scale,
      locked: locked ?? this.locked,
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      rotationAngle: rotation ?? rotationAngle,
    );
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
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
    Offset? vertex,
  }) {
    return NodePolygonDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      size: size ?? this.size,
      paint: paint ?? this.paint,
      locked: locked ?? this.locked,
      vertices: vertices ?? this.vertices,
    );
  }

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    if (vertices.isEmpty) {
      final superSize = super.getSize();
      return Size(superSize.width, superSize.height);
    } else {
      return Size(width, height);
    }
  }

  Offset centroid([double? padding]) {
    final dxs = vertices.map((vertex) => vertex.dx).sum;
    final dys = vertices.map((vertex) => vertex.dy).sum;
    final dx = dxs / vertices.length;
    final dy = dys / vertices.length;

    if (padding == null) return Offset(dx, dy);
    return Offset(dx - (padding / 2), dy + (padding / 2));
  }

  double get height {
    final dys = vertices.map((vertex) => vertex.dy);
    final maximum = dys.reduce(max);
    final minimum = dys.reduce(min);

    return maximum - minimum;
  }

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
  )
  ''';

  @override
  int get hashCode => hashValues(
        hidden,
        locked,
        hashList(assists),
        hashList(assistPaints.entries),
        rotationAngle,
        scale,
        paint,
        position,
        size,
        vertices,
      );
}