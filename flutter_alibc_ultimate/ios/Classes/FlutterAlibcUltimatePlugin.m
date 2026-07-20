#import "FlutterAlibcUltimatePlugin.h"
#if __has_include(<flutter_alibc_ultimate/flutter_alibc_ultimate-Swift.h>)
#import <flutter_alibc_ultimate/flutter_alibc_ultimate-Swift.h>
#else
#import "flutter_alibc_ultimate-Swift.h"
#endif

@implementation FlutterAlibcUltimatePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAlibcUltimatePlugin registerWithRegistrar:registrar];
}
@end
