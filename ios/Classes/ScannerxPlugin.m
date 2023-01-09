#import "ScannerxPlugin.h"
#if __has_include(<scannerx/scannerx-Swift.h>)
#import <scannerx/scannerx-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "scannerx-Swift.h"
#endif

@implementation ScannerxPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftScannerxPlugin registerWithRegistrar:registrar];
}
@end
