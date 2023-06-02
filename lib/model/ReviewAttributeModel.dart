class ReviewAttributeModel {
  String? id;
  String? title;

  ReviewAttributeModel({
    this.id,
    this.title,
  });

  ReviewAttributeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    title = json['title'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    return data;
  }
}
