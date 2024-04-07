import 'package:age_calculator/age_calculator.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bluetooth/bloc/bluetooth_bloc.dart';
import '../../../bluetooth/presentation/bluetooth_panel.dart';
import '../../cubit/device_pair_cubit.dart';
import '../../domain/child_device_model.dart';

class ChildProfileTile extends StatefulWidget {
  final ChildDeviceModel profile;
  const ChildProfileTile({super.key, required this.profile});

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
            widget.profile.name,
            style: const TextStyle(
              fontSize: 30,
            ),
          ),
          const Text("Age"),
          Text(
            calculateAge(widget.profile.birthDate),
            style: const TextStyle(
              fontSize: 30,
            ),
          ),
          BlocConsumer<DevicePairCubit, DevicePairState>(
              listener: (context, state) {
            // if (state.status.isPairSuccess) {
            //   ScaffoldMessenger.of(context)
            //     ..hideCurrentSnackBar()
            //     ..showSnackBar(
            //       SnackBar(
            //         content: Text(state.message),
            //       ),
            //     );
            /*} else*/ if (state.status.isUnpairSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
            } else if (state.status.isFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
            }
          }, builder: (context, state) {
            return BlocProvider(
              create: (_) => BluetoothBloc(),
              child: BluetoothPanel(name: widget.profile.name, childId: widget.profile.id ?? -1,),
            );
          }),
        ],
      ),
    );
  }
}
