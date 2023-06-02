class PaytmSettingData {
  String paytmMID;
  String paytmMerchantKey;
  bool isEnabled;
  bool isSandboxEnabled;

  PaytmSettingData({
    this.paytmMID = '',
    this.paytmMerchantKey = '',
    required this.isSandboxEnabled,
    required this.isEnabled,
  });

  factory PaytmSettingData.fromJson(Map<String, dynamic> parsedJson) {
    return PaytmSettingData(
      paytmMerchantKey: parsedJson['PAYTM_MERCHANT_KEY'] ?? '',
      paytmMID: parsedJson['PaytmMID'] ?? '',
      isSandboxEnabled: parsedJson['isSandboxEnabled'],
      isEnabled: parsedJson['isEnabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PaytmMID': this.paytmMID,
      'PAYTM_MERCHANT_KEY': this.paytmMerchantKey,
      'isEnabled': this.isEnabled,
      'isSandboxEnabled': this.isSandboxEnabled,
    };
  }
}
