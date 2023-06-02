import 'package:foodie_customer/model/ItemAttributes.dart';
import 'package:foodie_customer/model/variant_info.dart';

class ProductModel {
  String categoryID;
  String brandID;
  String description;
  String id;
  String photo;
  List<dynamic> photos;
  String price;
  String name;
  String vendorID;
  String sectionId;
  int quantity;
  bool publish;
  int calories;
  int grams;
  int proteins;
  int fats;
  bool veg;
  bool nonveg;
  String? disPrice = "0";
  bool takeaway;
  List<dynamic> addOnsTitle = [];
  List<dynamic> addOnsPrice = [];
  String? addonName;
  String? addonPrice;
  ItemAttributes? itemAttributes;
  Map<String, dynamic>? reviewAttributes;
  Map<String, dynamic> specification = {};
  num reviewsCount;
  num reviewsSum;
  VariantInfo? variantInfo;

  //List<AddAddonsDemo> lstAddOnsCustom=[];

  ProductModel({
    this.categoryID = '',
    this.brandID = '',
    this.description = '',
    this.id = '',
    this.photo = '',
    this.photos = const [],
    this.price = '',
    this.name = '',
    this.quantity = 0,
    this.vendorID = '',
    this.sectionId = '',
    this.calories = 0,
    this.grams = 0,
    this.proteins = 0,
    this.fats = 0,
    this.publish = true,
    this.veg = false,
    this.nonveg = false,
    this.addonName,
    this.addonPrice,
    this.disPrice,
    this.takeaway = false,
    this.reviewsCount = 0,
    this.reviewsSum = 0,
    this.addOnsPrice = const [],
    this.addOnsTitle = const [],
    this.itemAttributes,
    this.variantInfo,
    this.specification = const {},
    this.reviewAttributes,
  });

  factory ProductModel.fromJson(Map<String, dynamic> parsedJson) {
    return ProductModel(
      categoryID: parsedJson['categoryID'] ?? '',
      brandID: parsedJson['brandID'] ?? '',
      description: parsedJson['description'] ?? '',
      id: parsedJson['id'] ?? '',
      photo: parsedJson['photo'],
      photos: parsedJson['photos'] ?? [],
      price: parsedJson['price'] ?? '',
      quantity: parsedJson['quantity'] ?? 0,
      name: parsedJson['name'] ?? '',
      vendorID: parsedJson['vendorID'] ?? '',
      sectionId: parsedJson['section_id'] ?? '',
      publish: parsedJson['publish'] ?? true,
      calories: parsedJson['calories'] ?? 0,
      grams: parsedJson['grams'] ?? 0,
      proteins: parsedJson['proteins'] ?? 0,
      fats: parsedJson['fats'] ?? 0,
      nonveg: parsedJson['nonveg'] ?? false,
      disPrice: parsedJson['disPrice'] ?? '0',
      specification: parsedJson['product_specification'] ?? {},
      takeaway: parsedJson['takeawayOption'] ?? false,
      addOnsPrice: parsedJson['addOnsPrice'] ?? [],
      addOnsTitle: parsedJson['addOnsTitle'] ?? [],
      reviewsCount: parsedJson['reviewsCount'] ?? 0,
      reviewsSum: parsedJson['reviewsSum'] ?? 0,
      variantInfo: (parsedJson.containsKey('variant_info') && parsedJson['variant_info'] != null)
          ? parsedJson['variant_info'].runtimeType.toString() == '_InternalLinkedHashMap<String, dynamic>'
              ? VariantInfo.fromJson(parsedJson['variant_info'])
              : null
          : null,
      reviewAttributes: parsedJson['reviewAttributes'] ?? {},
      addonName: parsedJson["addon_name"] ?? "",
      addonPrice: parsedJson["addon_price"] ?? "",
      //lstSizeCustom: lstSizeCustom,//parse dJson['lstSizeCustom'] != null?parsedJson['lstSizeCustom']:<AddSizeDemo>[] ,
      //lstAddOnsCustom: lstAddOnsCustom,//parsedJson['lstAddOnsCustom']!=null?parsedJson['lstAddOnsCustom']:<AddAddonsDemo>[],
      veg: parsedJson['veg'] ?? false,
      itemAttributes: (parsedJson.containsKey('item_attribute') && parsedJson['item_attribute'] != null) ? ItemAttributes.fromJson(parsedJson['item_attribute']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    photos.toList().removeWhere((element) => element == null);
    return {
      'categoryID': categoryID,
      'brandID': brandID,
      'description': description,
      'id': id,
      'photo': photo,
      'photos': photos,
      'price': price,
      'name': name,
      'quantity': quantity,
      'vendorID': vendorID,
      'section_id': sectionId,
      'publish': publish,
      'calories': calories,
      'grams': grams,
      'proteins': proteins,
      'fats': fats,
      'veg': veg,
      'nonveg': nonveg,
      'takeawayOption': takeaway,
      'disPrice': disPrice,
      "addOnsTitle": addOnsTitle,
      "addOnsPrice": addOnsPrice,
      "addon_name": addonName,
      "addon_price": addonPrice,
      'item_attribute': itemAttributes == null ? null : itemAttributes!.toJson(),
      'product_specification': specification,
      'reviewAttributes': reviewAttributes,
      'reviewsCount': reviewsCount,
      'reviewsSum': reviewsSum,
    };
  }
}

class ReviewsAttribute {
  num? reviewsCount;
  num? reviewsSum;

  ReviewsAttribute({
    this.reviewsCount,
    this.reviewsSum,
  });

  ReviewsAttribute.fromJson(Map<String, dynamic> json) {
    reviewsCount = json['reviewsCount'] ?? 0;
    reviewsSum = json['reviewsSum'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reviewsCount'] = reviewsCount;
    data['reviewsSum'] = reviewsSum;
    return data;
  }
}
