import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  String? offerId;
  String? offerCode;
  String? descriptionOffer;
  String? discountOffer;
  String? discountTypeOffer;
  Timestamp? expireOfferDate;
  bool? isEnableOffer;
  String? imageOffer = "";
  String? restaurantId;

  OfferModel({this.descriptionOffer, this.discountOffer, this.discountTypeOffer, this.expireOfferDate, this.imageOffer = "", this.isEnableOffer, this.offerCode, this.offerId, this.restaurantId});

  factory OfferModel.fromJson(Map<String, dynamic> parsedJson) {
    return OfferModel(
        descriptionOffer: parsedJson["description"],
        discountOffer: parsedJson["discount"],
        discountTypeOffer: parsedJson["discountType"],
        expireOfferDate: parsedJson["expiresAt"],
        imageOffer: parsedJson["image"] == null ? ((parsedJson["photo"] == null ? "" : parsedJson["photo"])) : parsedJson["image"],
        isEnableOffer: parsedJson["isEnabled"],
        offerCode: parsedJson["code"],
        offerId: parsedJson["id"],
        restaurantId: parsedJson["resturant_id"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "description": this.descriptionOffer,
      "discount": this.discountOffer,
      "discountType": this.discountTypeOffer,
      "expiresAt": this.expireOfferDate,
      "image": this.imageOffer,
      "isEnabled": this.isEnableOffer,
      "code": this.offerCode,
      "id": this.offerId,
      "resturant_id": this.restaurantId
    };
  }
}
