import Flutter
import UIKit

public class SwiftFlutterAlibcUltimatePlugin: NSObject, FlutterPlugin {

    var alibchandler : FlutterAlibcUltimateHandle? = nil;

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_alibc_ultimate", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterAlibcUltimatePlugin()
        instance.alibchandler = FlutterAlibcUltimateHandle(channel: channel)

        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getPlatformVersion"{
            result("iOS " + UIDevice.current.systemVersion)
        } else if call.method == "initAlibc"{
            alibchandler?.initAlibc(call: call, result: result)
        } else if call.method == "loginTaoBao" {
            alibchandler?.loginTaoBao(call: call, result: result)
        } else if call.method == "taoKeLogin" {
            alibchandler?.openByAsyncWebView(call: call, result: result, callBackString: FlutterAlibcUltimateConstKey.CallBackString.AlibcTaokeLogin.rawValue)
        } else if call.method == "loginOut" {
            alibchandler?.loginOut(call: call, result: result)
        } else if call.method == "taoKeLoginForCode" {
            alibchandler?.openByAsyncWebView(call: call, result: result, callBackString: FlutterAlibcUltimateConstKey.CallBackString.AlibcTaokeLoginForCode.rawValue)
        } else if call.method == "openByUrl" {
            alibchandler?.openByUrl(call: call, result: result, callBackString: FlutterAlibcUltimateConstKey.CallBackString.AlibcOpenURL.rawValue)
        } else if call.method == "openItemDetail"{
            alibchandler?.openItemDetail(call: call, result: result, callBackString: FlutterAlibcUltimateConstKey.CallBackString.AlibcOpenDetail.rawValue)
        } else if call.method == "openShop"{
            alibchandler?.openShop(call: call, result: result, callBackString: FlutterAlibcUltimateConstKey.CallBackString.AlibcOpenShop.rawValue)
        } else if call.method == "openCart"{
            alibchandler?.openCart(call: call, result: result, callBackString: FlutterAlibcUltimateConstKey.CallBackString.AlibcOpenCar.rawValue)
        } else if call.method == "openPriceProtection"{
            alibchandler?.openPriceProtection(call: call, result: result, callBackString: FlutterAlibcUltimateConstKey.CallBackString.AlibcOpenPriceProtection.rawValue)
        } else if call.method == "syncForTaoke"{
            alibchandler?.syncForTaoke(call: call, result: result)
        } else if call.method == "useAlipayNative"{
            alibchandler?.useAlipayNative(call: call, result: result)
        }else{
            result(FlutterMethodNotImplemented)
        }
    }

    //    MARK:- 百川处理应用跳转
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String, annotation: Any) -> Bool {
        if !(AlibcTradeSDK.sharedInstance()?.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation))! {
            return true
        }
        return false
    }

    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if #available(iOS 9.0, *) {
            var op : [String : Any] = [:];
            for (key,value) in options {
                op[key.rawValue] = value
            }
            let isHandledByALBBSDK : Bool = (AlibcTradeSDK.sharedInstance()?.application(application, open: url, options: op))!;
            return isHandledByALBBSDK
        } else {
            // Fallback on earlier versions
        }
        return false
    }
}
