// To parse this JSON data, do
//
//     final stripePayFailedModel = stripePayFailedModelFromJson(jsonString);

import 'dart:convert';

StripePayFailedModel stripePayFailedModelFromJson(String str) => StripePayFailedModel.fromJson(json.decode(str));

String stripePayFailedModelToJson(StripePayFailedModel data) => json.encode(data.toJson());

class StripePayFailedModel {
  StripePayFailedModel({
    required this.error,
  });

  Error error;

  factory StripePayFailedModel.fromJson(Map<String, dynamic> json) => StripePayFailedModel(
        error: Error.fromJson(json["error"]),
      );

  Map<String, dynamic> toJson() => {
        "error": error.toJson(),
      };
}

class Error {
  Error({
    required this.code,
    required this.localizedMessage,
    required this.message,
    required this.stripeErrorCode,
    required this.declineCode,
    required this.type,
  });

  String code;
  String localizedMessage;
  String message;
  dynamic stripeErrorCode;
  dynamic declineCode;
  dynamic type;

  factory Error.fromJson(Map<String, dynamic> json) => Error(
        code: json["code"],
        localizedMessage: json["localizedMessage"],
        message: json["message"],
        stripeErrorCode: json["stripeErrorCode"],
        declineCode: json["declineCode"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "localizedMessage": localizedMessage,
        "message": message,
        "stripeErrorCode": stripeErrorCode,
        "declineCode": declineCode,
        "type": type,
      };
}
