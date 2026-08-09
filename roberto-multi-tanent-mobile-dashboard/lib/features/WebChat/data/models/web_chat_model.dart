class WebChatWebhook {
  final String id;
  final String businessId;
  final String branchId;
  final String token;
  final String url;
  final bool isActive;
  final String businessName;
  final String branchName;
  final String branchPhone;
  final String branchAddress;

  WebChatWebhook({
    required this.id,
    required this.businessId,
    required this.branchId,
    required this.token,
    required this.url,
    required this.isActive,
    required this.businessName,
    required this.branchName,
    required this.branchPhone,
    required this.branchAddress,
  });

  factory WebChatWebhook.fromJson(Map<String, dynamic> json) {
    return WebChatWebhook(
      id: json['id'] ?? '',
      businessId: json['businessId'] ?? '',
      branchId: json['branchId'] ?? '',
      token: json['token'] ?? '',
      url: json['url'] ?? '',
      isActive: json['isActive'] ?? false,
      businessName: json['business']?['name'] ?? 'N/A',
      branchName: json['branch']?['name'] ?? 'N/A',
      branchPhone: json['branch']?['phone'] ?? 'N/A',
      branchAddress: json['branch']?['address'] ?? 'N/A',
    );
  }
}
