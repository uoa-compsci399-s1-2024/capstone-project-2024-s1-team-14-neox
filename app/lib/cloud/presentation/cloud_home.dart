import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cloud_sync_cubit.dart';
import '../cubit/login_cubit.dart';
import '../domain/authentication_repository.dart';
import 'screen/login_screen.dart';
import 'screen/sync_screen.dart';

class CloudHomeScreen extends StatelessWidget {
  const CloudHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(AuthenticationRepository()),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          // TODO: implement listener for login failure
        },
        builder: (context, state) {
          if (state.status.isLoading) {
            return const CircularProgressIndicator();
          } else if (state.status.isLoginSuccess) {
            return BlocProvider(
              create: (context) => CloudSyncCubit(),
              child: SyncScreen(),
            );
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
