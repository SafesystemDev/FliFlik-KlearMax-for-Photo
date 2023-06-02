class PayStackSettingData {
  String publicKey;
  String secretKey;
  String callbackURL;
  String webhookURL;
  bool isEnabled;
  bool isSandbox;

  PayStackSettingData({
    this.publicKey = '',
    this.callbackURL = '',
    this.webhookURL = '',
    this.secretKey = '',
    required this.isSandbox,
    required this.isEnabled,
  });

  factory PayStackSettingData.fromJson(Map<String, dynamic> parsedJson) {
    return PayStackSettingData(
      publicKey: parsedJson['publicKey'] ?? '',
      webhookURL: parsedJson['webhookURL'] ?? '',
      callbackURL: parsedJson['callbackURL'] ?? '',
      isSandbox: parsedJson['isSandbox'],
      isEnabled: parsedJson['isEnable'],
      secretKey: parsedJson['secretKey'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'secretKey': this.secretKey,
      'callbackURL': this.callbackURL,
      'webhookURL': this.webhookURL,
      'isEnable': this.isEnabled,
      'isSandbox': this.isSandbox,
      'publicKey': this.publicKey,
    };
  }
}
