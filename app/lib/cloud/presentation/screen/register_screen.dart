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
  late bool _passwordVisible;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nicknameController = TextEditingController();
    middleNameController = TextEditingController();
    givenNameController = TextEditingController();
    familyNameController = TextEditingController();
    _passwordVisible = false;
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
              TextField(
                controller: emailController,
                obscureText: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )),
                  // prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: passwordController,
                obscureText: !_passwordVisible,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                      icon: Icon(_passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      }),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )),
                  // prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: givenNameController,
                obscureText: false,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Given name",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )),
                  // prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: middleNameController,
                obscureText: false,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Middle name",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )),
                  // prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: familyNameController,
                obscureText: false,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Family name",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )),
                  // prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              PrimaryBtn(
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
