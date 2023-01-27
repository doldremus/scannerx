import AVFoundation
import Flutter

public class SwiftScannerxPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        ScannerHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(),
            api: ScannerHostApiImpl(registrar)
        )
    }
}
