class AgentModel {
  final String id;
  final String businessId;
  final String branchId;
  final String? rulesFile;
  final String? productFile;
  final String? vapiId;
  final AgentMetadata? metadata;
  final String? createdAt;
  final String? updatedAt;
  final String? twilioSid;
  final String? twilioAuthToken;
  final String? twilioNumber;
  final String? transferNumber;

  AgentModel({
    required this.id,
    required this.businessId,
    required this.branchId,
    this.rulesFile,
    this.productFile,
    this.vapiId,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.twilioSid,
    this.twilioAuthToken,
    this.twilioNumber,
    this.transferNumber,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>? ?? {};
    return AgentModel(
      id: json['id'] ?? '',
      businessId: json['businessId'] ?? '',
      branchId: json['branchId'] ?? '',
      rulesFile: json['rulesFile'],
      productFile: json['productFile'],
      vapiId: json['vapiId'],
      metadata: json['metadata'] != null
          ? AgentMetadata.fromJson(json['metadata'])
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      twilioSid:
          json['twilioSid'] ??
          json['twilio_sid'] ??
          meta['twilioSid'] ??
          meta['twilio_sid'],
      twilioAuthToken:
          json['twilioAuthToken'] ??
          json['twilio_auth_token'] ??
          meta['twilioAuthToken'] ??
          meta['twilio_auth_token'],
      twilioNumber:
          json['twilioNumber'] ??
          json['twilio_number'] ??
          meta['twilioNumber'] ??
          meta['twilio_number'],
      transferNumber:
          json['transferNumber'] ??
          json['transfer_number'] ??
          meta['transferNumber'] ??
          meta['transfer_number'],
    );
  }
}

class AgentMetadata {
  final String? agentName;
  final String? businessId;
  final String? assistantId;
  final Map<String, dynamic>? twilioResponse;

  AgentMetadata({this.agentName, this.businessId, this.assistantId, this.twilioResponse});

  factory AgentMetadata.fromJson(Map<String, dynamic> json) {
    return AgentMetadata(
      agentName: json['agentName'] ?? json['agent_name'],
      businessId: json['business_id'],
      assistantId: json['assistant_id'],
      twilioResponse: json['twilioResponse'] as Map<String, dynamic>?,
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
