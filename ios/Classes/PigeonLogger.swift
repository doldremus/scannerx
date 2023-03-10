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

enum LogLevel: Int {
  case none = 0
  case critical = 1
  case error = 2
  case warning = 3
  case informational = 4
  case verbose = 5
}

/// Generated class from Pigeon that represents data sent in messages.
struct LoggerError {
  var className: String? = nil
  var cause: String? = nil
  var message: String? = nil
  var stackTrace: String? = nil
  var isCritical: Bool

  static func fromList(_ list: [Any?]) -> LoggerError? {
    let className = list[0] as? String 
    let cause = list[1] as? String 
    let message = list[2] as? String 
    let stackTrace = list[3] as? String 
    let isCritical = list[4] as! Bool

    return LoggerError(
      className: className,
      cause: cause,
      message: message,
      stackTrace: stackTrace,
      isCritical: isCritical
    )
  }
  func toList() -> [Any?] {
    return [
      className,
      cause,
      message,
      stackTrace,
      isCritical,
    ]
  }
}

/// Generated class from Pigeon that represents data sent in messages.
struct LoggerMessage {
  var message: String
  var logLevel: LogLevel

  static func fromList(_ list: [Any?]) -> LoggerMessage? {
    let message = list[0] as! String
    let logLevel = LogLevel(rawValue: list[1] as! Int)!

    return LoggerMessage(
      message: message,
      logLevel: logLevel
    )
  }
  func toList() -> [Any?] {
    return [
      message,
      logLevel.rawValue,
    ]
  }
}
private class LoggerFlutterApiCodecReader: FlutterStandardReader {
  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
      case 128:
        return LoggerError.fromList(self.readValue() as! [Any])      
      case 129:
        return LoggerMessage.fromList(self.readValue() as! [Any])      
      default:
        return super.readValue(ofType: type)
      
    }
  }
}
private class LoggerFlutterApiCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let value = value as? LoggerError {
      super.writeByte(128)
      super.writeValue(value.toList())
    } else if let value = value as? LoggerMessage {
      super.writeByte(129)
      super.writeValue(value.toList())
    } else {
      super.writeValue(value)
    }
  }
}

private class LoggerFlutterApiCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return LoggerFlutterApiCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return LoggerFlutterApiCodecWriter(data: data)
  }
}

class LoggerFlutterApiCodec: FlutterStandardMessageCodec {
  static let shared = LoggerFlutterApiCodec(readerWriter: LoggerFlutterApiCodecReaderWriter())
}

/// Generated class from Pigeon that represents Flutter messages that can be called from Swift.
class LoggerFlutterApi {
  private let binaryMessenger: FlutterBinaryMessenger
  init(binaryMessenger: FlutterBinaryMessenger){
    self.binaryMessenger = binaryMessenger
  }
  var codec: FlutterStandardMessageCodec {
    return LoggerFlutterApiCodec.shared
  }
  func logError(error errorArg: LoggerError, completion: @escaping () -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.LoggerFlutterApi.logError", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([errorArg]) { _ in
      completion()
    }
  }
  func logMessage(message messageArg: LoggerMessage, completion: @escaping () -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.LoggerFlutterApi.logMessage", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([messageArg]) { _ in
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
