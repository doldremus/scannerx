import 'package:flutter/material.dart';
import 'package:scannerx/src/types.dart';

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
  const DetectorData(this.insideRectBarcodes, this.outsideRectBarcodes);

  final List<Barcode> insideRectBarcodes;
  final List<Barcode> outsideRectBarcodes;
}

class OverlayOptions {
  const OverlayOptions({
    this.color = Colors.greenAccent,
    this.borderOffset = 2,
    this.borderThickness = 4,
    this.borderRoundingRadius = 36,
    this.borderGapsFaction = 0.5,
  });

  final Color color;
  final double borderOffset;
  final double borderThickness;
  final double borderRoundingRadius;
  final double borderGapsFaction;
}
