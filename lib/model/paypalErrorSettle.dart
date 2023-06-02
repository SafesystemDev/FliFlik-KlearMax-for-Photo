// To parse this JSON data, do
//
//     final payPalErrorSettelModel = payPalErrorSettelModelFromJson(jsonString);

import 'dart:convert';

PayPalErrorSettleModel payPalErrorSettelModelFromJson(String str) => PayPalErrorSettleModel.fromJson(json.decode(str));

String payPalErrorSettelModelToJson(PayPalErrorSettleModel data) => json.encode(data.toJson());

class PayPalErrorSettleModel {
  PayPalErrorSettleModel({
    required this.success,
    required this.data,
  });

  bool success;
  Data data;

  factory PayPalErrorSettleModel.fromJson(Map<String, dynamic> json) => PayPalErrorSettleModel(
        success: json["success"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.toJson(),
      };
}

class Data {
  Data({
    required this.errors,
    required this.params,
    required this.message,
    this.creditCardVerification,
    this.transaction,
    this.subscription,
    this.merchantAccount,
    this.verification,
  });

  List<Error> errors;
  Params params;
  String message;
  dynamic creditCardVerification;
  dynamic transaction;
  dynamic subscription;
  dynamic merchantAccount;
  dynamic verification;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        errors: List<Error>.from(json["errors"].map((x) => Error.fromJson(x))),
        params: Params.fromJson(json["params"]),
        message: json["message"],
        creditCardVerification: json["creditCardVerification"],
        transaction: json["transaction"],
        subscription: json["subscription"],
        merchantAccount: json["merchantAccount"],
        verification: json["verification"],
      );

  Map<String, dynamic> toJson() => {
        "errors": List<dynamic>.from(errors.map((x) => x.toJson())),
        "params": params.toJson(),
        "message": message,
        "creditCardVerification": creditCardVerification,
        "transaction": transaction,
        "subscription": subscription,
        "merchantAccount": merchantAccount,
        "verification": verification,
      };
}

class Error {
  Error();

  factory Error.fromJson(Map<String, dynamic> json) => Error();

  Map<String, dynamic> toJson() => {};
}

class Params {
  Params({
    required this.transaction,
  });

  Transaction transaction;

  factory Params.fromJson(Map<String, dynamic> json) => Params(
        transaction: Transaction.fromJson(json["transaction"]),
      );

  Map<String, dynamic> toJson() => {
        "transaction": transaction.toJson(),
      };
}

class Transaction {
  Transaction({
    required this.correlationId,
    required this.type,
    required this.amount,
    required this.paymentMethodNonce,
    required this.options,
  });

  String correlationId;
  String type;
  String amount;
  String paymentMethodNonce;
  Options options;

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        correlationId: json["correlationId"],
        type: json["type"],
        amount: json["amount"],
        paymentMethodNonce: json["paymentMethodNonce"],
        options: Options.fromJson(json["options"]),
      );

  Map<String, dynamic> toJson() => {
        "correlationId": correlationId,
        "type": type,
        "amount": amount,
        "paymentMethodNonce": paymentMethodNonce,
        "options": options.toJson(),
      };
}

class Options {
  Options({
    required this.submitForSettlement,
  });

  String submitForSettlement;

  factory Options.fromJson(Map<String, dynamic> json) => Options(
        submitForSettlement: json["submitForSettlement"],
      );

  Map<String, dynamic> toJson() => {
        "submitForSettlement": submitForSettlement,
      };
}
