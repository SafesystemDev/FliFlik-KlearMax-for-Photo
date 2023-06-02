import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie_customer/model/User.dart';
import 'package:foodie_customer/model/VendorModel.dart';

class BookTableModel {
  String authorID;

  User author;

  Timestamp createdAt, date;

  String vendorID;

  VendorModel vendor;

  String status;
  String id, guestEmail, guestFirstName, guestLastName, guestPhone;
  String? occasion, specialRequest;
  bool firstVisit;
  int totalGuest;
  String? discount;
  String? discountType;

  BookTableModel(
      {author,
      this.authorID = '',
      createdAt,
      date,
      this.vendorID = '',
      vendor,
      this.id = '',
      this.status = '',
      this.guestEmail = '',
      this.guestFirstName = '',
      this.guestLastName = '',
      this.guestPhone = '',
      this.occasion,
      this.specialRequest,
      this.discount,
      this.firstVisit = false,
      this.totalGuest = 0,
      this.discountType = ""})
      : this.author = author ?? User(),
        this.createdAt = createdAt ?? Timestamp.now(),
        this.date = date ?? Timestamp.now(),
        this.vendor = vendor ?? VendorModel();

  factory BookTableModel.fromJson(Map<String, dynamic> parsedJson) {
    int guestVal = 0;
    if (parsedJson['totalGuest'] == null || parsedJson['totalGuest'] == double.nan || parsedJson['totalGuest'] == double.infinity) {
      guestVal = 0;
    } else {
      if (parsedJson['totalGuest'] is String) {
        guestVal = int.parse(parsedJson['totalGuest']);
      } else {
        guestVal = (parsedJson['totalGuest'] is double) ? (parsedJson["totalGuest"].isNaN ? 0 : (parsedJson['totalGuest'] as double).toInt()) : parsedJson['totalGuest'];
      }
    }
    return BookTableModel(
        author: parsedJson.containsKey('author') ? User.fromJson(parsedJson['author']) : User(),
        authorID: parsedJson['authorID'] ?? '',
        createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
        date: parsedJson['date'] ?? Timestamp.now(),
        id: parsedJson['id'] ?? '',
        vendor: parsedJson.containsKey('vendor') ? VendorModel.fromJson(parsedJson['vendor']) : VendorModel(),
        vendorID: parsedJson['vendorID'] ?? '',
        status: parsedJson['status'] ?? '',
        guestEmail: parsedJson['guestEmail'] ?? '',
        guestFirstName: parsedJson['guestFirstName'] ?? '',
        guestLastName: parsedJson['guestLastName'] ?? '',
        guestPhone: parsedJson['guestPhone'] ?? '',
        discount: parsedJson['discount'] ?? '',
        discountType: parsedJson['discountType'] ?? '',
        occasion: (parsedJson["occasion"] != null && parsedJson["occasion"].toString().isNotEmpty) ? parsedJson["occasion"] : "",
        specialRequest: (parsedJson["specialRequest"] != null && parsedJson["specialRequest"].toString().isNotEmpty) ? parsedJson["specialRequest"] : "",
        firstVisit: parsedJson["firstVisit"] != null ? parsedJson["firstVisit"] : false,
        totalGuest: guestVal);
  }

  Map<String, dynamic> toJson() {
    return {
      'author': this.author.toJson(),
      'authorID': this.authorID,
      'createdAt': this.createdAt,
      'date': this.date,
      'id': this.id,
      'status': this.status,
      'vendor': this.vendor.toJson(),
      'vendorID': this.vendorID,
      'guestEmail': guestEmail,
      'guestFirstName': guestFirstName,
      'guestLastName': guestLastName,
      'guestPhone': guestPhone,
      'occasion': occasion,
      'specialRequest': specialRequest,
      'firstVisit': firstVisit,
      'totalGuest': totalGuest,
      'discount': discount,
      'discountType': discountType
    };
  }
}
