class LanguageModel {
  List<Data>? data;

  LanguageModel({this.data});

  LanguageModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? language;
  String? icon;
  String? languageCode;

  Data({this.language, this.icon, this.languageCode});

  Data.fromJson(Map<String, dynamic> json) {
    language = json['language'];
    icon = json['icon'];
    languageCode = json['languageCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['language'] = language;
    data['icon'] = icon;
    data['languageCode'] = languageCode;
    return data;
  }
}
