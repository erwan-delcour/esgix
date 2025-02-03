import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoginUserEvent extends UserEvent {
  final String email;
  final String password;

  const LoginUserEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class UpdateUserEvent extends UserEvent {
  final String? username;
  final String? avatar;
  final String? description;

  const UpdateUserEvent({
    this.username,
    this.avatar,
    this.description,
  });

  @override
  List<Object?> get props => [username, avatar, description];
}

class RegisterUserEvent extends UserEvent {
  final String email;
  final String username;
  final String password;
  final String? avatar;

  RegisterUserEvent({
    required this.email,
    required this.username,
    required this.password,
    this.avatar,
  });

  @override
  List<Object?> get props => [email, username, password, avatar];
}