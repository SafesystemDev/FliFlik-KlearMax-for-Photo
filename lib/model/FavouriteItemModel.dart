class FavouriteItemModel {
  String? storeId;
  String? userId;
  String? productId;

  FavouriteItemModel({this.storeId, this.userId, this.productId});

  factory FavouriteItemModel.fromJson(Map<String, dynamic> parsedJson) {
    return FavouriteItemModel(storeId: parsedJson["store_id"] ?? "", userId: parsedJson["user_id"] ?? "", productId: parsedJson["product_id"] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {"store_id": storeId, "user_id": userId, "product_id": productId};
  }
}
