#import "IdwallSdkBridgeFlutterPlugin.h"
#if __has_include(<idwall_sdk/idwall_sdk-Swift.h>)
#import <idwall_sdk/idwall_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "idwall_sdk-Swift.h"
#endif

@implementation IdwallSdkBridgeFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [IdwallSdkBridgeFlutterPluginSwift registerWithRegistrar:registrar];
}
@end
