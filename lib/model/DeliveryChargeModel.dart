import 'dart:core';

class DeliveryChargeModel {
  num amount, deliveryChargesPerKm, minimumDeliveryCharges, minimumDeliveryChargesWithinKm;
  bool vendorCanModify = false;

  DeliveryChargeModel({this.amount = 0, this.deliveryChargesPerKm = 0, this.minimumDeliveryCharges = 0, this.minimumDeliveryChargesWithinKm = 0, this.vendorCanModify = false});

  factory DeliveryChargeModel.fromJson(Map<String, dynamic> parsedJson) {
    return DeliveryChargeModel(
        amount: parsedJson['amount'] ?? 0,
        deliveryChargesPerKm: parsedJson['delivery_charges_per_km'] ?? 0,
        minimumDeliveryCharges: parsedJson['minimum_delivery_charges'] ?? 0,
        minimumDeliveryChargesWithinKm: parsedJson['minimum_delivery_charges_within_km'] ?? 0,
        vendorCanModify: parsedJson['vendor_can_modify'] ?? false);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'delivery_charges_per_km': this.deliveryChargesPerKm,
      'minimum_delivery_charges': this.minimumDeliveryCharges,
      'minimum_delivery_charges_within_km': this.minimumDeliveryChargesWithinKm
    };

    return json;
  }
}
