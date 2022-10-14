import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const FlutterPainterExample(),
    );
  }
}

class FlutterPainterExample extends StatefulWidget {
  const FlutterPainterExample({Key? key}) : super(key: key);

  @override
  _FlutterPainterExampleState createState() => _FlutterPainterExampleState();
}

class _FlutterPainterExampleState extends State<FlutterPainterExample> {
  static const Color red = ui.Color.fromARGB(255, 0, 0, 0);
  FocusNode textFocusNode = FocusNode();
  late PainterController controller;
  ui.Image? backgroundImage;
  Paint shapePaint = Paint()..color = red;

  @override
  void initState() {
    super.initState();
    controller = PainterController(
      settings: PainterSettings(
        shape: ShapeSettings(paint: shapePaint),
      ),
    );
    // Listen to focus events of the text field
    textFocusNode.addListener(onFocus);
    // Initialize background
    initBackground();
  }

  /// Fetches image from an [ImageProvider] (in this example, [NetworkImage])
  /// to use it as a background
  void initBackground() async {
    // Extension getter (.image) to get [ui.Image] from [ImageProvider]
    final image =
        await const NetworkImage('https://picsum.photos/id/111/3000/1996')
            .image;

    setState(() {
      backgroundImage = image;
      controller.background = image.backgroundDrawable;
    });
  }

  /// Updates UI when the focus changes
  void onFocus() {
    setState(() {});
  }

  Widget buildDefault(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, kToolbarHeight),
          // Listen to the controller and update the UI when it updates.
          child: ValueListenableBuilder<PainterControllerValue>(
              valueListenable: controller,
              child: const Text("Quadrilateral"),
              builder: (context, _, child) {
                return AppBar(
                  title: child,
                  actions: [
                    ValueListenableBuilder(
                      valueListenable: controller,
                      builder: (context, _, __) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Add shapes
                          if (controller.shapeFactory == null)
                            PopupMenuButton<ShapeFactory?>(
                              tooltip: "Add shape",
                              itemBuilder: (context) => <ShapeFactory, String>{
                                QuadrilateralFactory(): "Rectangle",
                                OvalFactory(): "Oval",
                              }
                                  .entries
                                  .map(
                                    (e) => PopupMenuItem(
                                      value: e.key,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            getShapeIcon(e.key),
                                            color: Colors.black,
                                          ),
                                          Text(" ${e.value}")
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onSelected: selectShape,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  getShapeIcon(controller.shapeFactory),
                                  color: controller.shapeFactory != null
                                      ? Theme.of(context).colorScheme.secondary
                                      : null,
                                ),
                              ),
                            )
                          else
                            IconButton(
                              icon: Icon(
                                getShapeIcon(controller.shapeFactory),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () => selectShape(null),
                            ),
                        ],
                      ),
                    ),
                    // Delete the selected drawable
                    IconButton(
                      icon: const Icon(
                        PhosphorIcons.trash,
                      ),
                      onPressed: controller.selectedObjectDrawable == null
                          ? null
                          : removeSelectedDrawable,
                    ),
                    // Redo action
                    IconButton(
                      icon: const Icon(
                        PhosphorIcons.arrowClockwise,
                      ),
                      onPressed: controller.canRedo ? redo : null,
                    ),
                    // Undo action
                    IconButton(
                      icon: const Icon(
                        PhosphorIcons.arrowCounterClockwise,
                      ),
                      onPressed: controller.canUndo ? undo : null,
                    ),
                  ],
                );
              }),
        ),
        // Generate image
        floatingActionButton: FloatingActionButton(
          child: const Icon(
            PhosphorIcons.imageFill,
          ),
          onPressed: renderAndDisplayImage,
        ),
        body: Stack(
          children: [
            if (backgroundImage != null)
              // Enforces constraints
              Positioned.fill(
                child: Center(
                  child: AspectRatio(
                    aspectRatio:
                        backgroundImage!.width / backgroundImage!.height,
                    child: FlutterPainter(
                      controller: controller,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildDefault(context);
  }

  static IconData getShapeIcon(ShapeFactory? shapeFactory) {
    if (shapeFactory is OvalFactory) return PhosphorIcons.circle;
    return PhosphorIcons.rectangle;
  }

  void undo() {
    controller.undo();
  }

  void redo() {
    controller.redo();
  }

  void selectShape(ShapeFactory? factory) {
    controller.shapeFactory = factory;
  }

  void setShapeFactoryPaint(Paint paint) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.shapePaint = paint;
    });
  }

  void renderAndDisplayImage() {
    if (backgroundImage == null) return;
    final backgroundImageSize = Size(
        backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble());

    // Render the image
    // Returns a [ui.Image] object, convert to to byte data and then to Uint8List
    final imageFuture = controller
        .renderImage(backgroundImageSize)
        .then<Uint8List?>((ui.Image image) => image.pngBytes);

    // From here, you can write the PNG image data a file or do whatever you want with it
    // For example:
    // ```dart
    // final file = File('${(await getTemporaryDirectory()).path}/img.png');
    // await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    // ```
    // I am going to display it using Image.memory

    // Show a dialog with the image
    showDialog(
        context: context,
        builder: (context) => RenderedImageDialog(imageFuture: imageFuture));
  }

  void removeSelectedDrawable() {
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable != null) controller.removeDrawable(selectedDrawable);
  }

  void flipSelectedImageDrawable() {
    final imageDrawable = controller.selectedObjectDrawable;
    if (imageDrawable is! ImageDrawable) return;

    controller.replaceDrawable(
        imageDrawable, imageDrawable.copyWith(flipped: !imageDrawable.flipped));
  }
}

class RenderedImageDialog extends StatelessWidget {
  final Future<Uint8List?> imageFuture;

  const RenderedImageDialog({Key? key, required this.imageFuture})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Rendered Image"),
      content: FutureBuilder<Uint8List?>(
        future: imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox();
          }
          return InteractiveViewer(
              maxScale: 10, child: Image.memory(snapshot.data!));
        },
      ),
    );
  }
}
