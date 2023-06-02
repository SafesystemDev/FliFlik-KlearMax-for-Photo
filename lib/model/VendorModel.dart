import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie_customer/model/DeliveryChargeModel.dart';
import 'package:foodie_customer/model/SpecialDiscountModel.dart';

import '../constants.dart';
import 'WorkingHoursModel.dart';

class VendorModel {
  String author;

  String authorName;

  String authorProfilePic;

  String categoryID;

  String fcmToken;

  String categoryPhoto;

  String categoryTitle;

  dynamic createdAt;

  String description;

  String phonenumber;

  Map<String, dynamic> filters;

  String id;

  double latitude;

  double longitude;

  String photo;

  List<dynamic> photos;
  List<dynamic> restaurantMenuPhotos;

  String location;

  String price;

  num reviewsCount, restaurantCost;

  num reviewsSum;
  GeoFireData geoFireData;

  String title;

  String opentime, openDineTime;

  String closetime, closeDineTime;

  bool hidephotos;

  bool reststatus;
  DeliveryChargeModel? deliveryCharge;
  List<SpecialDiscountModel> specialDiscount;
  bool specialDiscountEnable;
  List<WorkingHoursModel> workingHours;

  // ,this.filters = filters ?? Filters(cuisine: '');

  VendorModel(
      {this.author = '',
      this.hidephotos = false,
      this.authorName = '',
      this.authorProfilePic = '',
      this.categoryID = '',
      this.categoryPhoto = '',
      this.categoryTitle = '',
      this.createdAt,
      this.filters = const {},
      this.description = '',
      this.phonenumber = '',
      this.fcmToken = '',
      this.id = '',
      this.latitude = 0.1,
      this.longitude = 0.1,
      this.photo = '',
      this.photos = const [],
      this.restaurantMenuPhotos = const [],
      this.specialDiscount = const [],
      this.workingHours = const [],
      this.specialDiscountEnable = false,
      this.location = '',
      this.price = '',
      this.reviewsCount = 0,
      this.reviewsSum = 0,
      this.restaurantCost = 0,
      this.closetime = '',
      this.opentime = '',
      this.closeDineTime = '',
      this.openDineTime = '',
      this.title = '',
      this.reststatus = false,
      geoFireData,
      deliveryCharge})
      : this.deliveryCharge = deliveryCharge ?? null,
        this.geoFireData = geoFireData ??
            GeoFireData(
              geohash: "",
              geoPoint: GeoPoint(0.0, 0.0),
            );

  factory VendorModel.fromJson(Map<String, dynamic> parsedJson) {
    num restCost = 0;
    if (parsedJson.containsKey("restaurantCost")) {
      if (parsedJson['restaurantCost'] == null || parsedJson['restaurantCost'].toString().isEmpty) {
        restCost = 0;
      } else if (parsedJson['restaurantCost'] is String) {
        restCost = num.parse(parsedJson['restaurantCost']);
      } else if (parsedJson['restaurantCost'] is num) {
        restCost = parsedJson['restaurantCost'];
      }
    }
    List<SpecialDiscountModel> specialDiscount = parsedJson.containsKey('specialDiscount')
        ? List<SpecialDiscountModel>.from((parsedJson['specialDiscount'] as List<dynamic>).map((e) => SpecialDiscountModel.fromJson(e))).toList()
        : [].cast<SpecialDiscountModel>();

    List<WorkingHoursModel> workingHours = parsedJson.containsKey('workingHours')
        ? List<WorkingHoursModel>.from((parsedJson['workingHours'] as List<dynamic>).map((e) => WorkingHoursModel.fromJson(e))).toList()
        : [].cast<WorkingHoursModel>();
    return new VendorModel(
        author: parsedJson['author'] ?? '',
        hidephotos: parsedJson['hidephotos'] ?? false,
        authorName: parsedJson['authorName'] ?? '',
        authorProfilePic: parsedJson['authorProfilePic'] ?? '',
        categoryID: parsedJson['categoryID'] ?? '',
        categoryPhoto: parsedJson['categoryPhoto'] ?? '',
        categoryTitle: parsedJson['categoryTitle'] ?? '',
        createdAt: parsedJson['createdAt'] != null
            ? parsedJson['createdAt'] is Map<dynamic, dynamic>
                ? CreatedAt.fromJson(parsedJson['createdAt'])
                : parsedJson['createdAt']
            : parsedJson['createdAt'] is Map<dynamic, dynamic>
                ? CreatedAt()
                : Timestamp.now(),
        deliveryCharge: (parsedJson.containsKey('DeliveryCharge') && parsedJson['DeliveryCharge'] != null) ? DeliveryChargeModel.fromJson(parsedJson['DeliveryCharge']) : null,
        description: parsedJson['description'] ?? '',
        phonenumber: parsedJson['phonenumber'] ?? '',
        filters: parsedJson['filters'] ?? {},
        // : Filters(cuisine: ''),
        id: parsedJson['id'] ?? '',
        geoFireData: parsedJson.containsKey('g')
            ? GeoFireData.fromJson(parsedJson['g'])
            : GeoFireData(
                geohash: "",
                geoPoint: GeoPoint(0.0, 0.0),
              ),
        latitude: getDoubleVal(parsedJson['latitude']),
        longitude: getDoubleVal(parsedJson['longitude']),
        photo: parsedJson['photo'] ?? placeholderImage,
        photos: parsedJson['photos'] ?? [],
        restaurantMenuPhotos: parsedJson['restaurantMenuPhotos'] ?? [],
        location: parsedJson['location'] ?? '',
        fcmToken: parsedJson['fcmToken'] ?? '',
        price: parsedJson['price'] ?? '',
        reviewsCount: parsedJson['reviewsCount'] ?? 0,
        restaurantCost: restCost,
        reviewsSum: parsedJson['reviewsSum'] ?? 0,
        title: parsedJson['title'] ?? '',
        closetime: parsedJson['closetime'] ?? '',
        opentime: parsedJson['opentime'] ?? '',
        closeDineTime: parsedJson['closeDineTime'] ?? '',
        openDineTime: parsedJson['openDineTime'] ?? '',
        specialDiscountEnable: parsedJson['specialDiscountEnable'] ?? false,
        specialDiscount: specialDiscount,
        workingHours: workingHours,
        reststatus: parsedJson['reststatus'] ?? false);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'author': this.author,
      'hidephotos': this.hidephotos,
      'authorName': this.authorName,
      'authorProfilePic': this.authorProfilePic,
      'categoryID': this.categoryID,
      'categoryPhoto': this.categoryPhoto,
      'categoryTitle': this.categoryTitle,
      'createdAt': this.createdAt.toJson(),
      'description': this.description,
      'phonenumber': this.phonenumber,
      'filters': this.filters,
      'restaurantCost': this.restaurantCost,
      'id': this.id,
      "g": this.geoFireData.toJson(),
      'latitude': this.latitude,
      'longitude': this.longitude,
      'photo': this.photo,
      'photos': this.photos,
      'restaurantMenuPhotos': this.restaurantMenuPhotos,
      'location': this.location,
      'fcmToken': this.fcmToken,
      'price': this.price,
      'reviewsCount': this.reviewsCount,
      'reviewsSum': this.reviewsSum,
      'title': this.title,
      'opentime': this.opentime,
      'closetime': this.closetime,
      'openDineTime': this.openDineTime,
      'closeDineTime': this.closeDineTime,
      'reststatus': this.reststatus,
      'specialDiscount': this.specialDiscount.map((e) => e.toJson()).toList(),
      'specialDiscountEnable': this.specialDiscountEnable,
      'workingHours': this.workingHours.map((e) => e.toJson()).toList(),
    };
    if (deliveryCharge != null) {
      json.addAll({'DeliveryCharge': this.deliveryCharge!.toJson()});
    }
    return json;
  }
}

class GeoFireData {
  String? geohash;
  GeoPoint? geoPoint;

  GeoFireData({this.geohash, this.geoPoint});

  factory GeoFireData.fromJson(Map<dynamic, dynamic> parsedJson) {
    return GeoFireData(
      geohash: parsedJson['geohash'] ?? '',
      geoPoint: parsedJson['geopoint'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geohash': this.geohash,
      'geopoint': this.geoPoint,
    };
  }
}

class CreatedAt {
  num nanoseconds;

  num seconds;

  CreatedAt({this.nanoseconds = 0.0, this.seconds = 0.0});

  factory CreatedAt.fromJson(Map<dynamic, dynamic> parsedJson) {
    return CreatedAt(
      nanoseconds: parsedJson['_nanoseconds'] ?? '',
      seconds: parsedJson['_seconds'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_nanoseconds': this.nanoseconds,
      '_seconds': this.seconds,
    };
  }
}

class Filters {
  String cuisine;

  String wifi;

  String breakfast;

  String dinner;

  String lunch;

  String seating;

  String vegan;

  String reservation;

  String music;

  String price;

  Filters({required this.cuisine, this.seating = '', this.price = '', this.breakfast = '', this.dinner = '', this.lunch = '', this.music = '', this.reservation = '', this.vegan = '', this.wifi = ''});

  factory Filters.fromJson(Map<dynamic, dynamic> parsedJson) {
    return new Filters(
        cuisine: parsedJson["Cuisine"] ?? '',
        wifi: parsedJson["Free Wi-Fi"] ?? 'No',
        breakfast: parsedJson["Good for Breakfast"] ?? 'No',
        dinner: parsedJson["Good for Dinner"] ?? 'No',
        lunch: parsedJson["Good for Lunch"] ?? 'No',
        music: parsedJson["Live Music"] ?? 'No',
        price: parsedJson["Price"] ?? '$symbol',
        reservation: parsedJson["Takes Reservations"] ?? 'No',
        vegan: parsedJson["Vegetarian Friendly"] ?? 'No',
        seating: parsedJson["Outdoor Seating"] ?? 'No');
  }

  Map<String, dynamic> toJson() {
    return {
      'Cuisine': this.cuisine,
      'Free Wi-Fi': this.wifi,
      'Good for Breakfast': this.breakfast,
      'Good for Dinner': this.dinner,
      'Good for Lunch': this.lunch,
      'Live Music': this.music,
      'Price': this.price,
      'Takes Reservations': this.reservation,
      'Vegetarian Friendly': this.vegan,
      'Outdoor Seating': this.seating
    };
  }
}
