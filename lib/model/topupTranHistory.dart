import 'package:cloud_firestore/cloud_firestore.dart';

class TopupTranHistoryModel {
  String userId;

  String paymentMethod;

  final amount;

  bool isTopup;

  String orderId;

  String paymentStatus;

  Timestamp date;

  String id;

  TopupTranHistoryModel({
    required this.amount,
    required this.userId,
    required this.orderId,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.date,
    required this.id,
    required this.isTopup,
  });

  factory TopupTranHistoryModel.fromJson(Map<String, dynamic> parsedJson) {
    return TopupTranHistoryModel(
      amount: parsedJson['amount'] ?? 0.0,
      id: parsedJson['id'],
      isTopup: parsedJson['isTopUp'] == null ? false : parsedJson['isTopUp'],
      date: parsedJson['date'] ?? '',
      orderId: parsedJson['order_id'] ?? '',
      paymentMethod: parsedJson['payment_method'] ?? '',
      paymentStatus: parsedJson['payment_status'] ?? false,
      userId: parsedJson['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'amount': this.amount,
      'id': this.id,
      'date': this.date,
      'isTopUp': this.isTopup,
      'payment_status': this.paymentStatus,
      'order_id': this.orderId,
      'payment_method': this.paymentMethod,
      'user_id': this.userId,
    };
    return json;
  }
}
