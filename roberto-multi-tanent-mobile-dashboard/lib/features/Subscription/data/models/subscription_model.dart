class SystemOwnerSubscriptionModel {
  final List<PlanModel> plans;
  final double mrr;
  final double arr;
  final int activeSubs;
  final List<BillingHistoryModel> billingHistory;

  SystemOwnerSubscriptionModel({
    required this.plans,
    required this.mrr,
    required this.arr,
    required this.activeSubs,
    required this.billingHistory,
  });

  factory SystemOwnerSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SystemOwnerSubscriptionModel(
      plans: (json['plans'] as List?)
              ?.map((e) => PlanModel.fromJson(e))
              .toList() ??
          [],
      mrr: (json['mrr'] ?? 0).toDouble(),
      arr: (json['arr'] ?? 0).toDouble(),
      activeSubs: json['activeSubs'] ?? 0,
      billingHistory: (json['billingHistory'] as List?)
              ?.map((e) => BillingHistoryModel.fromJson(e))
              .toList() ??
          [],
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
  final int sortOrder;
  final List<FeatureModel> features;

  PlanModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.currency,
    required this.isActive,
    required this.sortOrder,
    required this.features,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      monthlyPrice: (json['monthlyPrice'] ?? 0).toDouble(),
      yearlyPrice: (json['yearlyPrice'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      isActive: json['isActive'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
      features: (json['features'] as List?)
              ?.map((e) => FeatureModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class FeatureModel {
  final String id;
  final String key;
  final String value;

  FeatureModel({
    required this.id,
    required this.key,
    required this.value,
  });

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

class BillingHistoryModel {
  final String id;
  final DateTime? date;
  final String description;
  final String client;
  final double amount;
  final String status;
  final String invoiceUrl;

  BillingHistoryModel({
    required this.id,
    this.date,
    required this.description,
    required this.client,
    required this.amount,
    required this.status,
    required this.invoiceUrl,
  });

  factory BillingHistoryModel.fromJson(Map<String, dynamic> json) {
    return BillingHistoryModel(
      id: json['id'] ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      description: json['description'] ?? '',
      client: json['client'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      invoiceUrl: json['invoiceUrl'] ?? '',
    );
  }
}
