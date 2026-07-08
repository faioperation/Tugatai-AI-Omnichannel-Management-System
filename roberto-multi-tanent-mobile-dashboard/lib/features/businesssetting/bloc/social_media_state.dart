import 'package:equatable/equatable.dart';

class SocialMediaState extends Equatable {
  final bool isLoading;
  final bool isFacebookConnected;
  final String? facebookConnectionId;
  final bool isInstagramConnected;
  final String? instagramConnectionId;
  final bool isWhatsAppConnected;
  final String? whatsappAccountId;
  final String? error;
  final String? redirectUrl;

  const SocialMediaState({
    this.isLoading = false,
    this.isFacebookConnected = false,
    this.facebookConnectionId,
    this.isInstagramConnected = false,
    this.instagramConnectionId,
    this.isWhatsAppConnected = false,
    this.whatsappAccountId,
    this.error,
    this.redirectUrl,
  });

  SocialMediaState copyWith({
    bool? isLoading,
    bool? isFacebookConnected,
    String? facebookConnectionId,
    bool? isInstagramConnected,
    String? instagramConnectionId,
    bool? isWhatsAppConnected,
    String? whatsappAccountId,
    String? error,
    String? redirectUrl,
    bool clearRedirectUrl = false,
    bool clearError = false,
  }) {
    return SocialMediaState(
      isLoading: isLoading ?? this.isLoading,
      isFacebookConnected: isFacebookConnected ?? this.isFacebookConnected,
      facebookConnectionId: facebookConnectionId ?? this.facebookConnectionId,
      isInstagramConnected: isInstagramConnected ?? this.isInstagramConnected,
      instagramConnectionId: instagramConnectionId ?? this.instagramConnectionId,
      isWhatsAppConnected: isWhatsAppConnected ?? this.isWhatsAppConnected,
      whatsappAccountId: whatsappAccountId ?? this.whatsappAccountId,
      error: clearError ? null : (error ?? this.error),
      redirectUrl: clearRedirectUrl ? null : (redirectUrl ?? this.redirectUrl),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isFacebookConnected,
        facebookConnectionId,
        isInstagramConnected,
        instagramConnectionId,
        isWhatsAppConnected,
        whatsappAccountId,
        error,
        redirectUrl,
      ];
}
