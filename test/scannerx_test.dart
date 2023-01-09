import 'package:flutter_test/flutter_test.dart';
import 'package:scannerx/scannerx.dart';
import 'package:scannerx/scannerx_platform_interface.dart';
import 'package:scannerx/scannerx_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockScannerxPlatform
    with MockPlatformInterfaceMixin
    implements ScannerxPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ScannerxPlatform initialPlatform = ScannerxPlatform.instance;

  test('$MethodChannelScannerx is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelScannerx>());
  });

  test('getPlatformVersion', () async {
    Scannerx scannerxPlugin = Scannerx();
    MockScannerxPlatform fakePlatform = MockScannerxPlatform();
    ScannerxPlatform.instance = fakePlatform;

    expect(await scannerxPlugin.getPlatformVersion(), '42');
  });
}
