import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gooteam_stream/features/auth/repositories/auth_repository.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;

  RegisterCubit(this._authRepository) : super(const RegisterState());

  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: RegisterStatus.initial));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: RegisterStatus.initial));
  }

  Future<void> signUpWithCredentials() async {
    if (state.status == RegisterStatus.submitting) return;
    emit(state.copyWith(status: RegisterStatus.submitting));
    try {
      await _authRepository.signUp(
        email: state.email,
        password: state.password,
      );
      emit(state.copyWith(status: RegisterStatus.success));
    } on SignUpWithEmailAndPasswordFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: RegisterStatus.error,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: RegisterStatus.error));
    }
  }
}
