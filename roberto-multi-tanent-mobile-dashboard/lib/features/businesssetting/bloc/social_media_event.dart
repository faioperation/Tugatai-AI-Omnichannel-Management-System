import 'package:equatable/equatable.dart';

abstract class SocialMediaEvent extends Equatable {
  const SocialMediaEvent();

  @override
  List<Object> get props => [];
}

class CheckSocialMediaStatus extends SocialMediaEvent {
  final String branchId;
  const CheckSocialMediaStatus(this.branchId);

  @override
  List<Object> get props => [branchId];
}

class ConnectFacebook extends SocialMediaEvent {
  final String branchId;
  const ConnectFacebook(this.branchId);

  @override
  List<Object> get props => [branchId];
}

class DisconnectFacebook extends SocialMediaEvent {
  final String connectionId;
  final String branchId;
  const DisconnectFacebook(this.connectionId, this.branchId);

  @override
  List<Object> get props => [connectionId, branchId];
}

class ConnectInstagram extends SocialMediaEvent {
  final String branchId;
  const ConnectInstagram(this.branchId);

  @override
  List<Object> get props => [branchId];
}

class DisconnectInstagram extends SocialMediaEvent {
  final String connectionId;
  final String branchId;
  const DisconnectInstagram(this.connectionId, this.branchId);

  @override
  List<Object> get props => [connectionId, branchId];
}

class ConnectWhatsApp extends SocialMediaEvent {
  final String branchId;
  const ConnectWhatsApp(this.branchId);

  @override
  List<Object> get props => [branchId];
}

class DisconnectWhatsApp extends SocialMediaEvent {
  final String accountId;
  final String branchId;
  const DisconnectWhatsApp(this.accountId, this.branchId);

  @override
  List<Object> get props => [accountId, branchId];
}

class ConnectGoogleCalendar extends SocialMediaEvent {
  final String branchId;
  const ConnectGoogleCalendar(this.branchId);

  @override
  List<Object> get props => [branchId];
}

class DisconnectGoogleCalendar extends SocialMediaEvent {
  final String branchId;
  const DisconnectGoogleCalendar(this.branchId);

  @override
  List<Object> get props => [branchId];
}

