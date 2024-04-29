import 'package:capstone_project_2024_s1_team_14_neox/child_home/domain/child_device_repository.dart';
import 'package:capstone_project_2024_s1_team_14_neox/theme/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../cubit/all_child_profile_cubit.dart';
import '../cubit/child_device_cubit.dart';
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
    context.read<AllChildProfileCubit>().fetchChildProfiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your profiles"),
      ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 30.0),
              child: Row(
                children: [
                  const Text("Dark Mode"),
                  const SizedBox(width: 8),
                  CupertinoSwitch(
                    value: Provider.of<ThemeProvider>(context).isDarkMode,
                    onChanged: (value) =>
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: BlocConsumer<AllChildProfileCubit, AllChildProfileState>(
        listener: (context, state) {
          // if (state.status.isAdding) {
          //   Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                   builder: (context) =>
          //                       const CreateChildProfileScreen()),
          //             );

          // }
          if (state.status.isAddSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.lightBlue,
              ),
            );
          // } else if (state.status.isDeleteSuccess) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       content: Text(state.message),
          //       backgroundColor: Colors.lightBlue,
          //     ),
          //   );
          }
        },
        builder: (context, state) {
          print("state change occured");
          print(state);
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
                    create: (_) => ChildDeviceCubit(
                      repo: context.read<ChildDeviceRepository>(),
                      childId: profile.childId,
                      childName: profile.childName,
                      birthDate: profile.birthDate,
                      deviceRemoteId: profile.deviceRemoteId ??
                          "", // Change ?? to ! and make deviceRemoteId nonnullable.
                      authorisationCode:
                          profile.authorisationCode ?? "", // Same here
                    ),
                    child: const ChildProfileTile(),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Add a new child"),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CreateChildProfileScreen()),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 100,
                      ),
                    ),
                  ],
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
