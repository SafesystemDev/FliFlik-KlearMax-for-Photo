import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  String? id;
  String? senderId;
  String? receiverId;
  String? orderId;
  String? message;
  String? messageType;
  String? videoThumbnail;
  Url? url;
  Timestamp? createdAt;

  ConversationModel({
    this.id,
    this.senderId,
    this.receiverId,
    this.orderId,
    this.message,
    this.messageType,
    this.videoThumbnail,
    this.url,
    this.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> parsedJson) {
    return ConversationModel(
      id: parsedJson['id'] ?? '',
      senderId: parsedJson['senderId'] ?? '',
      receiverId: parsedJson['receiverId'] ?? '',
      orderId: parsedJson['orderId'] ?? '',
      message: parsedJson['message'] ?? '',
      messageType: parsedJson['messageType'] ?? '',
      videoThumbnail: parsedJson['videoThumbnail'] ?? '',
      url: parsedJson.containsKey('url')
          ? parsedJson['url'] != null
              ? Url.fromJson(parsedJson['url'])
              : null
          : Url(),
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'senderId': this.senderId,
      'receiverId': this.receiverId,
      'orderId': this.orderId,
      'message': this.message,
      'messageType': this.messageType,
      'videoThumbnail': this.videoThumbnail,
      'url': url == null ? null : this.url!.toJson(),
      'createdAt': this.createdAt,
    };
  }
}

class Url {
  String mime;

  String url;

  String? videoThumbnail;

  Url({this.mime = '', this.url = '', this.videoThumbnail});

  factory Url.fromJson(Map<dynamic, dynamic> parsedJson) {
    return Url(mime: parsedJson['mime'] ?? '', url: parsedJson['url'] ?? '', videoThumbnail: parsedJson['videoThumbnail'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'mime': this.mime, 'url': this.url, 'videoThumbnail': videoThumbnail};
  }
}
