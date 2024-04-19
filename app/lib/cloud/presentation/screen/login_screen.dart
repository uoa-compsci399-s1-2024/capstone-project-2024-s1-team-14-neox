
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../cubit/login_cubit.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect with Neox Cloud"),
      ),
      body: Column(
        children: [
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
            onPressed: () => context.read<LoginCubit>().logInWithGoogle(),
          ),
        ],
      ),
    );
  }
}
