// To parse this JSON data, do
//
//     final getPaymentTxtTokenModel = getPaymentTxtTokenModelFromJson(jsonString);

import 'dart:convert';

GetPaymentTxtTokenModel getPaymentTxtTokenModelFromJson(String str) => GetPaymentTxtTokenModel.fromJson(json.decode(str));

String getPaymentTxtTokenModelToJson(GetPaymentTxtTokenModel data) => json.encode(data.toJson());

class GetPaymentTxtTokenModel {
  GetPaymentTxtTokenModel({
    required this.head,
    required this.body,
  });

  Head head;
  Body body;

  factory GetPaymentTxtTokenModel.fromJson(Map<String, dynamic> json) => GetPaymentTxtTokenModel(
        head: Head.fromJson(json["head"]),
        body: Body.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
        "head": head.toJson(),
        "body": body.toJson(),
      };
}

class Body {
  Body({
    required this.resultInfo,
    required this.txnToken,
    required this.isPromoCodeValid,
    required this.authenticated,
  });

  ResultInfo resultInfo;
  String txnToken;
  bool isPromoCodeValid;
  bool authenticated;

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        resultInfo: ResultInfo.fromJson(json["resultInfo"]),
        txnToken: json["txnToken"],
        isPromoCodeValid: json["isPromoCodeValid"],
        authenticated: json["authenticated"],
      );

  Map<String, dynamic> toJson() => {
        "resultInfo": resultInfo.toJson(),
        "txnToken": txnToken,
        "isPromoCodeValid": isPromoCodeValid,
        "authenticated": authenticated,
      };
}

class ResultInfo {
  ResultInfo({
    required this.resultStatus,
    required this.resultCode,
    required this.resultMsg,
  });

  String resultStatus;
  String resultCode;
  String resultMsg;

  factory ResultInfo.fromJson(Map<String, dynamic> json) => ResultInfo(
        resultStatus: json["resultStatus"],
        resultCode: json["resultCode"],
        resultMsg: json["resultMsg"],
      );

  Map<String, dynamic> toJson() => {
        "resultStatus": resultStatus,
        "resultCode": resultCode,
        "resultMsg": resultMsg,
      };
}

class Head {
  Head({
    required this.responseTimestamp,
    required this.version,
    required this.signature,
  });

  String responseTimestamp;
  String version;
  String signature;

  factory Head.fromJson(Map<String, dynamic> json) => Head(
        responseTimestamp: json["responseTimestamp"],
        version: json["version"],
        signature: json["signature"],
      );

  Map<String, dynamic> toJson() => {
        "responseTimestamp": responseTimestamp,
        "version": version,
        "signature": signature,
      };
}
