import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/services/aws_cognito.dart';
import '../../cubit/login_cubit.dart';
import '../../domain/authentication_repository.dart';
import '../widget/input_field.dart';
import '../widget/primary_btn.dart';
import 'spacer.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late bool _passwordVisible;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _passwordVisible = false;
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double screeWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return BlocProvider(
      create: (context) => LoginCubit(AuthenticationRepository()),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Connect with Neox Cloud"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                const Text(
                  "Welcome!",
                  style: TextStyle(fontSize: 24),
                ),
                const Text(
                  "Please log into your Neox account",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: screeWidth * 0.1,
                ),
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
                // InputField(
                //   controller: emailController,
                //   isPassword: false,
                //   labelTxt: 'Email',
                //   icon: Icons.person,
                // ),
                // InputField(
                //   controller: passwordController,
                //   isPassword: true,
                //   labelTxt: 'Password',
                //   icon: Icons.lock,
                // ),
                const SizedBox(
                  height: 40,
                ),
                // TextButton(
                //   style: ButtonStyle(backgroundColor:Theme.of(context).colorScheme.),
                //   onPressed: () =>
                //       context.read<LoginCubit>().logInWithEmailAndPassword(
                //             emailController.text,
                //             passwordController.text,
                //           ),
                //   child: const Text(
                //     'Log in',
                //     style: TextStyle(fontSize: 24),
                //   ),
                // ),
                SizedBox(
                  // padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                  width: screeWidth,
                  height: 60,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ))),
                    child: const Text(
                      'Log in',
                      style: TextStyle(fontSize: 24),
                    ),
                    onPressed: () =>
                        context.read<LoginCubit>().logInWithEmailAndPassword(
                              emailController.text,
                              passwordController.text,
                            ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Text("Don't have an account? Register here"),
                  ),
                ),

                // TODO remove
                ElevatedButton(
                  child: const Text("Test"),
                  onPressed: () => context.read<LoginCubit>().logInWithGoogle(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
