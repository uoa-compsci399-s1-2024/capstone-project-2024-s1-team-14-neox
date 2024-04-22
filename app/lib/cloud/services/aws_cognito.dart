
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/cloud_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../presentation/screen/confirmation.dart';

class AWSServices {
  CognitoUserSession? session;

  final userPool = CognitoUserPool(
    '${(dotenv.env['POOL_ID'])}',
    '${(dotenv.env['CLIENT_ID'])}',
  );


  void register(BuildContext context, String email, String password,
       String middleName, String givenName,
      String familyName) async {
    try {
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationPage(email: email),
        ),
      );
    } catch (e) {
      print('Error during user registration: $e');
    }
  }


  Future createInitialRecord(BuildContext context, String email,
      String password) async {
    debugPrint('Authenticating User...');
    final cognitoUser = CognitoUser(email, userPool);
    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );

    try {
      session = await cognitoUser.authenticateUser(authDetails);
      debugPrint('Login Success...');
    } on CognitoUserNewPasswordRequiredException catch (e) {

      debugPrint('CognitoUserNewPasswordRequiredException $e');
    } on CognitoUserMfaRequiredException catch (e) {

      debugPrint('CognitoUserMfaRequiredException $e');
    } on CognitoUserSelectMfaTypeException catch (e) {

      debugPrint('CognitoUserMfaRequiredException $e');
    } on CognitoUserMfaSetupException catch (e) {

      debugPrint('CognitoUserMfaSetupException $e');
    } on CognitoUserTotpRequiredException catch (e) {

      debugPrint('CognitoUserTotpRequiredException $e');
    } on CognitoUserCustomChallengeException catch (e) {

      debugPrint('CognitoUserCustomChallengeException $e');

    } on CognitoUserConfirmationNecessaryException catch (e) {
      debugPrint('CognitoUserConfirmationNecessaryException $e');

    } on CognitoClientException catch (e) {
      if (e is CognitoClientException &&
          e.name == 'UserNotConfirmedException') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationPage(email: email),
          ),
        );
      }
      debugPrint('CognitoClientException $e');

    } catch (e) {

      print(e);

    }
    print(session?.getAccessToken().getJwtToken());
  }

 bool confirmUser(){
    if(AWSServices().session == null){
      return false;
    }else{
      return true;
    }
  }




}