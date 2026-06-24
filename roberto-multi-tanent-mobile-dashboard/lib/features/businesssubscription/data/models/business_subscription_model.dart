class InvoiceModel {
  final String id;
  final String businessId;
  final String subscriptionId;
  final String invoiceNo;
  final double amount;
  final String status;
  final String billingCycle;
  final String stripeInvoiceId;
  final String invoicePath;
  final String invoiceUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InvoiceModel({
    required this.id,
    required this.businessId,
    required this.subscriptionId,
    required this.invoiceNo,
    required this.amount,
    required this.status,
    required this.billingCycle,
    required this.stripeInvoiceId,
    required this.invoicePath,
    required this.invoiceUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? '',
      businessId: json['businessId'] ?? '',
      subscriptionId: json['subscriptionId'] ?? '',
      invoiceNo: json['invoiceNo'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      billingCycle: json['billingCycle'] ?? '',
      stripeInvoiceId: json['stripeInvoiceId'] ?? '',
      invoicePath: json['invoicePath'] ?? '',
      invoiceUrl: json['invoiceUrl'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }
}

class PlanFeatureModel {
  final String id;
  final String planId;
  final String key;
  final String value;

  PlanFeatureModel({
    required this.id,
    required this.planId,
    required this.key,
    required this.value,
  });

  factory PlanFeatureModel.fromJson(Map<String, dynamic> json) {
    return PlanFeatureModel(
      id: json['id'] ?? '',
      planId: json['planId'] ?? '',
      key: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

class PlanModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final String currency;
  final bool isActive;
  final List<PlanFeatureModel> features;

  PlanModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.currency,
    required this.isActive,
    required this.features,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    var featureList = json['features'] as List? ?? [];
    List<PlanFeatureModel> parsedFeatures = featureList.map((f) => PlanFeatureModel.fromJson(f)).toList();

    return PlanModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      monthlyPrice: (json['monthlyPrice'] ?? 0).toDouble(),
      yearlyPrice: (json['yearlyPrice'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      isActive: json['isActive'] ?? false,
      features: parsedFeatures,
    );
  }
}

class BusinessSubscriptionModel {
  final String id;
  final String businessId;
  final String planId;
  final String status;
  final String billingCycle;
  final String stripeCustomerId;
  final String stripeSubscriptionId;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PlanModel? plan;
  final List<InvoiceModel> invoices;
  final String invoicePath;
  final String invoiceUrl;

  BusinessSubscriptionModel({
    required this.id,
    required this.businessId,
    required this.planId,
    required this.status,
    required this.billingCycle,
    required this.stripeCustomerId,
    required this.stripeSubscriptionId,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.plan,
    required this.invoices,
    required this.invoicePath,
    required this.invoiceUrl,
  });

  bool get isExpired {
    if (status.toUpperCase() != 'ACTIVE') return true;
    if (endDate == null) return false;
    return endDate!.isBefore(DateTime.now());
  }

  factory BusinessSubscriptionModel.fromJson(Map<String, dynamic> json) {
    var invoiceList = json['invoices'] as List? ?? [];
    List<InvoiceModel> invoices = invoiceList.map((i) => InvoiceModel.fromJson(i)).toList();

    return BusinessSubscriptionModel(
      id: json['id'] ?? '',
      businessId: json['businessId'] ?? '',
      planId: json['planId'] ?? '',
      status: json['status'] ?? '',
      billingCycle: json['billingCycle'] ?? '',
      stripeCustomerId: json['stripeCustomerId'] ?? '',
      stripeSubscriptionId: json['stripeSubscriptionId'] ?? '',
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      plan: json['plan'] != null ? PlanModel.fromJson(json['plan']) : null,
      invoices: invoices,
      invoicePath: json['invoicePath'] ?? '',
      invoiceUrl: json['invoiceUrl'] ?? '',
    );
  }
}
