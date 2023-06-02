// To parse this JSON data, do
//
//     final payStackUrlModel = payStackUrlModelFromJson(jsonString);

import 'dart:convert';

PayStackUrlModel payStackUrlModelFromJson(String str) => PayStackUrlModel.fromJson(json.decode(str));

String payStackUrlModelToJson(PayStackUrlModel data) => json.encode(data.toJson());

class PayStackUrlModel {
  PayStackUrlModel({
    required this.status,
    required this.message,
    required this.data,
  });

  bool status;
  String message;
  Data data;

  factory PayStackUrlModel.fromJson(Map<String, dynamic> json) => PayStackUrlModel(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  Data({
    required this.authorizationUrl,
    required this.accessCode,
    required this.reference,
  });

  String authorizationUrl;
  String accessCode;
  String reference;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        authorizationUrl: json["authorization_url"],
        accessCode: json["access_code"],
        reference: json["reference"],
      );

  Map<String, dynamic> toJson() => {
        "authorization_url": authorizationUrl,
        "access_code": accessCode,
        "reference": reference,
      };
}
