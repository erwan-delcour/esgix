import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../../data/repositories/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(const UserState()) {
    on<LoginUserEvent>(_onLoginUser);
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
}