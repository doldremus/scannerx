import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scannerx/scannerx_method_channel.dart';

void main() {
  MethodChannelScannerx platform = MethodChannelScannerx();
  const MethodChannel channel = MethodChannel('scannerx');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
