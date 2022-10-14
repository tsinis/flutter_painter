import 'package:flutter/material.dart';

import '../../../models/quadrilateral.dart';
import '../../../models/quadrilateral_corners.dart';
import '../object_drawable.dart';
import '../sized2ddrawable.dart';
import 'shape_drawable.dart';

/// A drawable of a rectangle with a radius.
class QuadrilateralDrawable extends Sized2DDrawable implements ShapeDrawable {
  /// Creates a new [QuadrilateralDrawable] with the given [size], and [paint].
  QuadrilateralDrawable({
    this.quadrilateral,
    this.handlersSize = 10,
    this.handlersColor = const Color.fromARGB(125, 255, 200, 0),
    Paint? paint,
    required Size size,
    required Offset position,
    double rotationAngle = 0,
    double scale = 1,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
    this.showHandlers = false,
    QuadrilateralCorners? selectedCorner,
  })  : paint = paint ?? ShapeDrawable.defaultPaint,
        currentCorner = selectedCorner,
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

  final double handlersSize;
  final Color handlersColor;
  final bool showHandlers;

  Quadrilateral? quadrilateral;
  QuadrilateralCorners? currentCorner;

  static QuadrilateralDrawable? maybe(ObjectDrawable? drawable) {
    if (drawable is QuadrilateralDrawable) return drawable;
    return null;
  }

  List<Offset>? get corners => quadrilateral?.localCorners(handlersSize);

  /// The paint to be used for the line drawable.
  @override
  Paint paint;

  /// Getter for padding of drawable.
  ///
  /// Add padding equal to the stroke width of the paint.
  @protected
  @override
  EdgeInsets get padding => EdgeInsets.all(handlersSize / 2);

  /// Draws the arrow on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    if (currentCorner == null) {
      final drawingSize = this.size * scale;

      quadrilateral = Quadrilateral.fromRect(
        Rect.fromCenter(
          center: position,
          width: drawingSize.width,
          height: drawingSize.height,
        ),
      );
    }

    _drawQuadrilateral(canvas);
  }

  QuadrilateralDrawable? updateCorner(Offset offset) {
    Quadrilateral? newQuadrilateral;
    switch (currentCorner) {
      case null:
        return null;
      case QuadrilateralCorners.topLeft:
        newQuadrilateral = quadrilateral?.copyWith(topLeft: offset);
        break;
      case QuadrilateralCorners.topRight:
        newQuadrilateral = quadrilateral?.copyWith(topRight: offset);
        break;
      case QuadrilateralCorners.bottomRight:
        newQuadrilateral = quadrilateral?.copyWith(bottomRight: offset);
        break;
      case QuadrilateralCorners.bottomLeft:
        newQuadrilateral = quadrilateral?.copyWith(bottomLeft: offset);
        break;
    }

    return copyWith(
      quadrilateral: newQuadrilateral,
      size: newQuadrilateral?.size,
    );
  }

  void _drawQuadrilateral(Canvas canvas, {double padding = 0}) {
    final points = quadrilateral?.corners;
    if (points == null) return;
    final path = Path()
      ..moveTo(
        points.first.dx + padding,
        points.first.dy + padding,
      );
    for (int i = 0; i < points.length; i++) {
      final end = i + 1 == points.length ? points.first : points[i + 1];
      path.lineTo(end.dx + padding, end.dy + padding);
      if (showHandlers) {
        final start = points.elementAt(i);
        final dx = start.dx + padding;
        final dy = start.dy + padding;
        canvas.drawCircle(
          Offset(dx, dy),
          handlersSize,
          Paint()..color = handlersColor,
        );
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  QuadrilateralDrawable copyWith({
    Quadrilateral? quadrilateral,
    QuadrilateralCorners? currentCorner,
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Size? size,
    Paint? paint,
    bool? locked,
    bool? showHandlers,
  }) =>
      QuadrilateralDrawable(
        quadrilateral: quadrilateral ?? this.quadrilateral,
        selectedCorner: currentCorner ?? this.currentCorner,
        showHandlers: showHandlers ?? this.showHandlers,
        hidden: hidden ?? this.hidden,
        assists: assists ?? this.assists,
        position: position ?? this.position,
        rotationAngle: rotation ?? rotationAngle,
        scale: scale ?? this.scale,
        size: size ?? this.size,
        paint: paint ?? this.paint,
        locked: locked ?? this.locked,
      );

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    if (quadrilateral == null || showHandlers) {
      final superSize = super.getSize();
      return Size(superSize.width, superSize.height);
    }
    final quadrilateralSize = quadrilateral!.size;
    // return Size(
    //   (quadrilateral!.width * scale + padding.horizontal)
    //       .clamp(0, double.infinity),
    //   (quadrilateral!.height * scale + padding.vertical)
    //       .clamp(0, double.infinity),
    // );
    print('QUADRILATERALSIZE: $quadrilateralSize');
    // return quadrilateralSize;
    return Size(
      ((quadrilateral!.width * scale) + (handlersSize * 2))
          .clamp(minWidth, maxWidth),
      ((quadrilateral!.height * scale) + (handlersSize * 2))
          .clamp(minWidth, maxWidth),
    );
  }

  /// Compares two [QuadrilateralDrawable]s for equality.
  @override
  bool operator ==(Object other) =>
      other is QuadrilateralDrawable &&
      super == other &&
      other.paint == paint &&
      other.size == size &&
      other.showHandlers == showHandlers;

  @override
  String toString() => '''
    hidden: $hidden,
    locked: $locked,
    assists: $assists,
    assistPaints: ${assistPaints.entries},
    position: $position,
    rotationAngle: $rotationAngle,
    scale: $scale,
    paint: $paint,
    size: $size,
    showHandlers: $showHandlers,
    quadrilateral: $quadrilateral,
    currentCorner: $currentCorner
    ''';

  @override
  int get hashCode => hashValues(
        hidden,
        locked,
        hashList(assists),
        hashList(assistPaints.entries),
        position,
        rotationAngle,
        scale,
        paint,
        size,
        showHandlers,
      );
}
