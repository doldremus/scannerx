import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/pigeon_logger.dart',
  swiftOut: 'ios/Classes/PigeonLogger.swift',
  kotlinOut: 'android/src/main/kotlin/dev/doldremus/scannerx/PigeonLogger.kt',
  kotlinOptions: KotlinOptions(
    package: 'dev.doldremus.scannerx',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))
@FlutterApi()
abstract class LoggerFlutterApi {
  void logError(LoggerError error);
  void logMessage(LoggerMessage message);
}

class LoggerError {
  LoggerError({this.className, this.cause, this.stackTrace, this.description, this.isCritical = true});

  final String? className;
  final String? cause;
  final String? stackTrace;
  final String? description;
  final bool isCritical;
}

class LoggerMessage {
  LoggerMessage(this.message, {this.logLevel = LogLevel.verbose});

  final String message;
  final LogLevel logLevel;
}

enum LogLevel {
  none,
  critical,
  error,
  warning,
  informational,
  verbose,
}
