import 'package:roberto/features/WebChat/data/models/web_chat_model.dart';

abstract class WebChatState {}

class WebChatInitial extends WebChatState {}

class WebChatLoading extends WebChatState {}

class WebChatLoaded extends WebChatState {
  final List<WebChatWebhook> webhooks;

  WebChatLoaded({required this.webhooks});
}

class WebChatError extends WebChatState {
  final String message;

  WebChatError({required this.message});
}

class WebChatOperationInProgress extends WebChatState {}

class WebChatOperationSuccess extends WebChatState {
  final String message;
  WebChatOperationSuccess({required this.message});
}

class WebChatOperationError extends WebChatState {
  final String message;
  WebChatOperationError({required this.message});
}
