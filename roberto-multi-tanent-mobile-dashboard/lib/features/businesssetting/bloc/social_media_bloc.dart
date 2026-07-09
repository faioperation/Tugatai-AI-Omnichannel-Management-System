import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/businesssetting/data/repositories/social_media_repository.dart';
import 'social_media_event.dart';
import 'social_media_state.dart';

class SocialMediaBloc extends Bloc<SocialMediaEvent, SocialMediaState> {
  final SocialMediaRepository repository;

  SocialMediaBloc({required this.repository}) : super(const SocialMediaState()) {
    on<CheckSocialMediaStatus>(_onCheckSocialMediaStatus);
    on<ConnectFacebook>(_onConnectFacebook);
    on<DisconnectFacebook>(_onDisconnectFacebook);
    on<ConnectInstagram>(_onConnectInstagram);
    on<DisconnectInstagram>(_onDisconnectInstagram);
    on<ConnectWhatsApp>(_onConnectWhatsApp);
    on<DisconnectWhatsApp>(_onDisconnectWhatsApp);
    on<ConnectGoogleCalendar>(_onConnectGoogleCalendar);
    on<DisconnectGoogleCalendar>(_onDisconnectGoogleCalendar);
  }

  Future<void> _onCheckSocialMediaStatus(CheckSocialMediaStatus event, Emitter<SocialMediaState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final results = await Future.wait([
        repository.getFacebookStatus(event.branchId),
        repository.getInstagramStatus(event.branchId),
        repository.getWhatsAppStatus(event.branchId),
        repository.getGoogleCalendarStatus(event.branchId),
      ]);

      emit(state.copyWith(
        isLoading: false,
        isFacebookConnected: results[0]['connected'],
        facebookConnectionId: results[0]['id'],
        isInstagramConnected: results[1]['connected'],
        instagramConnectionId: results[1]['id'],
        isWhatsAppConnected: results[2]['connected'],
        whatsappAccountId: results[2]['id'],
        isGoogleCalendarConnected: results[3]['connected'],
        googleCalendarEmail: results[3]['email'],
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onConnectFacebook(ConnectFacebook event, Emitter<SocialMediaState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearRedirectUrl: true));
    try {
      final url = await repository.getFacebookAuthUrl(event.branchId);
      if (url != null) {
        emit(state.copyWith(isLoading: false, redirectUrl: url));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Failed to generate Facebook Auth URL.'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDisconnectFacebook(DisconnectFacebook event, Emitter<SocialMediaState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final success = await repository.disconnectFacebook(event.connectionId);
      if (success) {
        add(CheckSocialMediaStatus(event.branchId));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Failed to disconnect Facebook.'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onConnectInstagram(ConnectInstagram event, Emitter<SocialMediaState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearRedirectUrl: true));
    try {
      final url = await repository.getInstagramAuthUrl(event.branchId);
      if (url != null) {
        emit(state.copyWith(isLoading: false, redirectUrl: url));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Failed to generate Instagram Auth URL.'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDisconnectInstagram(DisconnectInstagram event, Emitter<SocialMediaState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final success = await repository.disconnectInstagram(event.connectionId);
      if (success) {
        add(CheckSocialMediaStatus(event.branchId));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Failed to disconnect Instagram.'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onConnectWhatsApp(ConnectWhatsApp event, Emitter<SocialMediaState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearRedirectUrl: true));
    try {
      final url = await repository.getWhatsAppAuthUrl(event.branchId);
      if (url != null) {
        // Quick fix: Meta no longer supports response_type=token for this specific Embedded Signup flow, it requires code.
        final fixedUrl = url.replaceAll('response_type=token', 'response_type=code');
        emit(state.copyWith(isLoading: false, redirectUrl: fixedUrl));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Failed to generate WhatsApp Auth URL.'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDisconnectWhatsApp(DisconnectWhatsApp event, Emitter<SocialMediaState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final success = await repository.disconnectWhatsApp(event.accountId);
      if (success) {
        add(CheckSocialMediaStatus(event.branchId));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Failed to disconnect WhatsApp.'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onConnectGoogleCalendar(ConnectGoogleCalendar event, Emitter<SocialMediaState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearRedirectUrl: true));
    try {
      final url = await repository.getGoogleCalendarAuthUrl(event.branchId);
      if (url != null) {
        emit(state.copyWith(isLoading: false, redirectUrl: url));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Failed to generate Google Calendar Auth URL.'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDisconnectGoogleCalendar(DisconnectGoogleCalendar event, Emitter<SocialMediaState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final success = await repository.disconnectGoogleCalendar(event.branchId);
      if (success) {
        add(CheckSocialMediaStatus(event.branchId));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Failed to disconnect Google Calendar.'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
