import 'package:flutter/material.dart';
import 'package:scannerx/scannerx.dart';

class Utils {
  static Size getViewSize() {
    return MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
  }

  static double getResolutionAspectRatio(Resolution resolution) {
    if (resolution.height != 0.0) return resolution.width / resolution.height;
    if (resolution.width > 0.0) return double.infinity;
    if (resolution.width < 0.0) return double.negativeInfinity;
    return 0.0;
  }

  static double getFitScale(double aspectRatio, Size viewSize) {
    if (viewSize.aspectRatio < aspectRatio) {
      return viewSize.height * aspectRatio / viewSize.width;
    } else {
      return viewSize.width / aspectRatio / viewSize.height;
    }
  }

  //If to sum up, the logic of the AspectRatio and Scale widgets is repeated here, but for corners coordinates
  static List<Offset>? getDisplaySpacedCorners(ScannerDescription? description, List<BarcodeOffset?>? corners) {
    if (description == null || corners == null) return null;

    //Scale that fit resolution to view
    var scale = 1.0;
    if (description.viewSize.aspectRatio > description.analysis.aspectRatio) {
      scale = description.viewSize.height / description.analysis.resolution.height;
    } else {
      scale = description.viewSize.width / description.analysis.resolution.width;
    }

    List<Offset> list = [];
    for (final c in corners) {
      if (c == null) return null;
      //Apply scale
      var x = c.x * scale;
      var y = c.y * scale;

      //Centering coordinates
      if (description.viewSize.aspectRatio > description.analysis.aspectRatio) {
        x += (description.viewSize.width - description.analysis.resolution.width * scale) / 2;
      } else {
        y += (description.viewSize.height - description.analysis.resolution.height * scale) / 2;
      }

      //Scaling coordinates from center to edges
      x = (x - description.viewSize.width / 2) * description.analysis.fitScale + description.viewSize.width / 2;
      y = (y - description.viewSize.height / 2) * description.analysis.fitScale + description.viewSize.height / 2;

      list.add(Offset(x, y));
    }
    return list;
  }
}
