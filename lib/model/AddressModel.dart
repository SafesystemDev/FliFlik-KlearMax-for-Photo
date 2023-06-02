import 'package:foodie_customer/model/User.dart';

class AddressModel {
  String city;

  String country;

  String email;

  String line1;

  String line2;

  UserLocation location;

  String name;

  String postalCode;

  AddressModel({this.city = '', this.country = '', this.email = '', this.line1 = '', this.line2 = '', location, this.name = '', this.postalCode = ''}) : this.location = location ?? UserLocation();

  factory AddressModel.fromJson(Map<String, dynamic> parsedJson) {
    return AddressModel(
      city: parsedJson['city'] ?? '',
      country: parsedJson['country'] ?? '',
      email: parsedJson['email'] ?? '',
      line1: parsedJson['line1'] ?? '',
      line2: parsedJson['line2'] ?? '',
      location: parsedJson.containsKey('location') ? UserLocation.fromJson(parsedJson['location']) : UserLocation(),
      name: parsedJson['name'] ?? '',
      postalCode: parsedJson['postalCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': this.city,
      'country': this.country,
      'email': this.email,
      'line1': this.line1,
      'line2': this.line2,
      'location': this.location.toJson(),
      'name': this.name,
      'postalCode': this.postalCode,
    };
  }
}
