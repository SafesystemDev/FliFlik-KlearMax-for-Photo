// To parse this JSON data, do
//
//     final paytmPaySuccessModel = paytmPaySuccessModelFromJson(jsonString);

import 'dart:convert';

PaytmPaySuccessModel paytmPaySuccessModelFromJson(String str) => PaytmPaySuccessModel.fromJson(json.decode(str));

String paytmPaySuccessModelToJson(PaytmPaySuccessModel data) => json.encode(data.toJson());

class PaytmPaySuccessModel {
  PaytmPaySuccessModel({
    required this.currency,
    required this.gatewayname,
    required this.respmsg,
    required this.bankname,
    required this.paymentmode,
    required this.mid,
    required this.respcode,
    required this.txnamount,
    required this.txnid,
    required this.orderid,
    required this.status,
    required this.banktxnid,
    required this.txndate,
    required this.checksumhash,
  });

  String currency;
  String gatewayname;
  String respmsg;
  String bankname;
  String paymentmode;
  String mid;
  String respcode;
  String txnamount;
  String txnid;
  String orderid;
  String status;
  String banktxnid;
  DateTime txndate;
  String checksumhash;

  factory PaytmPaySuccessModel.fromJson(Map<String, dynamic> json) => PaytmPaySuccessModel(
        currency: json["CURRENCY"],
        gatewayname: json["GATEWAYNAME"],
        respmsg: json["RESPMSG"],
        bankname: json["BANKNAME"],
        paymentmode: json["PAYMENTMODE"],
        mid: json["MID"],
        respcode: json["RESPCODE"],
        txnamount: json["TXNAMOUNT"],
        txnid: json["TXNID"],
        orderid: json["ORDERID"],
        status: json["STATUS"],
        banktxnid: json["BANKTXNID"],
        txndate: DateTime.parse(json["TXNDATE"]),
        checksumhash: json["CHECKSUMHASH"],
      );

  Map<String, dynamic> toJson() => {
        "CURRENCY": currency,
        "GATEWAYNAME": gatewayname,
        "RESPMSG": respmsg,
        "BANKNAME": bankname,
        "PAYMENTMODE": paymentmode,
        "MID": mid,
        "RESPCODE": respcode,
        "TXNAMOUNT": txnamount,
        "TXNID": txnid,
        "ORDERID": orderid,
        "STATUS": status,
        "BANKTXNID": banktxnid,
        "TXNDATE": txndate.toIso8601String(),
        "CHECKSUMHASH": checksumhash,
      };
}
