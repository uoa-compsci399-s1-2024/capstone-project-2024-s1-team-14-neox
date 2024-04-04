import 'package:ble_skeleton/child_profile/cubit/child_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'screens/create_child_profile_screen.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => ChildHomeScreenState();
}

class ChildHomeScreenState extends State<ChildHomeScreen> {
  @override
  void initState() {
    context.read<ChildProfileCubit>().fetchChildProfiles();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your profiles"),
      ),
      body: BlocConsumer<ChildProfileCubit, ChildProfileState>(
        listener: (context, state) {
          if (state.status.isAddSuccess) {
            print(state.message);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                
                content: Text(state.message),
                backgroundColor: Colors.lightBlue,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            children: [
              Text(state.profiles.toString()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const CreateChildProfileScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
