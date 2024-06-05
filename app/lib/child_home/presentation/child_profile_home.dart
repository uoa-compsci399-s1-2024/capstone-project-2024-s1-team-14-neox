import 'package:capstone_project_2024_s1_team_14_neox/child_home/domain/child_device_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
  final PageController _pageController = PageController();

  @override
  void initState() {
    context.read<AllChildProfileCubit>().fetchChildProfiles();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        Size screenSize = MediaQuery.sizeOf(context);
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return SingleChildScrollView(
      child: SizedBox(
        height: screenHeight * 0.88,
        width: screenWidth,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Home"),
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
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                );
              }
              if (state.status.isDeleteSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                );
              }
              if (state.status.isFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.grey,
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
              if (state.status.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
        
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        scrollDirection: Axis.horizontal,
                        controller: _pageController,
                        children: [
                          ...state.profiles.map(
                            (profile) => BlocProvider(
                              // We have a problem with our ChildDeviceCubit not updating when we change it.
                              // This UniqueKey is a workaround which causes a new ChildDeviceCubit to be
                              // created every time the build function runs.
                              key: UniqueKey(),
        
                              create: (_) {
                                return ChildDeviceCubit(
                                  repo: context.read<ChildDeviceRepository>(),
                                  childId: profile.childId,
                                  childName: profile.childName,
                                  birthDate: profile.birthDate,
                                  gender: profile.gender,
                                  deviceRemoteId: profile.deviceRemoteId ?? "",
                                  authorisationCode:
                                      profile.authorisationCode ?? "",
                                  outdoorTimeToday: profile.outdoorTimeToday!,
                                  outdoorTimeWeek: profile.outdoorTimeWeek!,
                                  outdoorTimeMonth: profile.outdoorTimeMonth!,
                                );
                              },
                              child: const ChildProfileTile(),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Add new child",
                                style: TextStyle(fontSize: 20),
                              ),
                              IconButton(
                                splashColor: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.1),
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.1),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateChildProfileScreen(
                                              editing: false)),
                                ),
                                icon: Icon(
                                  Icons.add,
                                  size: 100,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: state.profiles.length + 1,
                      effect: ScrollingDotsEffect(
                        // fixedCenter: true,
                        dotColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.2),
                        activeDotColor: Theme.of(context).colorScheme.primary,
                        radius: 8,
                        dotHeight: 12,
                        dotWidth: 12,
                        activeDotScale: 1.2,
                      ),
                    )
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
        ),
      ),
    );
  }
}
