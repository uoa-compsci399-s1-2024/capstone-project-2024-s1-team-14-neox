import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../cubit/login_cubit.dart';
import '../../data/services/aws/aws_cognito.dart'; // Import your AWS Cognito service

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late TextEditingController emailController;
    late TextEditingController passwordController;

    emailController = TextEditingController();
    passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect with Neox Cloud"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Call createInitialRecord method from AWSServices to attempt to create a user
                  await AWSServices().createInitialRecord(
                    emailController.text,
                    passwordController.text,
                  );
                } catch (e) {
                  // Handle any errors that occur during user creation
                  print('User creation error: $e');
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User creation failed: $e'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'SIGN IN',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              label: const Text(
                'SIGN IN WITH GOOGLE',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              icon: const Icon(FontAwesomeIcons.google, color: Colors.white),
              onPressed: () {
                // Handle Google sign-in
              },
            ),
          ],
        ),
      ),
    );
  }
}
