// To parse this JSON data, do
//
//     final payTmCurrencyCodeErrorModel = payTmCurrencyCodeErrorModelFromJson(jsonString);

import 'dart:convert';

PayTmCurrencyCodeErrorModel payTmCurrencyCodeErrorModelFromJson(String str) => PayTmCurrencyCodeErrorModel.fromJson(json.decode(str));

String payTmCurrencyCodeErrorModelToJson(PayTmCurrencyCodeErrorModel data) => json.encode(data.toJson());

class PayTmCurrencyCodeErrorModel {
  PayTmCurrencyCodeErrorModel({
    required this.head,
    required this.body,
  });

  Head head;
  Body body;

  factory PayTmCurrencyCodeErrorModel.fromJson(Map<String, dynamic> json) => PayTmCurrencyCodeErrorModel(
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
    this.extraParamsMap,
    required this.resultInfo,
  });

  dynamic extraParamsMap;
  ResultInfo resultInfo;

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        extraParamsMap: json["extraParamsMap"],
        resultInfo: ResultInfo.fromJson(json["resultInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "extraParamsMap": extraParamsMap,
        "resultInfo": resultInfo.toJson(),
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
    this.requestId,
    required this.responseTimestamp,
    required this.version,
  });

  dynamic requestId;
  String responseTimestamp;
  String version;

  factory Head.fromJson(Map<String, dynamic> json) => Head(
        requestId: json["requestId"],
        responseTimestamp: json["responseTimestamp"],
        version: json["version"],
      );

  Map<String, dynamic> toJson() => {
        "requestId": requestId,
        "responseTimestamp": responseTimestamp,
        "version": version,
      };
}
