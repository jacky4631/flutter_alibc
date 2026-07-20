import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_alibc_ultimate/albc_tools.dart';
import 'package:flutter_alibc_ultimate/alibc_const_key.dart';
import 'package:flutter_alibc_ultimate/alibc_model.dart';

typedef LoginCallback = void Function(LoginModel model);
typedef OpenCallback = void Function(TradeResult model);
typedef CommonCallback = void Function(Map<String, dynamic> map);

class FlutterAlibcUltimate {
  // 通信的桥接类
  static final MethodChannel _channel = const MethodChannel("flutter_alibc_ultimate")
    ..setMethodCallHandler(_platformCallHandler);

  static Map<CallBackType, Function?> _callBackMaps = {
    CallBackType.AlibcTaobaoLogin: null,
    CallBackType.AlibcTaokeLogin: null,
    CallBackType.AlibcTaokeLoginForCode: null,
    CallBackType.AlibcOpenURL: null,
    CallBackType.AlibcOpenCar: null,
    CallBackType.AlibcOpenDetail: null,
    CallBackType.AlibcOpenShop: null,
  };

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  ///初始化
  ///version:当前app版本
  ///appName:当前app名称
  static Future<InitModel> initAlibc({String? version, String? appName}) async {
    Map result = await _channel
        .invokeMethod("initAlibc", {"version": version, "appName": appName});
    return InitModel(
        result[AlibcConstKey.errorCode], result[AlibcConstKey.errorMessage]);
  }

  /// 登录淘宝
  static void loginTaoBao({required LoginCallback loginCallback}) async {
    _channel.invokeMethod("loginTaoBao");
    _callBackMaps[CallBackType.AlibcTaobaoLogin] = loginCallback;
  }

  /// 退出淘宝登录
  static loginOut() {
    _channel.invokeMethod("loginOut");
  }

  /// 渠道授权，获取access_token
  static void taoKeLogin(
      {required String url,
      AlibcOpenType openType = AlibcOpenType.AlibcOpenTypeAuto,
      bool isNeedCustomNativeFailMode = false,
      AlibcNativeFailMode nativeFailMode =
          AlibcNativeFailMode.AlibcNativeFailModeNone,
      AlibcSchemeType schemeType = AlibcSchemeType.AlibcSchemeTaoBao,
      TaokeParams? taokeParams,
      String? backUrl,
      required CommonCallback taokeCallback}) async {
    Map? taoKe = AlibcTools.getTaokeMap(taokeParams);
    _channel.invokeMethod("taoKeLogin", {
      "url": url,
      "openType": openType.index,
      "isNeedCustomNativeFailMode": isNeedCustomNativeFailMode,
      "nativeFailMode": nativeFailMode.index,
      "schemeType": schemeType.index,
      "taokeParams": taoKe,
      "backUrl": backUrl,
    });
    _callBackMaps[CallBackType.AlibcTaokeLogin] = taokeCallback;
  }

  /// 关闭淘客登录的webview
  static closeAlibcWebview() {
    _channel.invokeMethod("closeAlibcWebview");
  }

  /// 渠道授权，获取 code 授权码
  static void taoKeLoginForCode({
    required String url,
    AlibcOpenType openType = AlibcOpenType.AlibcOpenTypeAuto,
    bool isNeedCustomNativeFailMode = false,
    AlibcNativeFailMode nativeFailMode =
        AlibcNativeFailMode.AlibcNativeFailModeNone,
    AlibcSchemeType schemeType = AlibcSchemeType.AlibcSchemeTaoBao,
    TaokeParams? taokeParams,
    String? backUrl,
    required CommonCallback taokeCallback,
  }) async {
    Map? taoKe = AlibcTools.getTaokeMap(taokeParams);
    _channel.invokeMethod("taoKeLoginForCode", {
      "url": url,
      "openType": openType.index,
      "isNeedCustomNativeFailMode": isNeedCustomNativeFailMode,
      "nativeFailMode": nativeFailMode.index,
      "schemeType": schemeType.index,
      "taokeParams": taoKe,
      "backUrl": backUrl
    });
    _callBackMaps[CallBackType.AlibcTaokeLoginForCode] = taokeCallback;
  }

  static Future<dynamic> _platformCallHandler(MethodCall call) async {
    var argu = call.arguments;
    print(
        'call.name ${call.method}  call.arguments ${call.arguments.toString()}');
    CallBackType? type = enumFromString(CallBackType.values, call.method);
    print(argu.runtimeType.toString());
    var temp = Map<String, dynamic>();
    (argu as Map).forEach((key, value) {
      temp['$key'] = value;
    });
    switch (type) {
      case CallBackType.AlibcTaobaoLogin:
        argu = LoginModel(
            argu[AlibcConstKey.errorCode], argu[AlibcConstKey.errorMessage],
            data: UserModel(
                argu[AlibcConstKey.data]["nick"],
                argu[AlibcConstKey.data]["avatarUrl"],
                argu[AlibcConstKey.data]["openId"],
                argu[AlibcConstKey.data]["openSid"],
                argu[AlibcConstKey.data]["topAccessToken"],
                argu[AlibcConstKey.data]["topAuthCode"]));
        break;
      case CallBackType.AlibcTaokeLogin:
      case CallBackType.AlibcTaokeLoginForCode:
        argu = temp;
        break;
      case CallBackType.AlibcOpenURL:
      case CallBackType.AlibcOpenCar:
      case CallBackType.AlibcOpenDetail:
      case CallBackType.AlibcOpenShop:
        TradeResult tradeResult = AlibcTools.getTradeResult(temp);
        argu = tradeResult;
        break;
      default:
        print("unsupport method handler");
        return;
    }
    Function? f = _callBackMaps[type];
    if (f != null) {
      f(argu);
      _callBackMaps[type!] = null;
    }
  }

  /// 通过url打开,包括h5，唤起手淘等
  static void openByUrl({
    required String url,
    AlibcOpenType openType = AlibcOpenType.AlibcOpenTypeAuto,
    bool isNeedCustomNativeFailMode = false,
    AlibcNativeFailMode nativeFailMode =
        AlibcNativeFailMode.AlibcNativeFailModeNone,
    AlibcSchemeType schemeType = AlibcSchemeType.AlibcSchemeTmall,
    TaokeParams? taokeParams,
    String? backUrl,
    OpenCallback? callback,
  }) async {
    Map? taoKe = AlibcTools.getTaokeMap(taokeParams);
    _channel.invokeMethod("openByUrl", {
      "url": url,
      "openType": openType.index,
      "isNeedCustomNativeFailMode": isNeedCustomNativeFailMode,
      "nativeFailMode": nativeFailMode.index,
      "schemeType": schemeType.index,
      "taokeParams": taoKe,
      "backUrl": backUrl
    });
    _callBackMaps[CallBackType.AlibcOpenURL] = callback;
  }

  /// 打开商品详情
  static void openItemDetail(
      {required String itemID,
      AlibcOpenType openType = AlibcOpenType.AlibcOpenTypeAuto,
      bool isNeedCustomNativeFailMode = false,
      AlibcNativeFailMode nativeFailMode =
          AlibcNativeFailMode.AlibcNativeFailModeNone,
      AlibcSchemeType schemeType = AlibcSchemeType.AlibcSchemeTmall,
      TaokeParams? taokeParams,
      Map? trackParam,
      String? backUrl,
      OpenCallback? callback}) async {
    Map? taoKe = AlibcTools.getTaokeMap(taokeParams);
    _channel.invokeMethod("openItemDetail", {
      "itemID": itemID,
      "openType": openType.index,
      "isNeedCustomNativeFailMode": isNeedCustomNativeFailMode,
      "nativeFailMode": nativeFailMode.index,
      "schemeType": schemeType.index,
      "taokeParams": taoKe,
      "trackParam": trackParam,
      "backUrl": backUrl
    });
    _callBackMaps[CallBackType.AlibcOpenDetail] = callback;
  }

  /// 打开店铺
  static void openShop(
      {required String shopId,
      AlibcOpenType openType = AlibcOpenType.AlibcOpenTypeAuto,
      bool isNeedCustomNativeFailMode = false,
      AlibcNativeFailMode nativeFailMode =
          AlibcNativeFailMode.AlibcNativeFailModeNone,
      AlibcSchemeType schemeType = AlibcSchemeType.AlibcSchemeTmall,
      TaokeParams? taokeParams,
      Map? trackParam,
      String? backUrl,
      OpenCallback? callback}) async {
    Map? taoKe = AlibcTools.getTaokeMap(taokeParams);

    _channel.invokeMethod("openShop", {
      "shopId": shopId,
      "openType": openType.index,
      "isNeedCustomNativeFailMode": isNeedCustomNativeFailMode,
      "nativeFailMode": nativeFailMode.index,
      "schemeType": schemeType.index,
      "taokeParams": taoKe,
      "trackParam": trackParam,
      "backUrl": backUrl
    });
    _callBackMaps[CallBackType.AlibcOpenShop] = callback;
  }

  /// 打开购物车
  static void openCart(
      {AlibcOpenType openType = AlibcOpenType.AlibcOpenTypeAuto,
      bool isNeedCustomNativeFailMode = false,
      AlibcNativeFailMode nativeFailMode =
          AlibcNativeFailMode.AlibcNativeFailModeNone,
      AlibcSchemeType schemeType = AlibcSchemeType.AlibcSchemeTmall,
      TaokeParams? taokeParams,
      Map? trackParam,
      String? backUrl,
      OpenCallback? callback}) async {
    Map? taoKe = AlibcTools.getTaokeMap(taokeParams);

    _channel.invokeMethod("openCart", {
      "openType": openType.index,
      "isNeedCustomNativeFailMode": isNeedCustomNativeFailMode,
      "nativeFailMode": nativeFailMode.index,
      "schemeType": schemeType.index,
      "taokeParams": taoKe,
      "trackParam": trackParam,
      "backUrl": backUrl
    });
    _callBackMaps[CallBackType.AlibcOpenCar] = callback;
  }

  // 是否需要设置打点
  static syncForTaoke(bool isSync) {
    _channel.invokeMethod("syncForTaoke", {"isSync": isSync});
  }

  // 是否需要 Native AliPay 接口
  static useAlipayNative(bool isNeed) {
    _channel.invokeMethod("useAlipayNative", {"isNeed": isNeed});
  }
}
