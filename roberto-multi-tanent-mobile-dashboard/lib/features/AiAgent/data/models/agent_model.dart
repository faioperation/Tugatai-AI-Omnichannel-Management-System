class AgentModel {
  final String id;
  final String businessId;
  final String branchId;
  final String? rulesFile;
  final String? vapiId;
  final AgentMetadata? metadata;
  final String? createdAt;
  final String? updatedAt;

  AgentModel({
    required this.id,
    required this.businessId,
    required this.branchId,
    this.rulesFile,
    this.vapiId,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id'] ?? '',
      businessId: json['businessId'] ?? '',
      branchId: json['branchId'] ?? '',
      rulesFile: json['rulesFile'],
      vapiId: json['vapiId'],
      metadata: json['metadata'] != null ? AgentMetadata.fromJson(json['metadata']) : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class AgentMetadata {
  final String? agentName;
  final String? businessId;
  final String? assistantId;

  AgentMetadata({this.agentName, this.businessId, this.assistantId});

  factory AgentMetadata.fromJson(Map<String, dynamic> json) {
    return AgentMetadata(
      agentName: json['agentName'] ?? json['agent_name'],
      businessId: json['business_id'],
      assistantId: json['assistant_id'],
    );
  }
}

class AgentListResponse {
  final List<AgentModel> agents;
  final int total;
  final int page;
  final int limit;

  AgentListResponse({
    required this.agents,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory AgentListResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] ?? {};
    final data = json['data'] as List<dynamic>? ?? [];

    return AgentListResponse(
      agents: data.map((e) => AgentModel.fromJson(e)).toList(),
      total: meta['total'] ?? 0,
      page: meta['page'] ?? 1,
      limit: meta['limit'] ?? 10,
    );
  }
}
