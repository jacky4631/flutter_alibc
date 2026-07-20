//
//  FlutterAlibcUltimateHandle.swift
//  flutter_alibc_ultimate
//

import Foundation

class FlutterAlibcUltimateHandle: NSObject, AlibcUltimateWkWebViewDelegate {
    func noticeToken(result: String) {
        if result == "" {
            channel?.invokeMethod(FlutterAlibcUltimateConstKey.CallBackString.AlibcTaokeLogin.rawValue, arguments: [
                FlutterAlibcUltimateConstKey.ErrorCode : "-1",
                FlutterAlibcUltimateConstKey.ErrorMessage:"取消授权",
            ])
        }else{
            let array : Array = result.components(separatedBy: "=")
            let token:String = array[1]
            channel?.invokeMethod(FlutterAlibcUltimateConstKey.CallBackString.AlibcTaokeLogin.rawValue, arguments: [
                FlutterAlibcUltimateConstKey.ErrorCode : "0",
                FlutterAlibcUltimateConstKey.ErrorMessage:"success",
                FlutterAlibcUltimateConstKey.Data :["accessToken":token]
            ])
        }
    }

    func noticeCode(result: String) {
        if result == "" {
            channel?.invokeMethod(FlutterAlibcUltimateConstKey.CallBackString.AlibcTaokeLoginForCode.rawValue, arguments: [
                FlutterAlibcUltimateConstKey.ErrorCode : "-1",
                FlutterAlibcUltimateConstKey.ErrorMessage:"取消授权",
            ])
        }else{
            let array : Array = result.components(separatedBy: "=")
            let code : String = array[1]
            channel?.invokeMethod(FlutterAlibcUltimateConstKey.CallBackString.AlibcTaokeLoginForCode.rawValue, arguments: [
                FlutterAlibcUltimateConstKey.ErrorCode : "0",
                FlutterAlibcUltimateConstKey.ErrorMessage:"success",
                FlutterAlibcUltimateConstKey.Data :["code":code]
            ])
        }
    }

    var channel : FlutterMethodChannel? = nil;

    init(channel:FlutterMethodChannel) {
        super.init()
        self.channel = channel
    }

    //    MARK: - 对flutter暴露的方法

    //    MARK:  初始化阿里百川旗舰版
    public func initAlibc(call : FlutterMethodCall , result : @escaping FlutterResult){
        AlibcTradeSDK.sharedInstance()?.setEnv(AlibcEnvironment.release)
        let version : String = getStringFromCall(key: "version", call: call);
        let appName : String = getStringFromCall(key: "appName", call: call);
        if version != ""{
            AlibcTradeSDK.sharedInstance()?.setIsvVersion(version)
        }
        if appName != ""{
            AlibcTradeSDK.sharedInstance()?.setIsvAppName(appName)
        }
        AlibcTradeSDK.sharedInstance()?.setDebugLogOpen(true)
        AlibcTradeSDK.sharedInstance()?.asyncInit(success: {
            let dic = [FlutterAlibcUltimateConstKey.ErrorCode :"0",FlutterAlibcUltimateConstKey.ErrorMessage:"success"]
            result(dic);
        }, failure: { (error) in
            let dic = [FlutterAlibcUltimateConstKey.ErrorCode :String((error! as NSError).code) ,FlutterAlibcUltimateConstKey.ErrorMessage:error?.localizedDescription] as! Dictionary<String,String>
            result(dic);
        })
    }

    //    MARK:  淘宝登录
    public func loginTaoBao(call : FlutterMethodCall , result : @escaping FlutterResult){
        if(!ALBBCompatibleSession.sharedInstance().isLogin()){
            let rootViewController : UIViewController = UIApplication.shared.windows.last!.rootViewController!
            ALBBSDK.sharedInstance().auth(rootViewController) {
                let userInfo : ALBBUser = ALBBCompatibleSession.sharedInstance().getUser()
                self.channel?.invokeMethod(FlutterAlibcUltimateConstKey.CallBackString.AlibcTaobaoLogin.rawValue, arguments: [
                    FlutterAlibcUltimateConstKey.ErrorCode : "0",
                    FlutterAlibcUltimateConstKey.ErrorMessage:"success",
                    FlutterAlibcUltimateConstKey.Data :[
                        "nick":userInfo.nick,
                        "avatarUrl":userInfo.avatarUrl,
                        "openId":userInfo.openId,
                        "openSid":userInfo.openSid,
                        "topAccessToken":userInfo.topAccessToken,
                        "topAuthCode":userInfo.topAuthCode,]
                ])
            } failureCallback: { error in
                let dic = [FlutterAlibcUltimateConstKey.ErrorCode :String((error! as NSError).code) ,FlutterAlibcUltimateConstKey.ErrorMessage: String(error!.localizedDescription)]
                result(dic);
                self.channel?.invokeMethod(FlutterAlibcUltimateConstKey.CallBackString.AlibcTaobaoLogin.rawValue, arguments: [dic])
            }
        }else{
            let userInfo : ALBBUser = ALBBCompatibleSession.sharedInstance().getUser()
            channel?.invokeMethod(FlutterAlibcUltimateConstKey.CallBackString.AlibcTaobaoLogin.rawValue, arguments: [
                FlutterAlibcUltimateConstKey.ErrorCode : "0",
                FlutterAlibcUltimateConstKey.ErrorMessage:"success",
                FlutterAlibcUltimateConstKey.Data :[
                    "nick":userInfo.nick,
                    "avatarUrl":userInfo.avatarUrl,
                    "openId":userInfo.openId,
                    "openSid":userInfo.openSid,
                    "topAccessToken":userInfo.topAccessToken,
                    "topAuthCode":userInfo.topAuthCode,]
            ])
        }
    }

    //    MARK:  退出登陆
    public func loginOut(call : FlutterMethodCall , result : @escaping FlutterResult){
        ALBBSDK.sharedInstance()?.logout()
    }

    //        MARK:  淘客授权，拿token / code
    public func openByAsyncWebView(call: FlutterMethodCall, result : @escaping FlutterResult, callBackString: String){
        let rootViewController : UIViewController = UIApplication.shared.windows.last!.rootViewController!
        let url : String = getStringFromCall(key: "url", call: call);
        let showParams = AlibcTradeShowParams.init()
        showParams.backUrl =  getStringFromCall(key: "backUrl", call: call)
        showParams.isNeedPush = true
        showParams.isNeedCustomNativeFailMode = getBoolFromCall(key: "isNeedCustomNativeFailMode", call: call)
        let tmpType : Int = (getNumberFromCall(key: "openType", call: call)).intValue;
        showParams.openType = self.openType(mode: tmpType)
        let failMode : Int = (getNumberFromCall(key: "nativeFailMode", call: call)).intValue;
        showParams.nativeFailMode =  NativeFailMode(mode: failMode)
        let tmpSchemeType : Int = (getNumberFromCall(key: "schemeType", call: call)).intValue;
        showParams.linkKey = schemeType(mode: tmpSchemeType)
        let taokeParam = getTaokeParams(call: call) ?? nil

        let wkvc = AlibcUltimateWkWebView()
        wkvc.delegate = self
        if callBackString == FlutterAlibcUltimateConstKey.CallBackString.AlibcTaokeLogin.rawValue {
            wkvc.fuctionType = "token"
        }else{
            wkvc.fuctionType = "code"
        }

        let res : NSInteger = AlibcTradeSDK.sharedInstance().tradeService().open(byUrl: url, identity: "trade", webView: wkvc.webview, parentController: rootViewController, showParams: showParams, taoKeParams: taokeParam, trackParam: nil) { result in
        } tradeProcessFailedCallback: { error in
        }
        if res == 1 {
            let nav = UINavigationController.init(rootViewController: wkvc)
            nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            rootViewController.present(nav, animated: false) {}
        }
    }

    //    MARK: 通过url打开
    public func openByUrl(call : FlutterMethodCall , result : @escaping FlutterResult, callBackString: String, overrideUrl: String? = nil){
        let rootViewController : UIViewController = UIApplication.shared.windows.last!.rootViewController!
        let url : String = overrideUrl ?? getStringFromCall(key: "url", call: call);
        let showParams = AlibcTradeShowParams.init()
        showParams.backUrl =  getStringFromCall(key: "backUrl", call: call)
        showParams.isNeedPush = true
        showParams.isNeedCustomNativeFailMode = getBoolFromCall(key: "isNeedCustomNativeFailMode", call: call)
        let tmpType : Int = (getNumberFromCall(key: "openType", call: call)).intValue;
        showParams.openType = self.openType(mode: tmpType)
        let failMode : Int = (getNumberFromCall(key: "nativeFailMode", call: call)).intValue;
        showParams.nativeFailMode =  NativeFailMode(mode: failMode)
        let tmpSchemeType : Int = (getNumberFromCall(key: "schemeType", call: call)).intValue;
        showParams.linkKey = schemeType(mode: tmpSchemeType)
        let taokeParam = getTaokeParams(call: call) ?? nil
        let trackParam : Dictionary<String,Any>? = getDicFromCall(key: "trackParam", call: call) ?? nil

        AlibcTradeSDK.sharedInstance().tradeService()?.open(byUrl: url, identity: "trade", webView: nil, parentController: rootViewController, showParams: showParams, taoKeParams: taokeParam, trackParam: trackParam, tradeProcessSuccessCallback: { alibcTradeResult in
            if alibcTradeResult?.result == AlibcTradeResultType.paySuccess {
                self.channel?.invokeMethod(callBackString, arguments: [
                    FlutterAlibcUltimateConstKey.ErrorCode:"0",
                    FlutterAlibcUltimateConstKey.ErrorMessage:"付款成功",
                    FlutterAlibcUltimateConstKey.Data:[
                        "type":0,
                        "paySuccessOrders":alibcTradeResult?.payResult?.paySuccessOrders as Any,
                        "payFailedOrders":alibcTradeResult?.payResult?.payFailedOrders as Any,
                    ]
                ])
            }else if alibcTradeResult?.result == AlibcTradeResultType.addCard {
                self.channel?.invokeMethod(callBackString, arguments: [
                    FlutterAlibcUltimateConstKey.ErrorCode:"0",
                    FlutterAlibcUltimateConstKey.ErrorMessage:"加入购物车成功",
                    FlutterAlibcUltimateConstKey.Data:["type":1]
                ]);
            }
        }, tradeProcessFailedCallback: { error in
            let dic = [FlutterAlibcUltimateConstKey.ErrorCode :String((error! as NSError).code) ,FlutterAlibcUltimateConstKey.ErrorMessage:error?.localizedDescription] as! Dictionary<String,String>
            self.channel?.invokeMethod(callBackString, arguments: [dic]);
        })
    }

    public func openItemDetail(call : FlutterMethodCall , result : @escaping FlutterResult, callBackString: String){
        let itemID : String = getStringFromCall(key: "itemID", call: call);
        let page = AlibcTradePageFactory.itemDetailPage(itemID)
        self.openPageByNewWay(page: page, bizcode: "detail", call: call, result: result, callBackString: callBackString)
    }

    public func openShop(call : FlutterMethodCall , result : @escaping FlutterResult, callBackString: String){
        let shopId : String = getStringFromCall(key: "shopId", call: call);
        let page = AlibcTradePageFactory.shopPage(shopId)
        self.openPageByNewWay(page: page, bizcode: "shop", call: call, result: result, callBackString: callBackString)
    }

    public func openCart(call : FlutterMethodCall , result : @escaping FlutterResult, callBackString: String){
        let page = AlibcTradePageFactory.myCartsPage()
        self.openPageByNewWay(page: page, bizcode: "cart", call: call, result: result, callBackString: callBackString)
    }

    public func openPriceProtection(call : FlutterMethodCall , result : @escaping FlutterResult, callBackString: String){
        let rootViewController : UIViewController = UIApplication.shared.windows.last!.rootViewController!
        let pageCode : String = getStringFromCall(key: "pageCode", call: call)
        let finalCode = pageCode.isEmpty ? "priceProtection" : pageCode
        let showParams = AlibcTradeShowParams.init()
        showParams.backUrl = getStringFromCall(key: "backUrl", call: call)
        showParams.isNeedPush = true
        showParams.isNeedCustomNativeFailMode = getBoolFromCall(key: "isNeedCustomNativeFailMode", call: call)
        let tmpType : Int = (getNumberFromCall(key: "openType", call: call)).intValue;
        showParams.openType = self.openType(mode: tmpType)
        let failMode : Int = (getNumberFromCall(key: "nativeFailMode", call: call)).intValue;
        showParams.nativeFailMode = NativeFailMode(mode: failMode)
        let tmpSchemeType : Int = (getNumberFromCall(key: "schemeType", call: call)).intValue;
        showParams.linkKey = schemeType(mode: tmpSchemeType)
        let taokeParam = getTaokeParams(call: call) ?? nil
        let trackParam : Dictionary<String,Any>? = getDicFromCall(key: "trackParam", call: call) ?? nil
        let urlParams = AlibcTradeUrlParams.init()

        AlibcTradeSDK.sharedInstance().tradeService()?.openTradePage(byCode: finalCode, parentController: rootViewController, urlParams: urlParams, showParams: showParams, taoKeParams: taokeParam, trackParam: trackParam, openUrlCallBack: { error, resultDic in
            if let error = error {
                let dic = [FlutterAlibcUltimateConstKey.ErrorCode :String((error as NSError).code) ,FlutterAlibcUltimateConstKey.ErrorMessage:error.localizedDescription] as! Dictionary<String,String>
                self.channel?.invokeMethod(callBackString, arguments: [dic]);
            } else {
                self.channel?.invokeMethod(callBackString, arguments: [
                    FlutterAlibcUltimateConstKey.ErrorCode:"0",
                    FlutterAlibcUltimateConstKey.ErrorMessage:"success",
                    FlutterAlibcUltimateConstKey.Data: resultDic as Any
                ])
            }
        })
    }

    public func syncForTaoke(call : FlutterMethodCall , result : @escaping FlutterResult){
        let isSync = getBoolFromCall(key: "isSync", call: call)
        AlibcTradeSDK.sharedInstance().setIsSyncForTaoke(isSync)
    }

    // 注意，新版本已经移除zfb，谨慎使用
    public func useAlipayNative(call : FlutterMethodCall , result : @escaping FlutterResult){
        let isNeed = getBoolFromCall(key: "isNeed", call: call)
        AlibcTradeSDK.sharedInstance().setShouldUseAlizfNative(isNeed)
    }

    //    MARK: - 私有方法
    private func openType(mode: Int) -> AlibcOpenType{
        var openType : AlibcOpenType = AlibcOpenType.auto
        switch mode {
        case 0: openType = AlibcOpenType.auto
        case 1: openType = AlibcOpenType.native
        default: break
        }
        return openType
    }

    private func NativeFailMode(mode: Int) -> AlibcNativeFailMode{
        var failType = AlibcNativeFailMode.jumpH5
        switch mode {
        case 0: failType = AlibcNativeFailMode.jumpH5
        case 1: failType = AlibcNativeFailMode.jumpDownloadPage
        case 2: failType = AlibcNativeFailMode.none
        default: break
        }
        return failType
    }

    private func schemeType(mode: Int) -> String{
        var linkKey = "tmall"
        switch mode {
        case 0: linkKey = "tmall"
        case 1: linkKey = "taobao"
        default: break
        }
        return linkKey
    }

    private func getStringFromCall(key:String,call : FlutterMethodCall) -> String{
        guard let result = (call.arguments as? Dictionary<String, Any>)?[key] as? String else {
            return ""
        }
        return result
    }

    private func getNumberFromCall(key:String,call : FlutterMethodCall) -> NSNumber{
        guard let result = (call.arguments as? Dictionary<String, Any>)?[key] as? NSNumber else {
            return FlutterAlibcUltimateConstKey.EmptyNum
        }
        return result
    }

    private func getBoolFromCall(key:String,call : FlutterMethodCall) -> Bool{
        guard let result = (call.arguments as? Dictionary<String, Any>)?[key] as? Bool else {
            return false
        }
        return result
    }

    private func getDicFromCall(key:String,call : FlutterMethodCall) -> Dictionary<String, Any>?{
        guard let result = (call.arguments as? Dictionary<String, Any>)?[key] as? Dictionary<String, Any> else {
            return nil
        }
        return result
    }

    private func getTaokeParams(call : FlutterMethodCall) -> AlibcTradeTaokeParams?{
        let taoke : AlibcTradeTaokeParams = AlibcTradeTaokeParams.init()
        if getDicFromCall(key: "taoKeParams", call: call) == nil {
            return nil
        }
        let taokeParams = getDicFromCall(key: "taoKeParams", call: call)
        taoke.adzoneId = (taokeParams!["adzoneId"] is NSNull) ? nil : taokeParams!["adzoneId"] as? String
        taoke.pid = (taokeParams!["pid"] is NSNull) ? nil : taokeParams!["pid"] as? String
        taoke.unionId = (taokeParams!["unionId"] is NSNull) ? nil : taokeParams!["unionId"] as? String
        taoke.subPid = (taokeParams!["subPid"] is NSNull) ? nil : taokeParams!["subPid"] as? String
        taoke.extParams = (taokeParams!["extParams"] is NSNull) ? nil : taokeParams!["extParams"] as? [AnyHashable : Any]
        return taoke
    }

    //     MARK: 打开page
    private func openPageByNewWay(page:AlibcTradePage, bizcode:String, call : FlutterMethodCall , result : @escaping FlutterResult, callBackString: String){
        let rootViewController : UIViewController = UIApplication.shared.windows.last!.rootViewController!
        let showParams = AlibcTradeShowParams.init()
        showParams.backUrl =  getStringFromCall(key: "backUrl", call: call)
        showParams.isNeedPush = true
        showParams.isNeedCustomNativeFailMode = getBoolFromCall(key: "isNeedCustomNativeFailMode", call: call)
        let tmpType : Int = (getNumberFromCall(key: "openType", call: call)).intValue;
        showParams.openType = self.openType(mode: tmpType)
        let failMode : Int = (getNumberFromCall(key: "nativeFailMode", call: call)).intValue;
        showParams.nativeFailMode =  NativeFailMode(mode: failMode)
        let tmpSchemeType : Int = (getNumberFromCall(key: "schemeType", call: call)).intValue;
        showParams.linkKey = schemeType(mode: tmpSchemeType)
        let taokeParam = getTaokeParams(call: call) ?? nil
        let trackParam : Dictionary<String,Any>? = getDicFromCall(key: "trackParam", call: call) ?? nil

        AlibcTradeSDK.sharedInstance().tradeService().open(byBizCode: bizcode, page: page, webView: nil, parentController: rootViewController, showParams: showParams, taoKeParams: taokeParam, trackParam: trackParam) { alibcTradeResult in
            if alibcTradeResult?.result == AlibcTradeResultType.paySuccess {
                self.channel?.invokeMethod(callBackString, arguments: [
                    FlutterAlibcUltimateConstKey.ErrorCode:"0",
                    FlutterAlibcUltimateConstKey.ErrorMessage:"付款成功",
                    FlutterAlibcUltimateConstKey.Data:[
                        "type":0,
                        "paySuccessOrders":alibcTradeResult?.payResult?.paySuccessOrders as Any,
                        "payFailedOrders":alibcTradeResult?.payResult?.payFailedOrders as Any,
                    ]
                ]);
            }else if alibcTradeResult?.result == AlibcTradeResultType.addCard {
                self.channel?.invokeMethod(callBackString, arguments: [
                    FlutterAlibcUltimateConstKey.ErrorCode:"0",
                    FlutterAlibcUltimateConstKey.ErrorMessage:"加入购物车成功",
                    FlutterAlibcUltimateConstKey.Data:["type":1]
                ]);
            }
        } tradeProcessFailedCallback: { error in
            let dic = [FlutterAlibcUltimateConstKey.ErrorCode :String((error! as NSError).code) ,FlutterAlibcUltimateConstKey.ErrorMessage:error?.localizedDescription] as! Dictionary<String,String>
            self.channel?.invokeMethod(callBackString, arguments: [dic]);
        }
    }
}
