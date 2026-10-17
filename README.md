# flutter_alibc

## 平台支持

本插件封装了阿里百川（淘宝联盟）SDK，通过 `MethodChannel` 桥接三端原生实现：

| 平台 | 目录 | 说明 |
| --- | --- | --- |
| Android | `android/` | 标准版 4.1.0.8，本地 aar/jar 依赖 |
| iOS | `ios/` | 标准版 4.1.0.4，同时支持 CocoaPods 与 SPM |
| HarmonyOS（鸿蒙） | `ohos/` | 基于鸿蒙百川 SDK，部分能力见下方「鸿蒙端说明」 |

## 安装

在 `pubspec.yaml` 中添加依赖：

``` yaml
dependencies:
  flutter_alibc: <版本号>
```

或直接引用本地/远程仓库：

``` yaml
dependencies:
  flutter_alibc:
    git:
      url: https://gitee.com/jacky4631/flutter_alibc.git
```

> iOS 通过 CocoaPods 集成会自动复制 SDK 资源；使用 SPM 集成需按下方「百川资源配置」添加脚本。

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
Android标准版     4.1.0.8
iOS标准版         4.1.0.4
HarmonyOS（鸿蒙） 基于鸿蒙百川 SDK
```

# flutter版本要求
```
sdk: '>=2.12.0 <4.0.0'   # 支持 Dart 2.12 空安全至 Dart 3
flutter: ">=1.20.0"
```


## 开始配置
### 工程性配置

参考[阿里百川官网](https://baichuan.taobao.com/docs/doc.htm?spm=a3c0d.7629140.0.0.a838be48k4hYDc&treeId=129&articleId=106383&docType=1)

Android: 注意在新版本gradle编译时,会强制校验远程仓库是否存在.pom文件, 阿里百川仓库目前缺少.pom文件, 因此目前先使用较低版本gradle

### 注意点

1. 该版本需使用V6.1版本的安全图片，V6.1版本的安全图片可在[百川套件平台](https://suite.baichuan.taobao.com/?spm=a3c0d.7629140.0.0.70e6be48TzC7BS)下载。
2. 通过第1步，重新下载V6版本的安全图，并把yw_1222.jpg文件名改为yw_1222_baichuan.jpg。

## 方法说明

所有方法均为 `FlutterAlibc` 的静态方法，除 `initAlibc` 返回 `Future` 外，登录 / 唤端类方法通过回调（callback）异步返回结果。

* 头文件引入

``` dart
import 'package:flutter_alibc/flutter_alibc.dart';
import 'package:flutter_alibc/alibc_model.dart';      // 数据模型（TaokeParams 等）
import 'package:flutter_alibc/alibc_const_key.dart';  // 枚举（AlibcOpenType 等）
```

* 初始化

``` dart
/**
 * 初始化
 * version: 当前app版本
 * appName: 当前app名称
 * 返回 InitModel: { errorCode, errorMessage }  // errorCode 为 "0" 表示初始化成功，其他为失败
 */
InitModel result = await FlutterAlibc.initAlibc(version: "", appName: "");
```

* 登录淘宝

``` dart
/**
 * 登录淘宝
 * 回调 LoginModel: {
 *   errorCode,     // "0" 为成功，其他为失败
 *   errorMessage,
 *   data: UserModel { nick, avatarUrl, openId, openSid, topAccessToken, topAuthCode }
 * }
 * 备注：登录过会直接返回淘宝用户的信息，不会多次唤醒淘宝，请放心
 */
FlutterAlibc.loginTaoBao(loginCallback: (LoginModel result) {
    print("登录淘宝  ${result.data?.nick} ${result.data?.topAccessToken}");
});
```

* 淘宝登出

``` dart
FlutterAlibc.loginOut();
```

* 淘客登录，二次授权获取 access_token

``` dart
/**
 * 获取 access_token（对应官方 Client-side flow）
 * url: 用于授权登录的url（必须参数）
 * openType: 打开类型，默认 AlibcOpenTypeAuto
 * isNeedCustomNativeFailMode: 是否需要设置唤端失败策略，默认 false
 * nativeFailMode: 唤端失败策略，默认 AlibcNativeFailModeNone
 * schemeType: 唤起哪个端，默认 AlibcSchemeTaoBao
 * taokeParams: 淘客数据（TaokeParams 对象，可空）
 * backUrl: 跳转回来的url
 * taokeCallback: 回调 Map，成功形如 {"data":{"accessToken":"xxx"},"errorCode":"0"}，失败 accessToken 为空字符串
 */
FlutterAlibc.taoKeLogin(
    url: "", // 必须参数，用于授权登录的url
    openType: AlibcOpenType.AlibcOpenTypeAuto,
    isNeedCustomNativeFailMode: false,
    nativeFailMode: AlibcNativeFailMode.AlibcNativeFailModeNone,
    schemeType: AlibcSchemeType.AlibcSchemeTmall,
    taokeParams: TaokeParams(pid: "", unionId: "", subPid: ""),
    backUrl: "",
    taokeCallback: (map) {
        print('淘客登录 ' + json.encode(map));
    },
);
```

* 淘客登录，二次授权获取 code

``` dart
/**
 * 获取 code 授权码（对应官方 Server-side flow），参数与 taoKeLogin 一致
 * taokeCallback: 回调 Map，成功形如 {"data":{"code":"xxx"},"errorCode":"0"}，失败 code 为空字符串
 * 注意：url 中的 redirect_uri 需与开发者后台配置的应用回调地址一致
 */
FlutterAlibc.taoKeLoginForCode(
    url: "",
    openType: AlibcOpenType.AlibcOpenTypeAuto,
    isNeedCustomNativeFailMode: false,
    nativeFailMode: AlibcNativeFailMode.AlibcNativeFailModeNone,
    schemeType: AlibcSchemeType.AlibcSchemeTmall,
    taokeParams: TaokeParams(),
    backUrl: "",
    taokeCallback: (map) {
        print('淘客登录 ' + json.encode(map));
    },
);
```

* 关闭淘客登录 WebView

``` dart
// 主动关闭二次授权打开的 WebView
FlutterAlibc.closeAlibcWebview();
```

* 唤起淘宝，openByUrl方式

``` dart
/**
 * 通过url打开，包括h5，唤起手淘等
 * url: 目标url（必须参数）
 * 其余参数同上（openType / nativeFailMode / schemeType / taokeParams / backUrl）
 * callback: 回调 TradeResult: {
 *   errorCode, errorMessage,
 *   type,       // TradeResultType，AddCard=加购，PaySuccess=付款成功
 *   payResult,  // type 为付款成功时返回：{ paySuccessOrders, payFailedOrders }
 * }
 */
FlutterAlibc.openByUrl(
    url: "", // 必须参数
    openType: AlibcOpenType.AlibcOpenTypeAuto,
    isNeedCustomNativeFailMode: false,
    nativeFailMode: AlibcNativeFailMode.AlibcNativeFailModeNone,
    schemeType: AlibcSchemeType.AlibcSchemeTmall,
    taokeParams: TaokeParams()..pid = "mm_xxx",
    backUrl: "",
    callback: (TradeResult result) {
        print('openByURL ' + json.encode(result));
    },
);
```

* 唤起淘宝，openItemDetail方式

``` dart
/**
 * 打开商品详情
 * itemID: 商品id，可以是真实的也可以是混淆的（必须参数）
 * trackParam: 需要额外追踪的业务数据（Map，可空）
 * 其余参数及返回值同 openByUrl
 */
FlutterAlibc.openItemDetail(
    itemID: "", // 必须参数
    openType: AlibcOpenType.AlibcOpenTypeAuto,
    isNeedCustomNativeFailMode: false,
    nativeFailMode: AlibcNativeFailMode.AlibcNativeFailModeNone,
    schemeType: AlibcSchemeType.AlibcSchemeTmall,
    taokeParams: TaokeParams(),
    trackParam: {}, // 需要额外追踪的业务数据
    backUrl: "",
    callback: (TradeResult result) {
        print('openItemDetail ' + json.encode(result));
    },
);
```

* 打开店铺，openShop方式

``` dart
/**
 * 打开店铺
 * shopId: 店铺id（必须参数）
 * 其余参数及返回值同 openItemDetail
 */
FlutterAlibc.openShop(
    shopId: "", // 必须参数
    openType: AlibcOpenType.AlibcOpenTypeAuto,
    isNeedCustomNativeFailMode: false,
    nativeFailMode: AlibcNativeFailMode.AlibcNativeFailModeNone,
    schemeType: AlibcSchemeType.AlibcSchemeTmall,
    taokeParams: TaokeParams(),
    trackParam: {},
    backUrl: "",
    callback: (TradeResult result) {
        print('openShop ' + json.encode(result));
    },
);
```

* 打开购物车，openCart方式

``` dart
/**
 * 打开购物车
 * 无必须参数，其余参数及返回值同 openByUrl
 */
FlutterAlibc.openCart(
    openType: AlibcOpenType.AlibcOpenTypeAuto,
    isNeedCustomNativeFailMode: false,
    nativeFailMode: AlibcNativeFailMode.AlibcNativeFailModeNone,
    schemeType: AlibcSchemeType.AlibcSchemeTmall,
    taokeParams: TaokeParams(),
    trackParam: {},
    backUrl: "",
    callback: (TradeResult result) {
        print('openCart ' + json.encode(result));
    },
);
```

* 是否设置同步打点

``` dart
FlutterAlibc.syncForTaoke(true);
```

* 是否使用Native Alipay

``` dart
FlutterAlibc.useAlipayNative(true);
```

## 枚举说明

| 枚举 | 取值 | 含义 |
| --- | --- | --- |
| `AlibcOpenType` | `AlibcOpenTypeAuto` / `AlibcOpenTypeNative` | 智能判断 / 强制拉端（手淘、天猫） |
| `AlibcNativeFailMode` | `AlibcNativeFailModeJumpH5` / `AlibcNativeFailModeJumpDownloadPage` / `AlibcNativeFailModeNone` | 拉起失败后：跳 H5（默认）/ 跳下载页 / 不做额外操作 |
| `AlibcSchemeType` | `AlibcSchemeTmall` / `AlibcSchemeTaoBao` | 唤起天猫 / 淘宝 |
| `TradeResultType` | `AlibcTradeResultTypePaySuccess` / `AlibcTradeResultTypeAddCard` | 付款成功 / 加购成功 |

## 数据模型说明

| 模型 | 主要字段 | 用途 |
| --- | --- | --- |
| `InitModel` | `errorCode`、`errorMessage` | 初始化结果 |
| `LoginModel` | `errorCode`、`errorMessage`、`data: UserModel` | 淘宝登录结果 |
| `UserModel` | `nick`、`avatarUrl`、`openId`、`openSid`、`topAccessToken`、`topAuthCode` | 登录用户信息 |
| `TaokeParams` | `adzoneId`、`pid`、`unionId`、`subPid`、`extParams` | 淘客参数（有 adzoneId 则 pid 失效） |
| `TradeResult` | `errorCode`、`errorMessage`、`type`、`payResult` | 唤端 / 交易结果 |
| `PayResult` | `paySuccessOrders`、`payFailedOrders` | 付款成功 / 失败订单列表 |

## 鸿蒙端说明

鸿蒙（HarmonyOS）端已完成初始化、登录 / 登出、淘客授权、`openByUrl` 等核心能力。受鸿蒙百川 SDK 接口限制，以下差异需注意：

- `openItemDetail` / `openShop` / `openCart` 暂无独立原生 API，内部降级为拼接对应 H5 地址后通过 `openByUrl` 打开。
- `taoKeLoginForCode` 复用授权能力，将返回的 accessToken 作为 code 透传。
- `syncForTaoke`（打点）、`useAlipayNative`（原生支付宝）鸿蒙 SDK 暂未提供对应接口，当前仅记录日志、不生效。
- 交易类回调的 `type` 统一返回 `AddCard`，付款结果等细分状态以真机验证为准。
