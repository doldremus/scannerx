import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'scannerx_method_channel.dart';

abstract class ScannerxPlatform extends PlatformInterface {
  /// Constructs a ScannerxPlatform.
  ScannerxPlatform() : super(token: _token);

  static final Object _token = Object();

  static ScannerxPlatform _instance = MethodChannelScannerx();

  /// The default instance of [ScannerxPlatform] to use.
  ///
  /// Defaults to [MethodChannelScannerx].
  static ScannerxPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ScannerxPlatform] when
  /// they register themselves.
  static set instance(ScannerxPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
