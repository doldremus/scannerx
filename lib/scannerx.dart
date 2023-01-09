
import 'scannerx_platform_interface.dart';

class Scannerx {
  Future<String?> getPlatformVersion() {
    return ScannerxPlatform.instance.getPlatformVersion();
  }
}
