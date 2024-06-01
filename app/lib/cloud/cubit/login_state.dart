part of 'login_cubit.dart';

enum LoginStatus {
  initial,
  loading,
  loginSuccess,
  logoutSuccess,
  failure,
}

extension LoginStatusX on LoginStatus {
  bool get isInitial => this == LoginStatus.initial;
  bool get isLoading => this == LoginStatus.loading;
  bool get isLoginSuccess => this == LoginStatus.loginSuccess;
  bool get isLogoutSuccess => this == LoginStatus.logoutSuccess;
  bool get isFailure => this == LoginStatus.failure;
}



class LoginState extends Equatable {
  const LoginState({

    this.status = LoginStatus.initial,
    this.isValid = false,
    this.message,
  });

  final LoginStatus status;
  final bool isValid;
  final String? message;

  @override
  List<Object?> get props => [status, isValid, message];

  LoginState copyWith({
    LoginStatus? status,
    bool? isValid,
    String? message,
  }) {
    return LoginState(
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      message: message ?? this.message,
    );
  }
}