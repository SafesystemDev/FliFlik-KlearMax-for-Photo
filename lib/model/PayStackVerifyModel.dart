// To parse this JSON data, do
//
//     final payStackUrlModel = payStackUrlModelFromJson(jsonString);

import 'dart:convert';

PayStackVerifyModel payStackUrlModelFromJson(String str) => PayStackVerifyModel.fromJson(json.decode(str));

String payStackUrlModelToJson(PayStackVerifyModel data) => json.encode(data.toJson());

class PayStackVerifyModel {
  PayStackVerifyModel({
    required this.status,
    required this.message,
    required this.data,
  });

  bool status;
  String message;
  Data data;

  factory PayStackVerifyModel.fromJson(Map<String, dynamic> json) => PayStackVerifyModel(
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
    required this.id,
    required this.domain,
    required this.status,
    required this.reference,
    required this.amount,
    required this.message,
    required this.gatewayResponse,
    required this.dataPaidAt,
    required this.dataCreatedAt,
    required this.channel,
    required this.currency,
    required this.ipAddress,
    required this.metadata,
    required this.log,
    required this.fees,
    this.feesSplit,
    required this.authorization,
    required this.customer,
    this.plan,
    required this.split,
    this.orderId,
    required this.paidAt,
    required this.createdAt,
    required this.requestedAmount,
    this.posTransactionData,
    this.source,
    this.feesBreakdown,
    required this.transactionDate,
    required this.planObject,
    required this.subaccount,
  });

  int id;
  String domain;
  String status;
  String reference;
  int amount;
  String message;
  String gatewayResponse;
  DateTime dataPaidAt;
  DateTime dataCreatedAt;
  String channel;
  String currency;
  String ipAddress;
  String metadata;
  Log log;
  int fees;
  dynamic feesSplit;
  Authorization authorization;
  Customer customer;
  dynamic plan;
  PlanObject split;
  dynamic orderId;
  DateTime paidAt;
  DateTime createdAt;
  int requestedAmount;
  dynamic posTransactionData;
  dynamic source;
  dynamic feesBreakdown;
  DateTime transactionDate;
  PlanObject planObject;
  PlanObject subaccount;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        domain: json["domain"],
        status: json["status"],
        reference: json["reference"],
        amount: json["amount"],
        message: json["message"],
        gatewayResponse: json["gateway_response"],
        dataPaidAt: DateTime.parse(json["paid_at"]),
        dataCreatedAt: DateTime.parse(json["created_at"]),
        channel: json["channel"],
        currency: json["currency"],
        ipAddress: json["ip_address"],
        metadata: json["metadata"],
        log: Log.fromJson(json["log"]),
        fees: json["fees"],
        feesSplit: json["fees_split"],
        authorization: Authorization.fromJson(json["authorization"]),
        customer: Customer.fromJson(json["customer"]),
        plan: json["plan"],
        split: PlanObject.fromJson(json["split"]),
        orderId: json["order_id"],
        paidAt: DateTime.parse(json["paidAt"]),
        createdAt: DateTime.parse(json["createdAt"]),
        requestedAmount: json["requested_amount"],
        posTransactionData: json["pos_transaction_data"],
        source: json["source"],
        feesBreakdown: json["fees_breakdown"],
        transactionDate: DateTime.parse(json["transaction_date"]),
        planObject: PlanObject.fromJson(json["plan_object"]),
        subaccount: PlanObject.fromJson(json["subaccount"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "domain": domain,
        "status": status,
        "reference": reference,
        "amount": amount,
        "message": message,
        "gateway_response": gatewayResponse,
        "paid_at": dataPaidAt.toIso8601String(),
        "created_at": dataCreatedAt.toIso8601String(),
        "channel": channel,
        "currency": currency,
        "ip_address": ipAddress,
        "metadata": metadata,
        "log": log.toJson(),
        "fees": fees,
        "fees_split": feesSplit,
        "authorization": authorization.toJson(),
        "customer": customer.toJson(),
        "plan": plan,
        "split": split.toJson(),
        "order_id": orderId,
        "paidAt": paidAt.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
        "requested_amount": requestedAmount,
        "pos_transaction_data": posTransactionData,
        "source": source,
        "fees_breakdown": feesBreakdown,
        "transaction_date": transactionDate.toIso8601String(),
        "plan_object": planObject.toJson(),
        "subaccount": subaccount.toJson(),
      };
}

class Authorization {
  Authorization({
    required this.authorizationCode,
    required this.bin,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.channel,
    required this.cardType,
    required this.bank,
    required this.countryCode,
    required this.brand,
    required this.reusable,
    required this.signature,
    required this.accountName,
  });

  String authorizationCode;
  String bin;
  String last4;
  String expMonth;
  String expYear;
  String channel;
  String cardType;
  String bank;
  String countryCode;
  String brand;
  bool reusable;
  String signature;
  dynamic accountName;

  factory Authorization.fromJson(Map<String, dynamic> json) => Authorization(
        authorizationCode: json["authorization_code"],
        bin: json["bin"],
        last4: json["last4"],
        expMonth: json["exp_month"],
        expYear: json["exp_year"],
        channel: json["channel"],
        cardType: json["card_type"],
        bank: json["bank"],
        countryCode: json["country_code"],
        brand: json["brand"],
        reusable: json["reusable"],
        signature: json["signature"],
        accountName: json["account_name"],
      );

  Map<String, dynamic> toJson() => {
        "authorization_code": authorizationCode,
        "bin": bin,
        "last4": last4,
        "exp_month": expMonth,
        "exp_year": expYear,
        "channel": channel,
        "card_type": cardType,
        "bank": bank,
        "country_code": countryCode,
        "brand": brand,
        "reusable": reusable,
        "signature": signature,
        "account_name": accountName,
      };
}

class Customer {
  Customer({
    required this.id,
    this.firstName,
    this.lastName,
    required this.email,
    required this.customerCode,
    this.phone,
    this.metadata,
    required this.riskAction,
    this.internationalFormatPhone,
  });

  int id;
  dynamic firstName;
  dynamic lastName;
  String email;
  String customerCode;
  dynamic phone;
  dynamic metadata;
  String riskAction;
  dynamic internationalFormatPhone;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        customerCode: json["customer_code"],
        phone: json["phone"],
        metadata: json["metadata"],
        riskAction: json["risk_action"],
        internationalFormatPhone: json["international_format_phone"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "customer_code": customerCode,
        "phone": phone,
        "metadata": metadata,
        "risk_action": riskAction,
        "international_format_phone": internationalFormatPhone,
      };
}

class Log {
  Log({
    required this.startTime,
    required this.timeSpent,
    required this.attempts,
    required this.authentication,
    required this.errors,
    required this.success,
    required this.mobile,
    required this.input,
    required this.history,
  });

  int startTime;
  int timeSpent;
  int attempts;
  String authentication;
  int errors;
  bool success;
  bool mobile;
  List<dynamic> input;
  List<History> history;

  factory Log.fromJson(Map<String, dynamic> json) => Log(
        startTime: json["start_time"],
        timeSpent: json["time_spent"],
        attempts: json["attempts"],
        authentication: json["authentication"],
        errors: json["errors"],
        success: json["success"],
        mobile: json["mobile"],
        input: List<dynamic>.from(json["input"].map((x) => x)),
        history: List<History>.from(json["history"].map((x) => History.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "start_time": startTime,
        "time_spent": timeSpent,
        "attempts": attempts,
        "authentication": authentication,
        "errors": errors,
        "success": success,
        "mobile": mobile,
        "input": List<dynamic>.from(input.map((x) => x)),
        "history": List<dynamic>.from(history.map((x) => x.toJson())),
      };
}

class History {
  History({
    required this.type,
    required this.message,
    required this.time,
  });

  String type;
  String message;
  int time;

  factory History.fromJson(Map<String, dynamic> json) => History(
        type: json["type"],
        message: json["message"],
        time: json["time"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "message": message,
        "time": time,
      };
}

class PlanObject {
  PlanObject();

  factory PlanObject.fromJson(Map<String, dynamic> json) => PlanObject();

  Map<String, dynamic> toJson() => {};
}
