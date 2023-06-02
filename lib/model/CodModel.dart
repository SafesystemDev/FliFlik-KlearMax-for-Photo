class CodModel {
  bool cod;

  CodModel({
    this.cod = false,
  });

  factory CodModel.fromJson(Map<String, dynamic> parsedJson) {
    return CodModel(
      cod: parsedJson['isEnabled'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': this.cod,
    };
  }
}
