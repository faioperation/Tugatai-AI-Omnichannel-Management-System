import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/WebChat/bloc/web_chat_event.dart';
import 'package:roberto/features/WebChat/bloc/web_chat_state.dart';
import 'package:roberto/features/WebChat/data/repositories/web_chat_repository.dart';

class WebChatBloc extends Bloc<WebChatEvent, WebChatState> {
  final WebChatRepository repository;

  WebChatBloc({required this.repository}) : super(WebChatInitial()) {
    on<FetchWebhooks>(_onFetchWebhooks);
    on<GenerateWebhook>(_onGenerateWebhook);
  }

  Future<void> _onFetchWebhooks(
      FetchWebhooks event, Emitter<WebChatState> emit) async {
    emit(WebChatLoading());
    try {
      final webhooks = await repository.getAllWebhooks();
      emit(WebChatLoaded(webhooks: webhooks));
    } catch (e) {
      emit(WebChatError(message: e.toString()));
    }
  }

  Future<void> _onGenerateWebhook(
      GenerateWebhook event, Emitter<WebChatState> emit) async {
    final currentState = state;
    emit(WebChatOperationInProgress());
    try {
      await repository.generateWebhook(
          businessId: event.businessId, branchId: event.branchId);
      emit(WebChatOperationSuccess(message: 'Webhook generated successfully'));
      add(FetchWebhooks());
    } catch (e) {
      emit(WebChatOperationError(message: e.toString()));
      if (currentState is WebChatLoaded) {
        emit(currentState);
      } else {
        add(FetchWebhooks());
      }
    }
  }
}
