import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  String? id;

  double? rating;

  List<dynamic>? photos;

  String? comment;

  String? orderId;

  String? customerId;

  String? vendorId;
  String? productId;
  String? driverId;
  String? uname;
  String? profile;
  Map<String, dynamic>? reviewAttributes;
  Timestamp? createdAt;

  RatingModel(
      {this.id = '',
      this.comment = '',
      this.photos = const [],
      this.rating = 0.0,
      this.orderId = '',
      this.vendorId = '',
      this.productId = '',
      this.driverId = '',
      this.customerId = '',
      this.uname = '',
      this.createdAt,
      this.reviewAttributes,
      this.profile = ''});

  factory RatingModel.fromJson(Map<String, dynamic> parsedJson) {
    return RatingModel(
        comment: parsedJson['comment'] ?? '',
        photos: parsedJson['photos'] ?? '',
        rating: parsedJson['rating'].toDouble() ?? 0.0,
        id: parsedJson['Id'] ?? '',
        orderId: parsedJson['orderid'] ?? '',
        vendorId: parsedJson['VendorId'] ?? '',
        productId: parsedJson['productId'] ?? '',
        driverId: parsedJson['driverId'] ?? '',
        customerId: parsedJson['CustomerId'] ?? '',
        uname: parsedJson['uname'] ?? '',
        reviewAttributes: parsedJson['reviewAttributes'] ?? {},
        createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
        profile: parsedJson['profile'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'comment': comment,
      'photos': photos,
      'rating': rating,
      'Id': id,
      'orderid': orderId,
      'VendorId': vendorId,
      'productId': productId,
      'driverId': driverId,
      'CustomerId': customerId,
      'uname': uname,
      'profile': profile,
      'reviewAttributes': reviewAttributes ?? {},
      'createdAt': createdAt
    };
  }
}
