import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'scannerx_platform_interface.dart';

/// An implementation of [ScannerxPlatform] that uses method channels.
class MethodChannelScannerx extends ScannerxPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('scannerx');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
