import 'package:collection/collection.dart' show IterableExtension;

class AlibcConstKey {
  static String errorCode = "errorCode";
  static String errorMessage = "errorMessage";
  static String platform = "platform";
  static String data = "data";

  static String platform_ios = "iOS";
  static String platform_andriod = "andriod";
  static String platform_harmony = "harmony";
}

///  成功支付
///  成功添加到购物车
enum TradeResultType {
  AlibcTradeResultTypePaySuccess,
  AlibcTradeResultTypeAddCard
}

///  智能判断
///  强制拉端(手淘/天猫)
enum AlibcOpenType { AlibcOpenTypeAuto, AlibcOpenTypeNative }

//  拉起手淘失败后的处理策略
enum AlibcNativeFailMode {
  AlibcNativeFailModeJumpH5,
  AlibcNativeFailModeJumpDownloadPage,
  AlibcNativeFailModeNone
}

// 天猫
// 淘宝
enum AlibcSchemeType { AlibcSchemeTmall, AlibcSchemeTaoBao }

enum CallBackType {
  AlibcTaobaoLogin,
  AlibcTaokeLogin,
  AlibcTaokeLoginForCode,
  AlibcOpenURL,
  AlibcOpenCar,
  AlibcOpenDetail,
  AlibcOpenShop,
  AlibcOpenPriceProtection
}

T? enumFromString<T>(Iterable<T> values, String value) {
  return values
      .firstWhereOrNull((type) => type.toString().split('.').last == value);
}
