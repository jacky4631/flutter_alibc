/**
 * 阿里百川 Flutter 插件 - 鸿蒙端主类
 * 对应 Android 端 FlutterAlibcPlugin.kt / iOS 端 SwiftFlutterAlibcPlugin.swift
 *
 * 注册 MethodChannel("flutter_alibc")，分发所有方法调用到 FlutterAlibcHandle
 */

import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import FlutterAlibcHandle from './FlutterAlibcHandle';
import { buildSuccessResponse, buildErrorResponse } from './PluginUtil';
import { AlibcConstKey } from './FlutterAlibcConst';

const CHANNEL_NAME: string = "flutter_alibc";
const TAG: string = 'FlutterAlibcPlugin';

export default class FlutterAlibcPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private channel: MethodChannel | null = null;
  private handle: FlutterAlibcHandle | null = null;
  private context: common.UIAbilityContext | null = null;

  getUniqueClassName(): string {
    return "FlutterAlibcPlugin";
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    console.info(TAG, 'onAttachedToEngine');
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
    this.handle = new FlutterAlibcHandle(this.channel);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    console.info(TAG, 'onDetachedFromEngine');
    this.channel?.setMethodCallHandler(null);
    this.handle?.dispose();
    this.channel = null;
    this.handle = null;
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    console.info(TAG, 'onAttachedToAbility');
    this.context = binding.getAbility().context;
    if (this.handle !== null && this.context !== null) {
      this.handle.setContext(this.context);
    }
  }

  onDetachedFromAbility(): void {
    console.info(TAG, 'onDetachedFromAbility');
    this.context = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "getPlatformVersion":
        result.success("HarmonyOS");
        break;

      case "initAlibc": {
        const version = call.argument<string>("version") ?? null;
        const appName = call.argument<string>("appName") ?? null;
        this.handle?.initAlibc(version, appName, (response: Record<string, Object | null>) => {
          result.success(response);
        });
        break;
      }

      case "loginTaoBao":
        this.handle?.loginTaoBao();
        // 登录结果通过 channel.invokeMethod 异步回调，此处不直接 result
        break;

      case "loginOut":
        this.handle?.logoutTaoBao((response: Record<string, Object | null>) => {
          result.success(response);
        });
        break;

      case "taoKeLogin": {
        const args = call.arguments as Record<string, Object>;
        this.handle?.taoKeLogin(args);
        break;
      }

      case "taoKeLoginForCode": {
        const args = call.arguments as Record<string, Object>;
        this.handle?.taoKeLoginForCode(args);
        break;
      }

      case "openByUrl": {
        const args = call.arguments as Record<string, Object>;
        this.handle?.openByUrl(args, (response: Record<string, Object | null>) => {
          // openByUrl 的结果通过 channel.invokeMethod 回调
        });
        break;
      }

      case "openItemDetail": {
        const args = call.arguments as Record<string, Object>;
        this.handle?.openItemDetail(args, (response: Record<string, Object | null>) => {
          // openItemDetail 的结果通过 channel.invokeMethod 回调
        });
        break;
      }

      case "openShop": {
        const args = call.arguments as Record<string, Object>;
        this.handle?.openShop(args, (response: Record<string, Object | null>) => {
          // openShop 的结果通过 channel.invokeMethod 回调
        });
        break;
      }

      case "openCart": {
        const args = call.arguments as Record<string, Object>;
        this.handle?.openCart(args, (response: Record<string, Object | null>) => {
          // openCart 的结果通过 channel.invokeMethod 回调
        });
        break;
      }

      case "syncForTaoke": {
        const isSync = call.argument<boolean>("isSync") ?? false;
        this.handle?.syncForTaoke(isSync);
        break;
      }

      case "useAlipayNative": {
        const isNeed = call.argument<boolean>("isNeed") ?? false;
        this.handle?.useAlipayNative(isNeed);
        break;
      }

      default:
        result.notImplemented();
        break;
    }
  }
}
