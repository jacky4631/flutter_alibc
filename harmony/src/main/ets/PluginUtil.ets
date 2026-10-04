/**
 * 工具类 - 参数解析与枚举转换
 * 对应 Android 端 PluginUtil.kt
 */

import { AlibcConstKey } from './FlutterAlibcConst';

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
 * 获取 OpenType 字符串
 * 0 -> "auto", 1 -> "native"
 */
export function getOpenType(openTypeIndex: number): string {
  if (openTypeIndex === AlibcConstKey.NativeOpenType) {
    return "native";
  }
  return "auto";
}

/**
 * 获取 SchemeType 字符串
 * 0 -> "tmall", 1 -> "taobao"
 */
export function getSchemeType(schemeTypeIndex: number): string {
  if (schemeTypeIndex === AlibcConstKey.TaoBaoSchemeType) {
    return "taobao";
  }
  return "tmall";
}

/**
 * 获取 NativeFailMode 字符串
 * 0 -> "jumpH5", 1 -> "jumpDownloadPage", 2 -> "none"
 */
export function getNativeFailMode(failModeIndex: number): string {
  if (failModeIndex === AlibcConstKey.JumpH5FailMode) {
    return "jumpH5";
  } else if (failModeIndex === AlibcConstKey.JumpDownloadPageFailMode) {
    return "jumpDownloadPage";
  }
  return "none";
}

/**
 * 从 taokeParams Map 中提取淘客参数
 */
export function getTaokeParams(taokeParamsMap: Record<string, Object> | null): Record<string, string> | null {
  if (taokeParamsMap === null || taokeParamsMap === undefined) {
    return null;
  }
  const result: Record<string, string> = {
    "adzoneId": (taokeParamsMap["adzoneId"] as string) ?? "",
    "pid": (taokeParamsMap["pid"] as string) ?? "",
    "unionId": (taokeParamsMap["unionId"] as string) ?? "",
    "subPid": (taokeParamsMap["subPid"] as string) ?? "",
  };
  return result;
}
