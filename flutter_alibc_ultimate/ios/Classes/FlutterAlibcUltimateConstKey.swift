//
//  FlutterAlibcUltimateConstKey.swift
//  flutter_alibc_ultimate
//

import Foundation

struct FlutterAlibcUltimateConstKey {
    static let ErrorCode :String = "errorCode"
    static let ErrorMessage:String  = "errorMessage"
    static let Data: String = "data"
    static let EmptyNum : NSNumber = NSNumber(integerLiteral: 5285)

    enum CallBackString:String{
        case AlibcTaobaoLogin = "AlibcTaobaoLogin"
        case AlibcTaokeLogin = "AlibcTaokeLogin"
        case AlibcTaokeLoginForCode = "AlibcTaokeLoginForCode"
        case AlibcOpenURL = "AlibcOpenURL"
        case AlibcOpenCar = "AlibcOpenCar"
        case AlibcOpenDetail = "AlibcOpenDetail"
        case AlibcOpenShop = "AlibcOpenShop"
    }
}
