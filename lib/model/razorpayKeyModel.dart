class RazorPayModel {
  String razorpayKey;
  String razorpaySecret;
  bool isEnabled;
  bool isSandboxEnabled;

  RazorPayModel({
    this.razorpayKey = '',
    this.razorpaySecret = '',
    required this.isEnabled,
    required this.isSandboxEnabled,
  });

  factory RazorPayModel.fromJson(Map<String, dynamic> parsedJson) {
    return RazorPayModel(
      razorpayKey: parsedJson['razorpayKey'] ?? '',
      razorpaySecret: parsedJson['razorpaySecret'] ?? '',
      isSandboxEnabled: parsedJson['isSandboxEnabled'],
      isEnabled: parsedJson['isEnabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'razorpayKey': this.razorpayKey,
      'razorpaySecret': this.razorpaySecret,
      'isEnabled': this.isEnabled,
      'isSandboxEnabled': this.isSandboxEnabled,
    };
  }
}
