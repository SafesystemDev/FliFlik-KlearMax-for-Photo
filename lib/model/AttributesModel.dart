class AttributesModel {
  String? id;
  String? title;

  AttributesModel({this.id, this.title});

  AttributesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['title'] = this.title;
    return data;
  }
}
