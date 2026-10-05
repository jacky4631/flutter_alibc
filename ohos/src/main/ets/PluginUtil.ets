/**
 * 工具类 - 参数解析与枚举转换
 * 对应 Android 端 PluginUtil.kt
 * 使用鸿蒙百川 SDK 的实际类型：AlibcShowParams, AlibcTaokeParams, AlibcDegradeType
 */

import { AlibcConstKey } from './FlutterAlibcConst';
import { AlibcShowParams, AlibcTaokeParams, AlibcDegradeType } from '@ohos/alibc';

/**
 * 构造成功响应
 */
export function buildSuccessResponse(data?: Object): Record<string, Object | null> {
  const result: Record<string, Object | null> = {
    "errorCode": "0",
    "errorMessage": "成功",
    "data": data ?? null
  };
  return result;
}

/**
 * 构造失败响应
 */
export function buildErrorResponse(errorCode: string, errorMessage: string): Record<string, Object | null> {
  const result: Record<string, Object | null> = {
    "errorCode": errorCode,
    "errorMessage": errorMessage,
    "data": null
  };
  return result;
}

/**
 * 根据 Dart 层传入的索引值获取 clientType 字符串
 * 0 -> "tmall", 1 -> "taobao"
 */
export function getClientType(schemeTypeIndex: number): string {
  if (schemeTypeIndex === AlibcConstKey.TaoBaoSchemeType) {
    return "taobao";
  }
  return "tmall";
}

/**
 * 根据 Dart 层传入的索引值获取 AlibcDegradeType
 * 0 -> H5, 1 -> Download, 2 -> NONE
 */
export function getDegradeType(failModeIndex: number): AlibcDegradeType {
  if (failModeIndex === AlibcConstKey.JumpH5FailMode) {
    return AlibcDegradeType.H5;
  } else if (failModeIndex === AlibcConstKey.JumpDownloadPageFailMode) {
    return AlibcDegradeType.Download;
  }
  return AlibcDegradeType.NONE;
}

/**
 * 从 MethodCall 参数中构建 AlibcShowParams
 */
export function buildShowParams(args: Record<string, Object>): AlibcShowParams {
  const showParams: AlibcShowParams = {
    clientType: getClientType((args[AlibcConstKey.KeySchemeType] as number) ?? 1),
    backUrl: (args[AlibcConstKey.KeyBackUrl] as string) ?? '',
  };

  const isNeedCustomFailMode = (args[AlibcConstKey.KeyIsNeedCustomNativeFailMode] as boolean) ?? false;
  if (isNeedCustomFailMode) {
    const failModeIndex = (args[AlibcConstKey.KeyNativeFailMode] as number) ?? 2;
    showParams.degradeType = getDegradeType(failModeIndex);
  }

  return showParams;
}

/**
 * 从 MethodCall 参数中构建 AlibcTaokeParams
 */
export function buildTaokeParams(args: Record<string, Object>): AlibcTaokeParams {
  const taokeParams: AlibcTaokeParams = {};
  const taokeParamsMap = args[AlibcConstKey.KeyTaokeParams] as Record<string, Object> | null;

  if (taokeParamsMap !== null && taokeParamsMap !== undefined) {
    taokeParams.pid = (taokeParamsMap["pid"] as string) ?? '';
    taokeParams.unionId = (taokeParamsMap["unionId"] as string) ?? '';
    taokeParams.subPid = (taokeParamsMap["subPid"] as string) ?? '';

    const extParamsObj = taokeParamsMap["extParams"] as Record<string, string> | null;
    if (extParamsObj !== null && extParamsObj !== undefined) {
      const extMap = new Map<string, string>();
      Object.entries(extParamsObj).forEach((item: [string, string]) => {
        extMap.set(item[0], item[1]);
      });
      taokeParams.extParams = extMap;
    }
  }

  return taokeParams;
}
