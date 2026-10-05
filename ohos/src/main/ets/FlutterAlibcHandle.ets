/**
 * 阿里百川业务处理类
 * 对应 Android 端 FlutterAlibcHandle.kt
 * 使用鸿蒙百川 SDK 实际 API：Alibc.init / login / logout / authorize / openByUrl
 */

import { MethodChannel } from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import hilog from '@ohos.hilog';
import { Alibc, AlibcShowParams, AlibcTaokeParams } from '@ohos/alibc';
import { AlibcConstKey, CallBackType, TradeResultType } from './FlutterAlibcConst';
import { buildSuccessResponse, buildErrorResponse, buildShowParams, buildTaokeParams } from './PluginUtil';

const TAG: string = 'FlutterAlibcHandle';
const DOMAIN: number = 0xF101;

export default class FlutterAlibcHandle {
  private channel: MethodChannel | null = null;
  private context: common.UIAbilityContext | null = null;

  constructor(channel: MethodChannel) {
    this.channel = channel;
  }

  setContext(context: common.UIAbilityContext): void {
    this.context = context;
  }

  dispose(): void {
    this.channel = null;
    this.context = null;
  }

  /**
   * 初始化阿里百川
   * 对应 SDK: Alibc.init({ context, onSuccess, onFailure })
   */
  initAlibc(version: string | null, appName: string | null, callback: (result: Record<string, Object | null>) => void): void {
    if (this.context === null) {
      callback(buildErrorResponse("-1", "context is null, please call init after ability attached"));
      return;
    }

    Alibc.init({
      context: this.context,
      onSuccess: () => {
        hilog.info(DOMAIN, TAG, 'Alibc init success');
        callback(buildSuccessResponse());
      },
      onFailure: (code: number, msg: string) => {
        hilog.error(DOMAIN, TAG, 'Alibc init fail code: %{public}d, msg: %{public}s', code, msg);
        callback(buildErrorResponse(code.toString(), msg));
      }
    });
  }

  /**
   * 登录淘宝
   * 对应 SDK: Alibc.login({ onSuccess, onFailure })
   * 登录成功后通过 channel.invokeMethod 回调 Dart 层
   */
  loginTaoBao(): void {
    Alibc.login({
      onSuccess: (user) => {
        hilog.info(DOMAIN, TAG, 'login success, openId: %{public}s', user?.openId ?? '');
        const userInfo: Record<string, string> = {
          "nick": '',
          "avatarUrl": user?.avatarUrl ?? '',
          "openId": user?.openId ?? '',
          "openSid": user?.openSid ?? '',
          "topAccessToken": user?.topAccessToken ?? '',
          "topAuthCode": user?.topAuthCode ?? '',
        };
        this.channel?.invokeMethod(CallBackType.AlibcTaobaoLogin, buildSuccessResponse(userInfo));
      },
      onFailure: (code: string, msg: string) => {
        hilog.error(DOMAIN, TAG, 'login fail code: %{public}s, msg: %{public}s', code, msg);
        this.channel?.invokeMethod(CallBackType.AlibcTaobaoLogin, buildErrorResponse(code, msg));
      }
    });
  }

  /**
   * 登出淘宝
   * 对应 SDK: Alibc.logout({ onComplete })
   */
  logoutTaoBao(callback: (result: Record<string, Object | null>) => void): void {
    Alibc.logout({
      onComplete: () => {
        hilog.info(DOMAIN, TAG, 'logout complete');
        callback(buildSuccessResponse());
      }
    });
  }

  /**
   * 淘客授权登录 - 获取 access_token
   * 对应 SDK: Alibc.authorize({ appName, appLogoSrc, appKey, onSuccess, onFailure })
   */
  taoKeLogin(args: Record<string, Object>): void {
    const url = (args[AlibcConstKey.KeyUrl] as string) ?? "";

    Alibc.authorize({
      appName: 'flutter_alibc',
      appKey: Alibc.getAppKey(),
      appLogoSrc: $r('app.media.icon'),
      onSuccess: (params) => {
        hilog.info(DOMAIN, TAG, 'authorize success, accessToken: %{public}s', params.accessToken);
        const resMap: Record<string, string> = {
          "accessToken": params.accessToken
        };
        this.channel?.invokeMethod(CallBackType.AlibcTaokeLogin, buildSuccessResponse(resMap));
      },
      onFailure: (code: string, msg: string) => {
        hilog.error(DOMAIN, TAG, 'authorize fail code: %{public}s, msg: %{public}s', code, msg);
        this.channel?.invokeMethod(CallBackType.AlibcTaokeLogin, buildErrorResponse(code, msg));
      }
    });
  }

  /**
   * 淘客授权登录 - 获取 code 授权码
   * 鸿蒙 SDK 的 authorize 返回的是 accessToken，
   * 如果需要 code，可能需要通过不同的参数或 API 实现。
   * 暂时复用 authorize，将返回的 accessToken 作为 code 传递。
   * TODO: 确认鸿蒙 SDK 是否有单独获取 code 的 API
   */
  taoKeLoginForCode(args: Record<string, Object>): void {
    const url = (args[AlibcConstKey.KeyUrl] as string) ?? "";

    Alibc.authorize({
      appName: 'flutter_alibc',
      appKey: Alibc.getAppKey(),
      appLogoSrc: $r('app.media.icon'),
      onSuccess: (params) => {
        hilog.info(DOMAIN, TAG, 'authorize for code success, accessToken: %{public}s', params.accessToken);
        const resMap: Record<string, string> = {
          "code": params.accessToken
        };
        this.channel?.invokeMethod(CallBackType.AlibcTaokeLoginForCode, buildSuccessResponse(resMap));
      },
      onFailure: (code: string, msg: string) => {
        hilog.error(DOMAIN, TAG, 'authorize for code fail code: %{public}s, msg: %{public}s', code, msg);
        this.channel?.invokeMethod(CallBackType.AlibcTaokeLoginForCode, buildErrorResponse(code, msg));
      }
    });
  }

  /**
   * 通过 URL 方式打开淘宝
   * 对应 SDK: Alibc.openByUrl({ url, onSuccess, onFailure, showParams, taokeParams, needBaichuanLinkConvert })
   */
  openByUrl(args: Record<string, Object>): void {
    const url = (args[AlibcConstKey.KeyUrl] as string) ?? "";
    const showParams: AlibcShowParams = buildShowParams(args);
    const taokeParams: AlibcTaokeParams = buildTaokeParams(args);

    Alibc.openByUrl({
      url,
      showParams,
      taokeParams,
      needBaichuanLinkConvert: false,
      onSuccess: (code: number, msg: string) => {
        hilog.info(DOMAIN, TAG, 'openByUrl success code: %{public}d, msg: %{public}s', code, msg);
        const results: Record<string, Object> = {
          "type": TradeResultType.AddCard,
        };
        this.channel?.invokeMethod(CallBackType.AlibcOpenURL, buildSuccessResponse(results));
      },
      onFailure: (code: number, msg: string) => {
        hilog.error(DOMAIN, TAG, 'openByUrl fail code: %{public}d, msg: %{public}s', code, msg);
        this.channel?.invokeMethod(CallBackType.AlibcOpenURL, buildErrorResponse(code.toString(), msg));
      }
    });
  }

  /**
   * 打开商品详情
   * 鸿蒙 SDK 可能没有 openByBizCode，通过 openByUrl 方式实现
   * TODO: 确认 SDK 是否有 openItemDetail 或 openByBizCode API
   */
  openItemDetail(args: Record<string, Object>): void {
    const itemID = (args[AlibcConstKey.KeyItemID] as string) ?? "";
    const showParams: AlibcShowParams = buildShowParams(args);
    const taokeParams: AlibcTaokeParams = buildTaokeParams(args);

    // 尝试使用 SDK 可能提供的 openItemDetail API
    // 如果不存在，则降级为 openByUrl
    const itemUrl = `https://item.taobao.com/item.htm?id=${itemID}`;

    Alibc.openByUrl({
      url: itemUrl,
      showParams,
      taokeParams,
      needBaichuanLinkConvert: false,
      onSuccess: (code: number, msg: string) => {
        hilog.info(DOMAIN, TAG, 'openItemDetail success code: %{public}d, msg: %{public}s', code, msg);
        const results: Record<string, Object> = {
          "type": TradeResultType.AddCard,
        };
        this.channel?.invokeMethod(CallBackType.AlibcOpenDetail, buildSuccessResponse(results));
      },
      onFailure: (code: number, msg: string) => {
        hilog.error(DOMAIN, TAG, 'openItemDetail fail code: %{public}d, msg: %{public}s', code, msg);
        this.channel?.invokeMethod(CallBackType.AlibcOpenDetail, buildErrorResponse(code.toString(), msg));
      }
    });
  }

  /**
   * 打开店铺
   * TODO: 确认 SDK 是否有 openShop API
   */
  openShop(args: Record<string, Object>): void {
    const shopId = (args[AlibcConstKey.KeyShopId] as string) ?? "";
    const showParams: AlibcShowParams = buildShowParams(args);
    const taokeParams: AlibcTaokeParams = buildTaokeParams(args);

    const shopUrl = `https://shop.m.taobao.com/shop/shop_index.htm?shopId=${shopId}`;

    Alibc.openByUrl({
      url: shopUrl,
      showParams,
      taokeParams,
      needBaichuanLinkConvert: false,
      onSuccess: (code: number, msg: string) => {
        hilog.info(DOMAIN, TAG, 'openShop success code: %{public}d, msg: %{public}s', code, msg);
        const results: Record<string, Object> = {
          "type": TradeResultType.AddCard,
        };
        this.channel?.invokeMethod(CallBackType.AlibcOpenShop, buildSuccessResponse(results));
      },
      onFailure: (code: number, msg: string) => {
        hilog.error(DOMAIN, TAG, 'openShop fail code: %{public}d, msg: %{public}s', code, msg);
        this.channel?.invokeMethod(CallBackType.AlibcOpenShop, buildErrorResponse(code.toString(), msg));
      }
    });
  }

  /**
   * 打开购物车
   * TODO: 确认 SDK 是否有 openCart API
   */
  openCart(args: Record<string, Object>): void {
    const showParams: AlibcShowParams = buildShowParams(args);
    const taokeParams: AlibcTaokeParams = buildTaokeParams(args);

    const cartUrl = 'https://h5.m.taobao.com/awp/base/cart.htm';

    Alibc.openByUrl({
      url: cartUrl,
      showParams,
      taokeParams,
      needBaichuanLinkConvert: false,
      onSuccess: (code: number, msg: string) => {
        hilog.info(DOMAIN, TAG, 'openCart success code: %{public}d, msg: %{public}s', code, msg);
        const results: Record<string, Object> = {
          "type": TradeResultType.AddCard,
        };
        this.channel?.invokeMethod(CallBackType.AlibcOpenCar, buildSuccessResponse(results));
      },
      onFailure: (code: number, msg: string) => {
        hilog.error(DOMAIN, TAG, 'openCart fail code: %{public}d, msg: %{public}s', code, msg);
        this.channel?.invokeMethod(CallBackType.AlibcOpenCar, buildErrorResponse(code.toString(), msg));
      }
    });
  }

  /**
   * 设置淘客打点策略
   * TODO: 确认鸿蒙 SDK 是否有对应的 setSyncForTaoke API
   */
  syncForTaoke(isSync: boolean): void {
    hilog.info(DOMAIN, TAG, 'syncForTaoke: %{public}s', isSync.toString());
    // 鸿蒙 SDK 暂未提供此 API，如需可后续补充
  }

  /**
   * 设置是否使用原生支付宝
   * TODO: 确认鸿蒙 SDK 是否有对应的 setShouldUseAlipay API
   */
  useAlipayNative(isNeed: boolean): void {
    hilog.info(DOMAIN, TAG, 'useAlipayNative: %{public}s', isNeed.toString());
    // 鸿蒙 SDK 暂未提供此 API，如需可后续补充
  }
}
