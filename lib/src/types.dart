import 'dart:ui';

import 'package:scannerx/scannerx.dart';
import 'package:scannerx/src/utils.dart';

class ScannerDescription {
  ScannerDescription({
    required this.texture,
    required this.analysis,
    required this.viewSize,
  });

  factory ScannerDescription.fromRaw(RawScannerDescription rawDescription) {
    final viewSize = Utils.getViewSize();

    final textureAspectRatio = Utils.getResolutionAspectRatio(rawDescription.texture.resolution);
    final analysisAspectRatio = Utils.getResolutionAspectRatio(rawDescription.analysis.resolution);

    return ScannerDescription(
      texture: TextureDescription(
        id: rawDescription.texture.id,
        resolution: rawDescription.texture.resolution,
        aspectRatio: textureAspectRatio,
        fitScale: Utils.getFitScale(textureAspectRatio, viewSize),
      ),
      analysis: AnalysisDescription(
        resolution: rawDescription.analysis.resolution,
        aspectRatio: analysisAspectRatio,
        fitScale: Utils.getFitScale(analysisAspectRatio, viewSize)
      ),
      viewSize: viewSize,
    );
  }

  final TextureDescription texture;
  final AnalysisDescription analysis;
  final Size viewSize;
}

class TextureDescription extends RawTextureDescription {
  TextureDescription({required super.id, required super.resolution, required this.aspectRatio, required this.fitScale});

  final double aspectRatio;
  final double fitScale;
}

class AnalysisDescription extends RawAnalysisDescription {
  AnalysisDescription({required super.resolution, required this.aspectRatio, required this.fitScale});

  final double aspectRatio;
  final double fitScale;
}

class Barcode extends RawBarcode {
  Barcode({
    super.corners,
    this.displaySpaceCorners,
    super.boundingBox,
    super.rawBytes,
    super.rawValue,
    super.format,
    super.type,
  });

  factory Barcode.fromRaw(ScannerDescription? description, RawBarcode rawBarcode) {
    return Barcode(
      corners: rawBarcode.corners,
      boundingBox: rawBarcode.boundingBox,
      rawBytes: rawBarcode.rawBytes,
      rawValue: rawBarcode.rawValue,
      format: rawBarcode.format,
      type: rawBarcode.type,
      displaySpaceCorners: Utils.getDisplaySpacedCorners(description, rawBarcode.corners),
    );
  }

  final List<Offset>? displaySpaceCorners;
}

class ScannerError implements Error {
  ScannerError({this.className, this.cause, this.message, required this.isCritical, this.stackTrace});

  final String? className;
  final String? cause;
  final String? message;
  final bool isCritical;

  @override
  final StackTrace? stackTrace;

  @override
  String toString() {
    var msg = '$runtimeType: ${className ?? ''} ${message ?? ''}';
    if (stackTrace != null) {
      msg += '\nSource stack:\n$stackTrace';
    }
    return msg;
  }
}