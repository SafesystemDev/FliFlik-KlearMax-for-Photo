class FavouriteModel {
  String? restaurantId;
  String? userId;

  FavouriteModel({this.restaurantId, this.userId});

  factory FavouriteModel.fromJson(Map<String, dynamic> parsedJson) {
    return new FavouriteModel(restaurantId: parsedJson["restaurant_id"] ?? "", userId: parsedJson["user_id"] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {"restaurant_id": this.restaurantId, "user_id": this.userId};
  }
}
