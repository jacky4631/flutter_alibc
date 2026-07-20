// 初始化阿里百川的model
import 'alibc_const_key.dart';

class InitModel {
  String? errorCode;
  String? errorMessage;

  InitModel(this.errorCode, this.errorMessage);

  InitModel.fromJson(Map<String, dynamic> map) {
    this.errorCode = map['errorCode'];
    this.errorMessage = map['errorMessage'];
  }

  Map<String, dynamic> toJson() {
    var data = new Map<String, dynamic>();
    data['errorCode'] = this.errorCode;
    data['errorMessage'] = this.errorMessage;
    return data;
  }
}

class LoginModel {
  String? errorCode;
  String? errorMessage;

  UserModel? data;

  LoginModel(this.errorCode, this.errorMessage, {this.data});

  LoginModel.fromJson(Map<String, dynamic> map) {
    this.errorCode = map['errorCode'];
    this.errorMessage = map['errorMessage'];
    this.data = map['data'];
  }

  Map<String, dynamic> toJson() {
    var data = new Map<String, dynamic>();
    data['errorCode'] = this.errorCode;
    data['errorMessage'] = this.errorMessage;
    data['data'] = this.data;
    return data;
  }
}

// 用户信息
class UserModel {
  final String? nick;
  final String? avatarUrl;
  final String? openId;
  final String? openSid;
  final String? topAccessToken;
  final String? topAuthCode;
  UserModel(this.nick, this.avatarUrl, this.openId, this.openSid,
      this.topAccessToken, this.topAuthCode);
}

// 淘宝客的参数
class TaokeParams {
  String? adzoneId;
  String? pid;
  String? unionId;
  String? subPid;
  Map? extParams;
  TaokeParams(
      {this.adzoneId, this.pid, this.unionId, this.subPid, this.extParams});
}

// url打开或者page打开等的数据
class TradeResult {
  final String? errorCode;
  final String? errorMessage;

  TradeResultType? type;

  PayResult? payResult;

  TradeResult(
    this.errorCode,
    this.errorMessage, {
    this.type,
    this.payResult,
  });
}

// 付款成功的result
class PayResult {
  final List<String>? paySuccessOrders;
  final List<String>? payFailedOrders;

  PayResult(this.paySuccessOrders, this.payFailedOrders);
}
