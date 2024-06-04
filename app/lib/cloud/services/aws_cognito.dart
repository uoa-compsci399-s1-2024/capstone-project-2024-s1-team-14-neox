import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/screen/sync_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/cloud_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../presentation/screen/confirmation.dart';

class AWSServices {
  final storage = FlutterSecureStorage();

  Future<void> initializeStorage() async {
    await storage.write(key: 'access_token', value: null);
    await storage.write(key: 'refresh_token', value: null);
    await storage.write(key: 'id_token', value: null);
  }

  final userPool = CognitoUserPool(
    '${(dotenv.env['POOL_ID'])}',
    '${(dotenv.env['CLIENT_ID'])}',
  );

  Future<bool> register(BuildContext context, String email, String password,
      String middleName, String givenName, String familyName) async {
    try {
      print("$email $password $middleName $givenName $familyName");
      var signUpResult = await userPool.signUp(
        email,
        password,
        userAttributes: [
          AttributeArg(name: 'email', value: email),
          AttributeArg(name: 'nickname', value: 'whocares'),
          AttributeArg(name: 'middle_name', value: middleName),
          AttributeArg(name: 'given_name', value: givenName),
          AttributeArg(name: 'family_name', value: familyName),
        ],
      );
      print('User registration successful: ${signUpResult.user}');
      return true;
    } catch (e) {
      print('Error during user registration: $e');
      return false;
    }
  }

  Future<bool> createInitialRecord(String email, String password) async {
    debugPrint('Authenticating User...');
    final cognitoUser = CognitoUser(email, userPool);
    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );
    CognitoUserSession? session;
    try {
      session = await cognitoUser.authenticateUser(authDetails);
      debugPrint('Login Success...');
      final accessToken = session?.getAccessToken().jwtToken;
      final refreshToken = session?.getRefreshToken()?.getToken();
      final idToken = session?.getIdToken().jwtToken;

      await storage.write(key: 'email',value: session?.getIdToken().payload["email"]);
      await storage.write(key: 'access_token', value: accessToken);
      await storage.write(key: 'refresh_token', value: refreshToken);
      await storage.write(key: 'id_token', value: idToken);

      return (true);
    } on CognitoUserNewPasswordRequiredException catch (e) {
      return (false);
      debugPrint('CognitoUserNewPasswordRequiredException $e');
    } on CognitoUserMfaRequiredException catch (e) {
      return (false);
      debugPrint('CognitoUserMfaRequiredException $e');
    } on CognitoUserSelectMfaTypeException catch (e) {
      return (false);
      debugPrint('CognitoUserMfaRequiredException $e');
    } on CognitoUserMfaSetupException catch (e) {
      return (false);
      debugPrint('CognitoUserMfaSetupException $e');
    } on CognitoUserTotpRequiredException catch (e) {
      return (false);
      debugPrint('CognitoUserTotpRequiredException $e');
    } on CognitoUserCustomChallengeException catch (e) {
      return (false);
      debugPrint('CognitoUserCustomChallengeException $e');
    } on CognitoUserConfirmationNecessaryException catch (e) {
      debugPrint('CognitoUserConfirmationNecessaryException $e');
      return (false);
    } on CognitoClientException catch (e) {
      return (false);
      debugPrint('CognitoClientException $e');
    } catch (e) {
      print(e);
      return (false);
    }
  }

  Future<bool> confirm(String email, String code) async {
    final cognitoUser = CognitoUser(email, userPool);

    bool registrationConfirmed = false;
    try {
      registrationConfirmed = await cognitoUser.confirmRegistration(code);
      return true;
    } catch (e) {
      if (e is CognitoClientException && e.name == 'ExpiredCodeException') {
        // Code has expired, resend the code
        try {
          await cognitoUser.resendConfirmationCode();
          print('Confirmation code resent');
        } catch (resendError) {
          print('Error resending confirmation code: $resendError');
        }
        print(e);
      }
      print(registrationConfirmed);
    }
    return false;
  }

  Future<bool> inSession() async {
    return await storage.read(key: 'access_token') != null;
  }

  Future<String?> getToken() async {

    return await storage.read(key: 'id_token');
  }

  Future<String?> getEmail() async {

    return await storage.read(key: 'email');
  }

}
