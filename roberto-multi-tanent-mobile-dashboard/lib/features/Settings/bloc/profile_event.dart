import 'package:flutter/foundation.dart';

@immutable
abstract class ProfileEvent {}

class FetchProfileRequested extends ProfileEvent {}

class UpdateProfileRequested extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String? avatarPath;
  final Uint8List? avatarBytes;
  final String? avatarName;

  UpdateProfileRequested({
    required this.firstName,
    required this.lastName,
    this.avatarPath,
    this.avatarBytes,
    this.avatarName,
  });
}
