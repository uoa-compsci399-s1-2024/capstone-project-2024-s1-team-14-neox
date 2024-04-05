import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../child_home/cubit/device_pair_cubit.dart';
import '../bloc/bluetooth_bloc.dart';

class BluetoothPanel extends StatelessWidget {
  const BluetoothPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevicePairCubit, DevicePairState>(
      builder: (context, state) {
        if (state is DevicePairLoading) {
          return CircularProgressIndicator();
        }
        if (state is DevicePairUnknown || state is DeviceUnpairSuccess) {
          return Column(
            children: [
              ElevatedButton(
                onPressed: null,
                child: const Text("Pair device"),
              ),
            ],
          );
        }
        return Column(
          children: [
            ElevatedButton(
              onPressed: null,
              child: Text("Sync device"),
            ),
            ElevatedButton(
              onPressed: null,
              child: Text("Unpair device"),
            ),
          ],
        );
      },
    );
  }
}
