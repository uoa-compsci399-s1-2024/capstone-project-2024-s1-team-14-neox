import 'package:age_calculator/age_calculator.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';

import '../../../bluetooth/bloc/bluetooth_bloc.dart';
import '../../../bluetooth/presentation/bluetooth_panel.dart';
import '../../cubit/all_child_profile_cubit.dart';
import '../../cubit/child_device_cubit.dart';

class ChildProfileTile extends StatefulWidget {
  const ChildProfileTile({super.key});

  @override
  State<ChildProfileTile> createState() => _ChildProfileTileState();
}

class _ChildProfileTileState extends State<ChildProfileTile> {
  String calculateAge(DateTime birthDate) {
    DateDuration duration = AgeCalculator.age(birthDate);
    return "${duration.years} years, ${duration.months} months";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          const Icon(
            Icons.face,
            size: 100,
          ),
          const Text("Name"),
          Text(
            context.read<ChildDeviceCubit>().state.childName,
            style: const TextStyle(
              fontSize: 30,
            ),
          ),
          const Text("Age"),
          Text(
            calculateAge(context.read<ChildDeviceCubit>().state.birthDate),
            style: const TextStyle(
              fontSize: 30,
            ),
          ),
          BlocConsumer<ChildDeviceCubit, ChildDeviceState>(
            listener: (context, state) {
            },
            builder: (context, state) {
              return BlocProvider(
                create: (_) => BluetoothBloc(),
                child: const BluetoothPanel(),
              );
            },
          ),
          OutlinedButton(
            onPressed: () => context.read<AllChildProfileCubit>()
              .deleteChildProfile(context.read<ChildDeviceCubit>().state.childId),
            child: const Text("Remove child profile")
          ),
          const Spacer(),
          BlocBuilder<ChildDeviceCubit, ChildDeviceState>(
            builder: (context, state) {
              if (state is ChildDeviceSyncingState && state.progress != null) {
                return LinearProgressBar(
                  maxSteps: 1000,
                  progressType: LinearProgressBar.progressTypeLinear,
                  currentStep: (state.progress! * 1000).round(),
                  progressColor: Colors.deepPurpleAccent,
                  backgroundColor: Colors.grey,
                  minHeight: 6,
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}
