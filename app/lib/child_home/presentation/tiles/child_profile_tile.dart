import 'package:age_calculator/age_calculator.dart';
import 'package:capstone_project_2024_s1_team_14_neox/child_home/presentation/screens/create_child_profile_screen.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    ChildDeviceState state = context.read<ChildDeviceCubit>().state;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          Row(children: [
            Text(
              state.childName,
              style: const TextStyle(fontSize: 30)
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return BlocProvider.value(
                        value: BlocProvider.of<AllChildProfileCubit>(context),
                        child: BlocProvider.value(
                          value: BlocProvider.of<ChildDeviceCubit>(context),
                          child: const CreateChildProfileScreen(editing: true),
                        ),
                      );
                    },
                  ),
                );
              },
              icon: const Icon(Icons.edit),
            ),
            const Spacer(),
            BlocProvider(
              create: (_) => BluetoothBloc(),
              child: const BluetoothPanel(),
            ),
          ]),
          
        ],
      ),
    );
  }
}
