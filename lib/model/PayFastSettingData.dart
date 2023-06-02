class PayFastSettingData {
  bool isEnable;
  bool isSandbox;
  String merchantId;
  String merchantKey;

  String returnUrl;
  String cancelUrl;
  String notifyUrl;

  PayFastSettingData({
    this.merchantId = '',
    this.cancelUrl = '',
    required this.isEnable,
    required this.isSandbox,
    this.merchantKey = '',
    this.notifyUrl = '',
    this.returnUrl = '',
  });

  factory PayFastSettingData.fromJson(Map<String, dynamic> parsedJson) {
    return PayFastSettingData(
      isSandbox: parsedJson['isSandbox'] ?? false,
      isEnable: parsedJson['isEnable'] ?? false,
      returnUrl: parsedJson['return_url'] ?? '',
      notifyUrl: parsedJson['notify_url'] ?? '',
      merchantKey: parsedJson['merchant_key'] ?? '',
      cancelUrl: parsedJson['cancel_url'] ?? '',
      merchantId: parsedJson['merchant_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant_id': this.merchantId,
      'merchant_key': this.merchantKey,
      'return_url': this.returnUrl,
      'cancel_url': this.cancelUrl,
      'notify_url': this.notifyUrl,
      'isEnable': this.isEnable,
      'isSandbox': this.isSandbox,
    };
  }
}
