import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/pigeon_scanner.dart',
  swiftOut: 'ios/Classes/PigeonScanner.swift',
  kotlinOut: 'android/src/main/kotlin/dev/doldremus/scannerx/PigeonScanner.kt',
  kotlinOptions: KotlinOptions(
    package: 'dev.doldremus.scannerx',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))

@HostApi()
abstract class ScannerHostApi {
  @async
  PermissionsResponse requestPermissions();

  @async
  RawScannerDescription? init(ScannerOptions options);

  @async
  void dispose();

  bool hasFlashlight();
  bool getFlashlightState();
  void setFlashlightState(bool state);
}

class ScannerOptions {
  const ScannerOptions({this.targetResolution, this.lensDirection});

  final Resolution? targetResolution;
  final CameraLensDirection? lensDirection;
}

class RawScannerDescription {
  const RawScannerDescription(this.texture, this.analysis);

  final RawTextureDescription texture;
  final RawAnalysisDescription analysis;
}

class RawTextureDescription {
  RawTextureDescription(this.id, this.resolution);

  final int id;
  final Resolution resolution;
}

class RawAnalysisDescription{
  RawAnalysisDescription(this.resolution);

  final Resolution resolution;
}

class Resolution {
  const Resolution(this.width, this.height);

  final double width;
  final double height;
}

enum CameraLensDirection {
  front,
  back,
}

class PermissionsResponse {
  PermissionsResponse(this.granted, this.permanentlyDenied);

  bool granted;
  bool permanentlyDenied;
}
