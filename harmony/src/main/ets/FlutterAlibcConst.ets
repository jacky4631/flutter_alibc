/**
 * 阿里百川插件常量定义
 * 与 Dart 层 alibc_const_key.dart 保持一致
 */

export class AlibcConstKey {
  static readonly ErrorCode: string = "errorCode";
  static readonly ErrorMessage: string = "errorMessage";
  static readonly Data: string = "data";
  static readonly Platform: string = "platform";
  static readonly PlatformOhos: string = "ohos";

  // 参数 key
  static readonly KeyOpenType: string = "openType";
  static readonly KeySchemeType: string = "schemeType";
  static readonly KeyBackUrl: string = "backUrl";
  static readonly KeyNativeFailMode: string = "nativeFailMode";
  static readonly KeyIsNeedCustomNativeFailMode: string = "isNeedCustomNativeFailMode";
  static readonly KeyTaokeParams: string = "taokeParams";
  static readonly KeyTrackParam: string = "trackParam";

  // 枚举值 - OpenType
  static readonly AutoOpenType: number = 0;
  static readonly NativeOpenType: number = 1;

  // 枚举值 - SchemeType
  static readonly TmallSchemeType: number = 0;
  static readonly TaoBaoSchemeType: number = 1;

  // 枚举值 - NativeFailMode
  static readonly JumpH5FailMode: number = 0;
  static readonly JumpDownloadPageFailMode: number = 1;
  static readonly NoneFailMode: number = 2;
}

/**
 * 回调类型，与 Dart 层 CallBackType 枚举值一致
 */
export class CallBackType {
  static readonly AlibcTaobaoLogin: string = "AlibcTaobaoLogin";
  static readonly AlibcTaokeLogin: string = "AlibcTaokeLogin";
  static readonly AlibcTaokeLoginForCode: string = "AlibcTaokeLoginForCode";
  static readonly AlibcOpenURL: string = "AlibcOpenURL";
  static readonly AlibcOpenCar: string = "AlibcOpenCar";
  static readonly AlibcOpenDetail: string = "AlibcOpenDetail";
  static readonly AlibcOpenShop: string = "AlibcOpenShop";
}

/**
 * 交易结果类型
 */
export class TradeResultType {
  static readonly PaySuccess: number = 0;
  static readonly AddCard: number = 1;
}
