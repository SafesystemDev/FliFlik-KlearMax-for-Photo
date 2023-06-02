import 'package:cloud_firestore/cloud_firestore.dart';

class InboxModel {
  String? customerId;
  String? customerName;
  String? customerProfileImage;
  String? lastMessage;
  String? orderId;
  String? restaurantId;
  String? restaurantName;
  String? restaurantProfileImage;
  String? lastSenderId;
  String? chatType;
  Timestamp? createdAt;

  InboxModel({
    this.customerId,
    this.customerName,
    this.customerProfileImage,
    this.lastMessage,
    this.orderId,
    this.restaurantId,
    this.restaurantName,
    this.restaurantProfileImage,
    this.lastSenderId,
    this.chatType,
    this.createdAt,
  });

  factory InboxModel.fromJson(Map<String, dynamic> parsedJson) {
    return InboxModel(
      customerId: parsedJson['customerId'] ?? '',
      customerName: parsedJson['customerName'] ?? '',
      customerProfileImage: parsedJson['customerProfileImage'] ?? '',
      lastMessage: parsedJson['lastMessage'],
      orderId: parsedJson['orderId'],
      restaurantId: parsedJson['restaurantId'] ?? '',
      restaurantName: parsedJson['restaurantName'] ?? '',
      lastSenderId: parsedJson['lastSenderId'] ?? '',
      chatType: parsedJson['chatType'] ?? '',
      restaurantProfileImage: parsedJson['restaurantProfileImage'] ?? '',
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': this.customerId,
      'customerName': this.customerName,
      'customerProfileImage': this.customerProfileImage,
      'lastMessage': this.lastMessage,
      'orderId': this.orderId,
      'restaurantId': this.restaurantId,
      'restaurantName': this.restaurantName,
      'restaurantProfileImage': this.restaurantProfileImage,
      'lastSenderId': this.lastSenderId,
      'chatType': this.chatType,
      'createdAt': this.createdAt,
    };
  }
}
