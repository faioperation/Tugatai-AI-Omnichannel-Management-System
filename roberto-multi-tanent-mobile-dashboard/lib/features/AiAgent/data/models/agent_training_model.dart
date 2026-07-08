class AgentTraining {
  final String id;
  final String systemPrompt;
  final String? businessInformation;
  final dynamic productInformation; // Can be List or null
  final dynamic policiesGuidelines;
  final dynamic faq;
  final String businessId;
  final String? rowText;
  final String? createdAt;
  final String? updatedAt;

  AgentTraining({
    required this.id,
    required this.systemPrompt,
    this.businessInformation,
    this.productInformation,
    this.policiesGuidelines,
    this.faq,
    required this.businessId,
    this.rowText,
    this.createdAt,
    this.updatedAt,
  });

  factory AgentTraining.fromJson(Map<String, dynamic> json) {
    return AgentTraining(
      id: json['id'] ?? '',
      systemPrompt: json['systemPrompt'] ?? '',
      businessInformation: json['businessInformation'],
      productInformation: json['productInformation'],
      policiesGuidelines: json['policiesGuidelines'],
      faq: json['faq'],
      businessId: json['businessId'] ?? '',
      rowText: json['rowText'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'systemPrompt': systemPrompt,
      'businessInformation': businessInformation,
      'productInformation': productInformation,
      'policiesGuidelines': policiesGuidelines,
      'faq': faq,
      'businessId': businessId,
      'rowText': rowText,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class AgentTrainingResponse {
  final List<AgentTraining> trainings;
  final int total;
  final int page;
  final int limit;

  AgentTrainingResponse({
    required this.trainings,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory AgentTrainingResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] ?? {};
    final data = json['data'] as List<dynamic>? ?? [];

    return AgentTrainingResponse(
      trainings: data.map((e) => AgentTraining.fromJson(e)).toList(),
      total: meta['total'] ?? 0,
      page: meta['page'] ?? 1,
      limit: meta['limit'] ?? 10,
    );
  }
}
