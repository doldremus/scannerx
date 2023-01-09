import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/pigeon_barcode.dart',
  swiftOut: 'ios/Classes/PigeonBarcode.swift',
  kotlinOut: 'android/src/main/kotlin/dev/doldremus/scannerx/PigeonBarcode.kt',
  kotlinOptions: KotlinOptions(
    package: 'dev.doldremus.scannerx',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))
@FlutterApi()
abstract class BarcodeFlutterApi {
  void barcodes(List<RawBarcode>? barcodes);
}

class RawBarcode {
  const RawBarcode(
    this.corners,
    this.boundingBox,
    this.rawBytes,
    this.rawValue,
    this.format,
    this.type,
  );

  final List<BarcodeOffset?>? corners;
  final BarcodeBoundingBox? boundingBox;
  final Uint8List? rawBytes;
  final String? rawValue;
  final BarcodeFormat? format;
  final BarcodeType? type;
}

class BarcodeBoundingBox {
  const BarcodeBoundingBox({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;
}

class BarcodeOffset {
  const BarcodeOffset({required this.x, required this.y});

  final double x;
  final double y;
}

enum BarcodeFormat {
  /// Barcode format unknown to the current SDK.
  ///
  /// Constant Value: -1
  unknown,

  /// Barcode format constant representing the union of all supported formats.
  ///
  /// Constant Value: 0
  all,

  /// Barcode format constant for Code 128.
  ///
  /// Constant Value: 1
  code128,

  /// Barcode format constant for Code 39.
  ///
  /// Constant Value: 2
  code39,

  /// Barcode format constant for Code 93.
  ///
  /// Constant Value: 4
  code93,

  /// Barcode format constant for Codabar.
  ///
  /// Constant Value: 8
  codebar,

  /// Barcode format constant for Data Matrix.
  ///
  /// Constant Value: 16
  dataMatrix,

  /// Barcode format constant for EAN-13.
  ///
  /// Constant Value: 32
  ean13,

  /// Barcode format constant for EAN-8.
  ///
  /// Constant Value: 64
  ean8,

  /// Barcode format constant for ITF (Interleaved Two-of-Five).
  ///
  /// Constant Value: 128
  itf,

  /// Barcode format constant for QR Code.
  ///
  /// Constant Value: 256
  qrCode,

  /// Barcode format constant for UPC-A.
  ///
  /// Constant Value: 512
  upcA,

  /// Barcode format constant for UPC-E.
  ///
  /// Constant Value: 1024
  upcE,

  /// Barcode format constant for PDF-417.
  ///
  /// Constant Value: 2048
  pdf417,

  /// Barcode format constant for AZTEC.
  ///
  /// Constant Value: 4096
  aztec,
}

/// Barcode value type constants
enum BarcodeType {
  /// Barcode value type unknown, which indicates the current version of SDK cannot recognize the structure of the barcode. Developers can inspect the raw value instead.
  ///
  /// Constant Value: 0
  unknown,

  /// Barcode value type constant for contact information.
  ///
  /// Constant Value: 1
  contactInfo,

  /// Barcode value type constant for email message details.
  ///
  /// Constant Value: 2
  email,

  /// Barcode value type constant for ISBNs.
  ///
  /// Constant Value: 3
  isbn,

  /// Barcode value type constant for phone numbers.
  ///
  /// Constant Value: 4
  phone,

  /// Barcode value type constant for product codes.
  ///
  /// Constant Value: 5
  product,

  /// Barcode value type constant for SMS details.
  ///
  /// Constant Value: 6
  sms,

  /// Barcode value type constant for plain text.
  ///
  ///Constant Value: 7
  text,

  /// Barcode value type constant for URLs/bookmarks.
  ///
  /// Constant Value: 8
  url,

  /// Barcode value type constant for WiFi access point details.
  ///
  /// Constant Value: 9
  wifi,

  /// Barcode value type constant for geographic coordinates.
  ///
  /// Constant Value: 10
  geo,

  /// Barcode value type constant for calendar events.
  ///
  /// Constant Value: 11
  calendarEvent,

  /// Barcode value type constant for driver's license data.
  ///
  /// Constant Value: 12
  driverLicense,
}
