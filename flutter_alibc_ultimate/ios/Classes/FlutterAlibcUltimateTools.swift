//
//  FlutterAlibcUltimateTools.swift
//  flutter_alibc_ultimate
//

import Foundation

class FlutterAlibcUltimateTools: NSObject {
    class func isNil(_ string: String?) -> Bool {
        if string == nil { return true }
        if (string is NSNull) { return true }
        return (string?.trimmingCharacters(in: CharacterSet.whitespaces).count ?? 0) == 0
    }

    class func dictionary(withJsonString jsonString: String?) -> [AnyHashable : Any]? {
        if jsonString == nil { return nil }
        let jsonData = jsonString?.data(using: .utf8)
        var err: Error?
        var dic: [AnyHashable : Any]? = nil
        do {
            if let jsonData = jsonData {
                dic = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [AnyHashable : Any]
            }
        } catch let error {
            err = error
        }
        if err != nil { return nil }
        return dic
    }

    class func null(toNil obj: Any?) -> Any? {
        if (obj is NSNull) { return nil }
        return obj
    }

    class func changeType(_ myObj: Any?) -> Any? {
        if (myObj is [AnyHashable : Any]) {
            return self.nullDic(myObj as? [AnyHashable : Any])
        } else if (myObj is [AnyHashable]) {
            return self.nullArr(myObj as? [AnyHashable])
        } else if (myObj is String) {
            return self.string(to: myObj as? String)
        } else if (myObj is NSNull) {
            return self.nullToString()
        } else {
            return myObj
        }
    }

    class func nullDic(_ myDic: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
        let keyArr = myDic?.keys
        var resDic: [AnyHashable : Any] = [:]
        return resDic
    }

    class func nullArr(_ myArr: [AnyHashable]?) -> [AnyHashable]? {
        var resArr: [AnyHashable] = []
        for i in 0..<(myArr?.count ?? 0) {
            var obj = myArr?[i]
            obj = self.changeType(obj) as? AnyHashable
            if let obj = obj { resArr.append(obj) }
        }
        return resArr
    }

    class func string(to string: String?) -> String? { return string }
    class func nullToString() -> String? { return "" }
}
