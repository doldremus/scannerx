import 'dart:async';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:scannerx/scannerx.dart';
import 'package:flutter/material.dart';

class BarcodeDetector extends StatefulWidget {
  const BarcodeDetector({
    required this.description,
    required this.barcodesStream,
    this.onDetected,
    this.drawDebug = false,
    super.key,
  });

  final ScannerDescription description;
  final Stream<List<Barcode>> barcodesStream;
  final void Function(List<Barcode> barcodes)? onDetected;
  final bool drawDebug;

  @override
  State<BarcodeDetector> createState() => _BarcodeDetectorState();
}

class _BarcodeDetectorState extends State<BarcodeDetector> {
  late StreamController<DetectorData> detectorStreamController;
  StreamSubscription? subscription;
  late DetectorRect detectorRect;

  @override
  void initState() {
    super.initState();
    detectorRect = DetectorRect(widget.description, 0.7);
    detectorStreamController = StreamController.broadcast();
    subscription = widget.barcodesStream.listen(onBarcodes);
  }

  @override
  void dispose() {
    subscription?.cancel();
    detectorStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: Overlay(context: context, detectorRect: detectorRect),
        ),
        if (widget.drawDebug)
          StreamBuilder(
              stream: detectorStreamController.stream,
              builder: (context, val) {
                return CustomPaint(
                  painter: BarcodeDetectorPainter(
                    context: context,
                    description: widget.description,
                    data: val.data,
                  ),
                );
              }),
      ],
    );
  }

  onBarcodes(List<Barcode> barcodes) {
    final List<Barcode> insideRectBarcodes = [];
    final List<Barcode> outsideRectBarcodes = [];

    for (final barcode in barcodes) {
      if (isInRect(barcode)) {
        insideRectBarcodes.add(barcode);
        break;
      }
      outsideRectBarcodes.add(barcode);
    }

    if (widget.onDetected != null && insideRectBarcodes.isNotEmpty) {
      widget.onDetected!(insideRectBarcodes);
    }

    if (!widget.drawDebug || detectorStreamController.isClosed) return;
    detectorStreamController.add(DetectorData(insideRectBarcodes, outsideRectBarcodes));
  }

  bool isInRect(Barcode barcode) {
    if (barcode.displaySpaceCorners == null) return false;

    for (final corner in barcode.displaySpaceCorners!) {
      if (corner.dx < detectorRect.leftBorder || corner.dx > detectorRect.rightBorder) {
        return false;
      }
      if (corner.dy < detectorRect.topBorder || corner.dy > detectorRect.bottomBorder) {
        return false;
      }
    }
    return true;
  }
}

class DetectorRect {
  DetectorRect(ScannerDescription description, this.faction) {
    rectSize = description.viewSize.width * faction;
    leftBorder = (description.viewSize.width - rectSize) / 2;
    rightBorder = (description.viewSize.width - rectSize) / 2 + rectSize;
    topBorder = (description.viewSize.height - rectSize) / 2;
    bottomBorder = (description.viewSize.height - rectSize) / 2 + rectSize;
  }

  final double faction;
  late double rectSize;
  late double leftBorder;
  late double rightBorder;
  late double topBorder;
  late double bottomBorder;
}

class DetectorData {
  DetectorData(this.insideRectBarcodes, this.outsideRectBarcodes);

  List<Barcode> insideRectBarcodes;
  List<Barcode> outsideRectBarcodes;
}

class BarcodeDetectorPainter extends CustomPainter {
  BarcodeDetectorPainter({required this.context, required this.description, this.data});

  final BuildContext context;
  final ScannerDescription description;
  final DetectorData? data;

  @override
  void paint(Canvas canvas, Size size) {
    if (data == null) return;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    drawInfo(canvas, primaryColor);

    for (final barcode in data!.insideRectBarcodes) {
      paint.color = primaryColor;
      drawRectangle(canvas, paint, barcode);
    }

    for (final barcode in data!.outsideRectBarcodes) {
      paint.color = Colors.redAccent;
      drawRectangle(canvas, paint, barcode);
    }
  }

  drawInfo(Canvas canvas, Color color) {
    final paragraphBuilder = ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.center, fontSize: 12));
    paragraphBuilder.pushStyle(ui.TextStyle(color: color));
    paragraphBuilder.addText("View size: ${description.viewSize.width.toInt()} x ${description.viewSize.height.toInt()}\n");
    paragraphBuilder.addText("Texture resolution: ${description.texture.resolution.width.toInt()} x ${description.texture.resolution.height.toInt()}\n");
    paragraphBuilder.addText("Analysis resolution: ${description.analysis.resolution.width.toInt()} x ${description.analysis.resolution.height.toInt()}");
    paragraphBuilder.pop();

    canvas.drawParagraph(
      paragraphBuilder.build()..layout(ParagraphConstraints(width: description.viewSize.width)),
      Offset(0, description.viewSize.height - 60),
    );
  }

  drawRectangle(Canvas canvas, Paint paint, Barcode barcode) {
    if (barcode.displaySpaceCorners == null) return;
    canvas.drawLine(barcode.displaySpaceCorners![0], barcode.displaySpaceCorners![1], paint);
    canvas.drawLine(barcode.displaySpaceCorners![1], barcode.displaySpaceCorners![2], paint);
    canvas.drawLine(barcode.displaySpaceCorners![2], barcode.displaySpaceCorners![3], paint);
    canvas.drawLine(barcode.displaySpaceCorners![3], barcode.displaySpaceCorners![0], paint);
  }

  @override
  bool shouldRepaint(BarcodeDetectorPainter oldDelegate) => true;
}

class Overlay extends CustomPainter {
  Overlay({required this.context, required this.detectorRect});

  final BuildContext context;
  final DetectorRect detectorRect;

  @override
  void paint(Canvas canvas, Size size) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final center = Offset(size.width / 2, size.height / 2);
    final halfSize = detectorRect.rectSize / 2;
    final borderHalfSize = halfSize + 2;
    const borderThickness = 4.0;
    const borderRoundingRadius = 36.0;
    const borderGapsFaction = 0.5;

    final bgPath = Path();
    bgPath.fillType = PathFillType.evenOdd;
    bgPath.addRect(Offset.zero & size);
    bgPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: center, radius: halfSize),
        const Radius.circular(borderRoundingRadius),
      ),
    );
    canvas.drawPath(bgPath, Paint()..color = Colors.black54);

    final borderRectPath = Path();
    borderRectPath.fillType = PathFillType.evenOdd;
    borderRectPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: center, radius: borderHalfSize),
        const Radius.circular(borderRoundingRadius),
      ),
    );

    final borderCutPath = Path();
    borderCutPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: center, radius: borderHalfSize - borderThickness),
        const Radius.circular(borderRoundingRadius - borderThickness),
      ),
    );
    borderCutPath.addRect(
      Rect.fromCenter(center: center, width: borderHalfSize * 2 * borderGapsFaction, height: size.height),
    );
    borderCutPath.addRect(
      Rect.fromCenter(center: center, width: size.width, height: borderHalfSize * 2 * borderGapsFaction),
    );

    final border = Path.combine(PathOperation.difference, borderRectPath, borderCutPath);
    canvas.drawPath(border, Paint()..color = primaryColor);
  }

  @override
  bool shouldRepaint(Overlay oldDelegate) => false;
}

extension BarcodeExtension on BarcodeOffset {
  Offset toOffset() {
    return Offset(x, y);
  }
}
