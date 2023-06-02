import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie_customer/model/User.dart';

class NotificationModel {
  Timestamp createdAt;

  String body;

  String id;

  String type;

  bool seen;

  String title;
  String toUserID;

  User toUser;

  Map<String, dynamic> metadata;

  NotificationModel({createdAt, this.body = '', this.id = '', this.type = '', this.seen = false, this.title = '', this.toUserID = '', toUser, this.metadata = const {}})
      : this.createdAt = createdAt ?? Timestamp.now(),
        this.toUser = toUser ?? User();

  factory NotificationModel.fromJson(Map<String, dynamic> parsedJson) {
    return NotificationModel(
        createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
        body: parsedJson['body'] ?? '',
        id: parsedJson['id'] ?? '',
        seen: parsedJson['seen'] ?? false,
        title: parsedJson['title'] ?? '',
        toUserID: parsedJson['toUserID'] ?? '',
        metadata: parsedJson['metadata'] ?? Map(),
        type: parsedJson['type'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'createdAt': this.createdAt, 'body': this.body, 'id': this.id, 'seen': this.seen, 'title': this.title, 'toUserID': this.toUserID, 'metadata': this.metadata, 'type': this.type};
  }
}
