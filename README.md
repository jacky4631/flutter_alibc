# flutter_alibc

Flutter版本的阿里百川，原作者维护太慢，这个插件以后我自己维护。

苹果安卓测试没问题，已上架稳定运行四个多月。使用时记得升级最新版安全图，记得看下面的注意点。

## iOS Swift Package Manager

本插件同时提供 SPM 和 CocoaPods 集成。SPM 最低 iOS 13，清单位于
`ios/flutter_alibc/Package.swift`，库产品名为 `flutter-alibc`。
SPM 集成要求 Flutter 3.44 及以上（提供 `FlutterFramework` 包），并由 Flutter 自动集成；
较早版本请继续使用 CocoaPods。遵循
[Flutter 官方迁移说明](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors)。

### 百川资源配置（SPM 必需）

旧版百川 SDK 从主应用 bundle 查找资源，而 SPM 把资源放在独立 bundle 中。
SDK 是静态库，代码已经链接进 App；Xcode 嵌入静态 framework 时可能生成空 dylib
占位文件，iOS 安装器会拒绝这些包。以下脚本同时复制资源、清除这 20 个 SDK 的占位包。
只针对本仓库的静态 SDK 使用清理逻辑；升级到动态 SDK 时须同步调整。
在宿主 Xcode 工程 Runner 的 Build Phases 中，添加 Run Script，放在资源复制之后、
签名之前，使用以下脚本把 SDK 的五个资源 bundle 复制到主应用中。
仓库 example 已配置此脚本。其他宿主应用需
取消勾选 “Based on dependency analysis”，并将 Runner 的
`ENABLE_USER_SCRIPT_SANDBOXING` 设为 `NO`（Flutter 构建脚本也使用此配置）。

```sh
set -eu
sdk_resources="${BUILT_PRODUCTS_DIR}/flutter_alibc_flutter_alibc.bundle"
app_resources="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
for name in AlibabaAuthSDK NBResource NebulaWK SmartLink WindVaneBasic; do
  /usr/bin/ditto "${sdk_resources}/${name}.bundle" "${app_resources}/${name}.bundle"
done

# These SDKs are static archives, already linked into the app executable.
# Xcode creates empty dylib placeholders when embedding static frameworks.
# Keep the SDK resource bundles above; do not ship those placeholders.
app_frameworks="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
for name in AlibabaAuthEntrance AlibabaAuthExt AlibabaAuthSDK AlibcLinkPartnerSDK AlibcTradeBiz AlibcTradeSDK MtopSDK SGIndieKit SGMain SGMiddleTier SGNoCaptcha SGSecurityBody SecurityGuardSDK UTDID UTMini WindVane WindVaneBasic WindVaneCore mtopcoreopen mtopext; do
  /bin/rm -rf "${app_frameworks}/${name}.framework"
done
```

安全图片 `yw_1222_baichuan.jpg` 仍由宿主应用提供，并加入 Runner 的
Copy Bundle Resources；URL Schemes、回跳和百川应用配置沿用原有说明。
CocoaPods 通过 podspec 自动复制 SDK 资源，无需上述脚本。

### 二进制和验证

`ios/flutter_alibc/Frameworks` 包含从仓库原始 framework 拆分的 20 个 XCFramework，
支持 arm64 真机和 x86_64 模拟器。原 SDK 不包含 arm64 模拟器二进制；
Apple Silicon 上建议使用真机，或使用 Xcode 支持的 Rosetta x86_64 模拟器。
重新打包不会生成缺失架构。更新原 SDK 后，在 macOS 安装 Xcode 并执行：

```sh
python3 tool/build_ios_xcframeworks.py
```

原始 framework 保留为重新打包的输入；SPM 和 CocoaPods 共用 XCFramework 和 Swift 源码。
示例通过 `path: ../` 引用本地插件。支持 Dart 2.12 至 Dart 3。
验证运行时请在真机检查初始化、淘宝登录、URL 回跳和交易页面。

# 百川SDK版本

```
Android标准版  4.1.0.8 
iOS标准版      4.1.0.4
```

# flutter版本要求
```
sdk: '>=2.12.0'
```


## 开始配置
### 工程性配置

参考[阿里百川官网](https://baichuan.taobao.com/docs/doc.htm?spm=a3c0d.7629140.0.0.a838be48k4hYDc&treeId=129&articleId=106383&docType=1)

Android: 注意在新版本gradle编译时,会强制校验远程仓库是否存在.pom文件, 阿里百川仓库目前缺少.pom文件, 因此目前先使用较低版本gradle

### 注意点

1. 该版本需使用V6.1版本的安全图片，V6.1版本的安全图片可在[百川套件平台](https://suite.baichuan.taobao.com/?spm=a3c0d.7629140.0.0.70e6be48TzC7BS)下载。
2. 通过第1步，重新下载V6版本的安全图，并把yw_1222.jpg文件名改为yw_1222_baichuan.jpg。

### 方法说明

* 头文件引入

``` dart
import 'package:alibc_kit/flutter_alibc.dart';
```

* 初始化

``` dart
 /**
   * 初始化
   * version:当前app版本
   * appName:当前app名称
   * result:{
   * errorCode,     //0为初始化成功，其他为失败
   * errorMessage,  //message
   * }
   */
var result = await FlutterAlibc.initAlibc(version:"",appName:"");
```

* 登录淘宝

``` dart
/**
   * 登录淘宝
   * result :{
   * errorCode,     //0为初始化成功，其他为失败
   * errorMessage,  //message
   * data:{					//登录成功的情况下返回data，为用户数据
   * 	//nick 用户昵称，avatarUrl 头像地址
	 *  nick,avatarUrl,openId,openSid,topAccessToken,topAuthCode
   * 	}
   * }
   * 备注：登录过会直接返回淘宝用户的信息，不会多次唤醒淘宝，请放心
   */
    FlutterAlibc.loginTaoBao(callback:(result){
        print("登录淘宝  ${result.data.nick} ${result.data.topAccessToken}");
    });
```

* 淘宝登出

``` dart
FlutterAlibc.loginOut();
```

* 淘客登录，二次授权获取access_token

``` dart
 /**
   * @description: 获取access_token
   * @param 
   * url:用于授权登录的url
   * openType:打开类型,默认auto
   * isNeedCustomNativeFailMode:是否需要设置唤端失败策略，默认false
   * nativeFailMode:唤端失败策略，默认None
   * schemeType:唤起哪个端，默认天猫
   * taokeParams:淘客数据
   * backUrl: 跳转回来的url
   * result: {"data":{"accessToken":"xxx"},"errorMessage":"成功","errorCode":"0"}//获取成功为token，获取失败为空字符串
   */
    FlutterAlibc.taoKeLogin(
        url:"",	//必须参数，用于授权登录的url
        openType : AlibcOpenType.AlibcOpenTypeAuto,
        isNeedCustomNativeFailMode : false,
        nativeFailMode :    AlibcNativeFailMode.AlibcNativeFailModeNone,
        schemeType : AlibcSchemeType.AlibcSchemeTmall,
        taokeParams : {},
        backUrl:"",
        callback: (result){
            print('淘客登录 ' + json.encode(result));
        },
    );
```

* 淘客登录，二次授权获取code

``` dart
 /**
   * @description: 获取code
   * @param 
   * url:用于授权登录的url
   * openType:打开类型,默认auto
   * isNeedCustomNativeFailMode:是否需要设置唤端失败策略，默认false
   * nativeFailMode:唤端失败策略，默认None
   * schemeType:唤起哪个端，默认天猫
   * taokeParams:淘客数据
   * backUrl: 跳转回来的url
   * result: {"data":{"code":"xxx"},"errorMessage":"成功","errorCode":"0"}//获取成功为code，获取失败为空字符串
   */
    FlutterAlibc.taoKeLoginForCode(
        url:"",	//必须参数，用于授权登录的url
        openType : AlibcOpenType.AlibcOpenTypeAuto,
        isNeedCustomNativeFailMode : false,
        nativeFailMode :    AlibcNativeFailMode.AlibcNativeFailModeNone,
        schemeType : AlibcSchemeType.AlibcSchemeTmall,
        taokeParams : {},
        backUrl:"",
        callback: (result){
            print('淘客登录 ' + json.encode(result));
        },
    );
```

* 唤起淘宝，openByUrl方式

``` dart
 /**
   * @description: 通过url打开,包括h5，唤起手淘等
   * @param 
   * url:目标url
   * openType:打开类型,默认auto
   * isNeedCustomNativeFailMode:是否需要设置唤端失败策略，默认false
   * nativeFailMode:唤端失败策略，默认None
   * schemeType:唤起哪个端，默认天猫
   * taokeParams:淘客数据
   * backUrl: 跳转回来的url
   * result: {
   *		errorCode,
   *		errorMessage,
   *		type,			//0为添加购物车，1为付款成功
   *		payResult,	//type为1时返回
   *  }
   */
   FlutterAlibc.openByUrl(
        url:"",	//必须参数
        openType : AlibcOpenType.AlibcOpenTypeAuto,
        isNeedCustomNativeFailMode : false,
        nativeFailMode :    AlibcNativeFailMode.AlibcNativeFailModeNone,
        schemeType : AlibcSchemeType.AlibcSchemeTmall,
        taokeParams : {},
        backUrl:"",
        callback: (result){
            print('openByURL ' + json.encode(result));
        },
  );
```

* 唤起淘宝，openItemDetail方式

``` dart
/**
   * @description: 打开商品详情
   * @param 
   * itemID 商品id，可以是真实的也可以是混淆的，必须参数
   * trackParam	需要额外追踪的业务数据
   * 其他同上
   * @return: 同openByUrl
   */
    FlutterAlibc.openItemDetail(
        itemID:"",	//必须参数
        openType : AlibcOpenType.AlibcOpenTypeAuto,
        isNeedCustomNativeFailMode : false,
        nativeFailMode :    AlibcNativeFailMode.AlibcNativeFailModeNone,
        schemeType : AlibcSchemeType.AlibcSchemeTmall,
        taokeParams : {},
        trackParam : {}, //需要额外追踪的业务数据
        backUrl:"",
        callback: (result){
            print('openItemDetail ' + json.encode(result));
        },
    );
```

* 打开店铺，openShop方式

``` dart
/**
   * @description: 打开店铺
   * @param 
   * shopId 店铺id，必须参数
   * 其他同上
   * result: 同openByUrl
   */
    FlutterAlibc.openShop(
        shopId:"",	//必须参数
        openType : AlibcOpenType.AlibcOpenTypeAuto,
        isNeedCustomNativeFailMode : false,
        nativeFailMode :    AlibcNativeFailMode.AlibcNativeFailModeNone,
        schemeType : AlibcSchemeType.AlibcSchemeTmall,
        taokeParams : {},
        trackParam : {}, //需要额外追踪的业务数据
        backUrl:"",
        callback: (result){
              print('openShop ' + json.encode(result));
        },
    );
```

* 打开购物车，openCart方式

``` dart
/**
   * @description: 打开购物车
   * @param 
   * 无必须参数
   * 其他同上
   * result: 同openByUrl
   */
    FlutterAlibc.openCart(
        openType : AlibcOpenType.AlibcOpenTypeAuto,
        isNeedCustomNativeFailMode : false,
        nativeFailMode :    AlibcNativeFailMode.AlibcNativeFailModeNone,
        schemeType : AlibcSchemeType.AlibcSchemeTmall,
        taokeParams : {},
        trackParam : {}, //需要额外追踪的业务数据
        backUrl:"",
        callback: (result){
              print('openShop ' + json.encode(result));
        },
    );
```


* 是否设置同步打点

``` dart
FlutterAlibc.syncForTaoke(true);
````

* 是否使用Native Alipay

``` dart
FlutterAlibc.useAlipayNative(true);
```
