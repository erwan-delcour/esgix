import 'package:esgix/data/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../../data/repositories/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(const UserState()) {
    on<LoginUserEvent>(_onLoginUser);
    on<UpdateUserEvent>(_onUpdateUser);
  }

  Future<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      final user = await userRepository.login(
        event.email,
        event.password,
      );
      emit(state.copyWith(user: user, status: UserStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: UserStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

    Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading));

      try {
        final currentUser = state.user!;
        final updatedUser = User(
          id: currentUser.id,
          username: (event.username?.isNotEmpty ?? false) ? event.username! : currentUser.username,
          email: currentUser.email,
          avatar: (event.avatar?.isNotEmpty ?? false) ? event.avatar! : currentUser.avatar,
          description: (event.description?.isNotEmpty ?? false) ? event.description! : currentUser.description,
          token: currentUser.token,
        );

        await userRepository.update(
          currentUser.token,
          currentUser.id,
          username: event.username ?? currentUser.username,
          avatar: event.avatar,
          description: event.description,
        );

        emit(state.copyWith(user: updatedUser, status: UserStatus.success));
      } catch (error) {
        emit(state.copyWith(
          status: UserStatus.error,
          errorMessage: error.toString(),
        ));
      }
    }
}