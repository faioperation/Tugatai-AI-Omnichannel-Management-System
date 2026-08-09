abstract class WebChatEvent {}

class FetchWebhooks extends WebChatEvent {}

class GenerateWebhook extends WebChatEvent {
  final String businessId;
  final String branchId;

  GenerateWebhook({required this.businessId, required this.branchId});
}
