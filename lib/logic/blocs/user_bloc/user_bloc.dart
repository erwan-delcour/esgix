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
    on<RegisterUserEvent>(_onRegisterUser);
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

      final String? newUsername =
          (event.username != null && event.username != currentUser.username)
              ? event.username
              : null;
      final String? newAvatar =
          (event.avatar != null && event.avatar != currentUser.avatar)
              ? event.avatar
              : null;
      final String? newDescription = (event.description != null &&
              event.description != currentUser.description)
          ? event.description
          : (event.description == "" ? "" : null); 

      await userRepository.update(
        currentUser.token,
        currentUser.id,
        username: newUsername,
        avatar: newAvatar,
        description: newDescription,
      );

      final updatedUser = User(
        id: currentUser.id,
        username: newUsername ?? currentUser.username,
        email: currentUser.email,
        avatar: newAvatar ?? currentUser.avatar,
        description: newDescription ?? currentUser.description, 
        token: currentUser.token,
      );

      emit(state.copyWith(user: updatedUser, status: UserStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: UserStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      final user = await userRepository.registerUser(
        email: event.email,
        username: event.username,
        password: event.password,
        avatar: event.avatar,
      );

      emit(state.copyWith(user: user, status: UserStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: UserStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }
}
