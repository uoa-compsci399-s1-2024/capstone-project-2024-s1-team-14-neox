import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bluetooth/bloc/bluetooth_bloc.dart';
import '../../data/child_repository.dart';
import '../cubit/child_profile_cubit.dart';
import 'screens/create_child_profile_screen.dart';
import 'tiles/child_profile_tile.dart';

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
          return Container(
            child: PageView(
              scrollDirection: Axis.horizontal,
              children: [
                ...state.profiles.map(
                  (profile) => BlocProvider(
                    create: (_) =>
                        BluetoothBloc(context.read<ChildRepository>()),
                    child: ChildProfileTile(
                      profile: profile,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateChildProfileScreen()),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => const CreateChildProfileScreen()),
      //   ),
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
