import 'package:flutter/material.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/services/aws_cognito.dart';
import '../widget/input_field.dart';
import '../widget/primary_btn.dart';
import 'spacer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController nicknameController;
  late TextEditingController middleNameController;
  late TextEditingController givenNameController;
  late TextEditingController familyNameController;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nicknameController = TextEditingController();
    middleNameController = TextEditingController();
    givenNameController = TextEditingController();
    familyNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nicknameController.dispose();
    middleNameController.dispose();
    givenNameController.dispose();
    familyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              InputField(
                controller: emailController,
                isPassword: false,
                labelTxt: 'Email',
                icon: Icons.person,
              ),
              InputField(
                controller: passwordController,
                isPassword: true,
                labelTxt: 'Password',
                icon: Icons.lock,
              ),
              InputField(
                controller: givenNameController,
                isPassword: false,
                labelTxt: 'Given Name',
                icon: Icons.person,
              ),
              InputField(
                controller: middleNameController,
                isPassword: false,
                labelTxt: 'Middle Name',
                icon: Icons.person,
              ),
              InputField(
                controller: familyNameController,
                isPassword: false,
                labelTxt: 'Family Name',
                icon: Icons.person,
              ),
              HeightSpacer(myHeight: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PrimaryBtn(
                  btnText: 'Register',
                  btnFun: () => register(
                    context,
                    emailController.text,
                    passwordController.text,
                    middleNameController.text,
                    givenNameController.text,
                    familyNameController.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void register(BuildContext context, String email, String password,
      String givenName, String middleName, String familyName) {
    AWSServices()
        .register(context, email, password, givenName, middleName, familyName);
  }
}
