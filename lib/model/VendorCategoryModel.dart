class VendorCategoryModel {
  List<dynamic>? reviewAttributes;
  String? photo;
  String? description;
  String? id;
  String? title;
  num? order;

  VendorCategoryModel({this.reviewAttributes, this.photo, this.description, this.id, this.title, this.order});

  VendorCategoryModel.fromJson(Map<String, dynamic> json) {
    reviewAttributes = json['review_attributes'] ?? [];
    photo = json['photo'] ?? "";
    description = json['description'] ?? '';
    id = json['id'] ?? "";
    title = json['title'] ?? "";
    order = json['order'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['review_attributes'] = reviewAttributes;
    data['photo'] = photo;
    data['description'] = description;
    data['id'] = id;
    data['title'] = title;
    data['order'] = order;
    return data;
  }
}
