// Copyright 2022 Doldremus. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v5.0.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon

import Foundation
#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#else
#error("Unsupported platform.")
#endif


/// Generated class from Pigeon.

enum BarcodeFormat: Int {
  /// Barcode format unknown to the current SDK.
  ///
  /// Constant Value: -1
  case unknown = 0
  /// Barcode format constant representing the union of all supported formats.
  ///
  /// Constant Value: 0
  case all = 1
  /// Barcode format constant for Code 128.
  ///
  /// Constant Value: 1
  case code128 = 2
  /// Barcode format constant for Code 39.
  ///
  /// Constant Value: 2
  case code39 = 3
  /// Barcode format constant for Code 93.
  ///
  /// Constant Value: 4
  case code93 = 4
  /// Barcode format constant for Codabar.
  ///
  /// Constant Value: 8
  case codebar = 5
  /// Barcode format constant for Data Matrix.
  ///
  /// Constant Value: 16
  case dataMatrix = 6
  /// Barcode format constant for EAN-13.
  ///
  /// Constant Value: 32
  case ean13 = 7
  /// Barcode format constant for EAN-8.
  ///
  /// Constant Value: 64
  case ean8 = 8
  /// Barcode format constant for ITF (Interleaved Two-of-Five).
  ///
  /// Constant Value: 128
  case itf = 9
  /// Barcode format constant for QR Code.
  ///
  /// Constant Value: 256
  case qrCode = 10
  /// Barcode format constant for UPC-A.
  ///
  /// Constant Value: 512
  case upcA = 11
  /// Barcode format constant for UPC-E.
  ///
  /// Constant Value: 1024
  case upcE = 12
  /// Barcode format constant for PDF-417.
  ///
  /// Constant Value: 2048
  case pdf417 = 13
  /// Barcode format constant for AZTEC.
  ///
  /// Constant Value: 4096
  case aztec = 14
}

/// Barcode value type constants
enum BarcodeType: Int {
  /// Barcode value type unknown, which indicates the current version of SDK cannot recognize the structure of the barcode. Developers can inspect the raw value instead.
  ///
  /// Constant Value: 0
  case unknown = 0
  /// Barcode value type constant for contact information.
  ///
  /// Constant Value: 1
  case contactInfo = 1
  /// Barcode value type constant for email message details.
  ///
  /// Constant Value: 2
  case email = 2
  /// Barcode value type constant for ISBNs.
  ///
  /// Constant Value: 3
  case isbn = 3
  /// Barcode value type constant for phone numbers.
  ///
  /// Constant Value: 4
  case phone = 4
  /// Barcode value type constant for product codes.
  ///
  /// Constant Value: 5
  case product = 5
  /// Barcode value type constant for SMS details.
  ///
  /// Constant Value: 6
  case sms = 6
  /// Barcode value type constant for plain text.
  ///
  /// Constant Value: 7
  case text = 7
  /// Barcode value type constant for URLs/bookmarks.
  ///
  /// Constant Value: 8
  case url = 8
  /// Barcode value type constant for WiFi access point details.
  ///
  /// Constant Value: 9
  case wifi = 9
  /// Barcode value type constant for geographic coordinates.
  ///
  /// Constant Value: 10
  case geo = 10
  /// Barcode value type constant for calendar events.
  ///
  /// Constant Value: 11
  case calendarEvent = 11
  /// Barcode value type constant for driver's license data.
  ///
  /// Constant Value: 12
  case driverLicense = 12
}

/// Generated class from Pigeon that represents data sent in messages.
struct RawBarcode {
  var corners: [BarcodeOffset?]? = nil
  var boundingBox: BarcodeBoundingBox? = nil
  var rawBytes: FlutterStandardTypedData? = nil
  var rawValue: String? = nil
  var format: BarcodeFormat? = nil
  var type: BarcodeType? = nil

  static func fromList(_ list: [Any?]) -> RawBarcode? {
    let corners = list[0] as? [BarcodeOffset?] 
    var boundingBox: BarcodeBoundingBox? = nil
    if let boundingBoxList = list[1] as? [Any?] {
      boundingBox = BarcodeBoundingBox.fromList(boundingBoxList)
    }
    let rawBytes = list[2] as? FlutterStandardTypedData 
    let rawValue = list[3] as? String 
    var format: BarcodeFormat? = nil
    if let formatRawValue = list[4] as? Int {
      format = BarcodeFormat(rawValue: formatRawValue)
    }
    var type: BarcodeType? = nil
    if let typeRawValue = list[5] as? Int {
      type = BarcodeType(rawValue: typeRawValue)
    }

    return RawBarcode(
      corners: corners,
      boundingBox: boundingBox,
      rawBytes: rawBytes,
      rawValue: rawValue,
      format: format,
      type: type
    )
  }
  func toList() -> [Any?] {
    return [
      corners,
      boundingBox?.toList(),
      rawBytes,
      rawValue,
      format?.rawValue,
      type?.rawValue,
    ]
  }
}

/// Generated class from Pigeon that represents data sent in messages.
struct BarcodeBoundingBox {
  var left: Double
  var top: Double
  var right: Double
  var bottom: Double

  static func fromList(_ list: [Any?]) -> BarcodeBoundingBox? {
    let left = list[0] as! Double
    let top = list[1] as! Double
    let right = list[2] as! Double
    let bottom = list[3] as! Double

    return BarcodeBoundingBox(
      left: left,
      top: top,
      right: right,
      bottom: bottom
    )
  }
  func toList() -> [Any?] {
    return [
      left,
      top,
      right,
      bottom,
    ]
  }
}

/// Generated class from Pigeon that represents data sent in messages.
struct BarcodeOffset {
  var x: Double
  var y: Double

  static func fromList(_ list: [Any?]) -> BarcodeOffset? {
    let x = list[0] as! Double
    let y = list[1] as! Double

    return BarcodeOffset(
      x: x,
      y: y
    )
  }
  func toList() -> [Any?] {
    return [
      x,
      y,
    ]
  }
}
private class BarcodeFlutterApiCodecReader: FlutterStandardReader {
  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
      case 128:
        return BarcodeBoundingBox.fromList(self.readValue() as! [Any])      
      case 129:
        return BarcodeOffset.fromList(self.readValue() as! [Any])      
      case 130:
        return RawBarcode.fromList(self.readValue() as! [Any])      
      default:
        return super.readValue(ofType: type)
      
    }
  }
}
private class BarcodeFlutterApiCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let value = value as? BarcodeBoundingBox {
      super.writeByte(128)
      super.writeValue(value.toList())
    } else if let value = value as? BarcodeOffset {
      super.writeByte(129)
      super.writeValue(value.toList())
    } else if let value = value as? RawBarcode {
      super.writeByte(130)
      super.writeValue(value.toList())
    } else {
      super.writeValue(value)
    }
  }
}

private class BarcodeFlutterApiCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return BarcodeFlutterApiCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return BarcodeFlutterApiCodecWriter(data: data)
  }
}

class BarcodeFlutterApiCodec: FlutterStandardMessageCodec {
  static let shared = BarcodeFlutterApiCodec(readerWriter: BarcodeFlutterApiCodecReaderWriter())
}

/// Generated class from Pigeon that represents Flutter messages that can be called from Swift.
class BarcodeFlutterApi {
  private let binaryMessenger: FlutterBinaryMessenger
  init(binaryMessenger: FlutterBinaryMessenger){
    self.binaryMessenger = binaryMessenger
  }
  var codec: FlutterStandardMessageCodec {
    return BarcodeFlutterApiCodec.shared
  }
  func barcodes(barcodes barcodesArg: [RawBarcode]?, completion: @escaping () -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.BarcodeFlutterApi.barcodes", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([barcodesArg]) { _ in
      completion()
    }
  }
}

private func wrapResult(_ result: Any?) -> [Any?] {
  return [result]
}

private func wrapError(_ error: FlutterError) -> [Any?] {
  return [
    error.code,
    error.message,
    error.details
  ]
}
