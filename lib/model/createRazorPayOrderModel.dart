// To parse this JSON data, do
//
//     final createRazorPayOrderModel = createRazorPayOrderModelFromJson(jsonString);

import 'dart:convert';

CreateRazorPayOrderModel createRazorPayOrderModelFromJson(String str) => CreateRazorPayOrderModel.fromJson(json.decode(str));

String createRazorPayOrderModelToJson(CreateRazorPayOrderModel data) => json.encode(data.toJson());

class CreateRazorPayOrderModel {
  CreateRazorPayOrderModel({
    required this.id,
    required this.entity,
    required this.amount,
    required this.amountPaid,
    required this.amountDue,
    required this.currency,
    required this.receipt,
    required this.offerId,
    required this.status,
    required this.attempts,
    required this.notes,
    required this.createdAt,
  });

  String id;
  String entity;
  int amount;
  int amountPaid;
  int amountDue;
  String currency;
  String receipt;
  dynamic offerId;
  String status;
  int attempts;
  Notes notes;
  int createdAt;

  factory CreateRazorPayOrderModel.fromJson(Map<String, dynamic> json) => CreateRazorPayOrderModel(
        id: json["id"],
        entity: json["entity"],
        amount: json["amount"],
        amountPaid: json["amount_paid"],
        amountDue: json["amount_due"],
        currency: json["currency"],
        receipt: json["receipt"] ?? "",
        offerId: json["offer_id"],
        status: json["status"],
        attempts: json["attempts"],
        notes: Notes.fromJson(json["notes"]),
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "entity": entity,
        "amount": amount,
        "amount_paid": amountPaid,
        "amount_due": amountDue,
        "currency": currency,
        "receipt": receipt,
        "offer_id": offerId,
        "status": status,
        "attempts": attempts,
        "notes": notes.toJson(),
        "created_at": createdAt,
      };
}

class Notes {
  Notes();

  factory Notes.fromJson(Map<String, dynamic> json) => Notes();

  Map<String, dynamic> toJson() => {};
}
