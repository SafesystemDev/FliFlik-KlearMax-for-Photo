class TaxModel {
  String? label;
  bool? active;
  int? tax;
  String? type;

  TaxModel({this.label, this.active, this.tax, this.type});

  TaxModel.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    active = json['active'];
    tax = (json['tax'] is String) ? int.parse(json['tax']) : json['tax'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['active'] = this.active;
    data['tax'] = this.tax;
    data['type'] = this.type;
    return data;
  }
}
