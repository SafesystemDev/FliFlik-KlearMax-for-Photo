class FlutterWaveSettingData {
  String publicKey;
  String secretKey;
  String encryptionKey;
  bool isEnable;
  bool isSandbox;

  FlutterWaveSettingData({
    this.publicKey = '',
    this.encryptionKey = '',
    this.secretKey = '',
    required this.isSandbox,
    required this.isEnable,
  });

  factory FlutterWaveSettingData.fromJson(Map<String, dynamic> parsedJson) {
    return FlutterWaveSettingData(
      publicKey: parsedJson['publicKey'] ?? '',
      encryptionKey: parsedJson['encryptionKey'] ?? '',
      isSandbox: parsedJson['isSandbox'] ?? false,
      isEnable: parsedJson['isEnable'] ?? false,
      secretKey: parsedJson['secretKey'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'secretKey': this.secretKey,
      'encryptionKey': this.encryptionKey,
      'isEnable': this.isEnable,
      'isSandbox': this.isSandbox,
      'publicKey': this.publicKey,
    };
  }
}
