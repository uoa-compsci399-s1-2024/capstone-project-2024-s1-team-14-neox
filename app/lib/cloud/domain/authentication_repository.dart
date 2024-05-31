import '../services/aws_cognito.dart';

class AuthenticationRepository {

  final AWSServices awsServices = AWSServices();

  // Method to log in with email and password
  Future<bool> logInWithEmailAndPassword(
     String email,
     String password,
  ) async {
    try {

      var response = await awsServices.createInitialRecord(email, password);
      return(response);
    } catch (e) {
      throw AuthenticationException('Failed to log in: $e');

    }
  }

  Future<void> logInWithGoogle() async {

  }

}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
}
