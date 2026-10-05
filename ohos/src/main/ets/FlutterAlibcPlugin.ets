/**
 * 阿里百川 Flutter 插件 - 鸿蒙端主类
 * 对应 Android 端 FlutterAlibcPlugin.kt / iOS 端 SwiftFlutterAlibcPlugin.swift
 *
 * 注册 MethodChannel("flutter_alibc")，分发所有方法调用到 FlutterAlibcHandle
 */

import {
  AbilityAware,
  NewWantListener,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import hilog from '@ohos.hilog';
import { Alibc } from '@ohos/alibc';
import FlutterAlibcHandle from './FlutterAlibcHandle';
import { AlibcConstKey } from './FlutterAlibcConst';

const CHANNEL_NAME: string = "flutter_alibc";
const TAG: string = 'FlutterAlibcPlugin';
const DOMAIN: number = 0xF101;

export default class FlutterAlibcPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware, NewWantListener {
  private channel: MethodChannel | null = null;
  private handle: FlutterAlibcHandle | null = null;
  private context: common.UIAbilityContext | null = null;
  private abilityBinding: AbilityPluginBinding | null = null;

  getUniqueClassName(): string {
    return "FlutterAlibcPlugin";
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    hilog.info(DOMAIN, TAG, 'onAttachedToEngine');
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
    this.handle = new FlutterAlibcHandle(this.channel);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    hilog.info(DOMAIN, TAG, 'onDetachedFromEngine');
    this.channel?.setMethodCallHandler(null);
    this.handle?.dispose();
    this.channel = null;
    this.handle = null;
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    hilog.info(DOMAIN, TAG, 'onAttachedToAbility');
    this.context = binding.getAbility().context;
    this.abilityBinding = binding;
    binding.addOnNewWantListener(this);
    if (this.handle !== null && this.context !== null) {
      this.handle.setContext(this.context);
    }
  }

  onDetachedFromAbility(): void {
    hilog.info(DOMAIN, TAG, 'onDetachedFromAbility');
    this.abilityBinding?.removeOnNewWantListener(this);
    this.abilityBinding = null;
    this.context = null;
  }

  onNewWant(want: Want, launchParams: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'onNewWant -> Alibc.onNewWant');
    Alibc.onNewWant(want);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "getPlatformVersion":
        result.success("HarmonyOS");
        break;

      case "initAlibc": {
        const version: string = ((call.args as Record<string, Object>)[AlibcConstKey.KeyVersion] ?? '') as string;
        const appName: string = ((call.args as Record<string, Object>)[AlibcConstKey.KeyAppName] ?? '') as string;
        this.handle?.initAlibc(version, appName, (response: Record<string, Object | null>) => {
          result.success(response);
        });
        break;
      }

      case "loginTaoBao":
        this.handle?.loginTaoBao();
        // 登录结果通过 channel.invokeMethod 异步回调
        break;

      case "loginOut":
        this.handle?.logoutTaoBao((response: Record<string, Object | null>) => {
          result.success(response);
        });
        break;

      case "taoKeLogin": {
        const args = call.args as Record<string, Object>;
        this.handle?.taoKeLogin(args);
        break;
      }

      case "taoKeLoginForCode": {
        const args = call.args as Record<string, Object>;
        this.handle?.taoKeLoginForCode(args);
        break;
      }

      case "openByUrl": {
        const args = call.args as Record<string, Object>;
        this.handle?.openByUrl(args);
        break;
      }

      case "openItemDetail": {
        const args = call.args as Record<string, Object>;
        this.handle?.openItemDetail(args);
        break;
      }

      case "openShop": {
        const args = call.args as Record<string, Object>;
        this.handle?.openShop(args);
        break;
      }

      case "openCart": {
        const args = call.args as Record<string, Object>;
        this.handle?.openCart(args);
        break;
      }

      case "syncForTaoke": {
        const isSync: boolean = ((call.args as Record<string, Object>)[AlibcConstKey.KeyIsSync] ?? false) as boolean;
        this.handle?.syncForTaoke(isSync);
        break;
      }

      case "useAlipayNative": {
        const isNeed: boolean = ((call.args as Record<string, Object>)[AlibcConstKey.KeyIsNeed] ?? false) as boolean;
        this.handle?.useAlipayNative(isNeed);
        break;
      }

      default:
        result.notImplemented();
        break;
    }
  }
}
