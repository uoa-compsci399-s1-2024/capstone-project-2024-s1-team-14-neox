
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/authentication_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthenticationRepository _authenticationRepository;

  LoginCubit(this._authenticationRepository) : super(const LoginState() );

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      await _authenticationRepository.logInWithGoogle();
      emit(state.copyWith(status: LoginStatus.loginSuccess));
    } on /*LogInWithGoogleFailure*/ Exception catch (e) {
      emit(
        state.copyWith(
          message: e.toString(),
          status: LoginStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: LoginStatus.failure));
    }
  }
  Future<void> logInWithEmailAndPassword(String email, String password) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {

      var response = await _authenticationRepository.logInWithEmailAndPassword(email, password);
      if(response) {
        emit(state.copyWith(status: LoginStatus.loginSuccess));
      }else{
        emit(state.copyWith(status: LoginStatus.failure));
      }
      } on Exception catch (e) {
      emit(
        state.copyWith(
          message: e.toString(),
          status: LoginStatus.failure,
        ),
      );
    }
  }

}

