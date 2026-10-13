#if SWIFT_PACKAGE
import Flutter

// CocoaPods uses its Objective-C forwarding class with the same public name.
@objc(FlutterAlibcPlugin)
public class FlutterAlibcPlugin: SwiftFlutterAlibcPlugin {}
#endif
