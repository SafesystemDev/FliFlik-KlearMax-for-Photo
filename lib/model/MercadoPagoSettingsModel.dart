class MercadoPagoSettingData {
  String publicKey;
  String accessToken;
  bool isEnabled;
  bool isSandbox;

  MercadoPagoSettingData({
    this.publicKey = '',
    this.accessToken = '',
    required this.isSandbox,
    required this.isEnabled,
  });

  factory MercadoPagoSettingData.fromJson(Map<String, dynamic> parsedJson) {
    return MercadoPagoSettingData(
      publicKey: parsedJson['PublicKey'] ?? '',
      isSandbox: parsedJson['isSandboxEnabled'],
      isEnabled: parsedJson['isEnabled'],
      accessToken: parsedJson['AccessToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AccessToken': this.accessToken,
      'isEnabled': this.isEnabled,
      'isSandboxEnabled': this.isSandbox,
      'PublicKey': this.publicKey,
    };
  }
}
