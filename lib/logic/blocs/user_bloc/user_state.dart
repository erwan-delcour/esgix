import 'package:equatable/equatable.dart';
import '../../../data/models/user.dart';

enum UserStatus { initial, loading, success, error }

class UserState extends Equatable {
  final User? user;
  final UserStatus status;
  final String? errorMessage;

  const UserState({
    this.user,
    this.status = UserStatus.initial,
    this.errorMessage,
  });

  UserState copyWith({
    User? user,
    UserStatus? status,
    String? errorMessage,
  }) {
    return UserState(
      user: user ?? this.user,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [user ?? '', status, errorMessage ?? ''];
}