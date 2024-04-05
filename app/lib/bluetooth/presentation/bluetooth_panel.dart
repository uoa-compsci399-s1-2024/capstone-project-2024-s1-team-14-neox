import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../child_home/cubit/device_pair_cubit.dart';
import '../bloc/bluetooth_bloc.dart';
import 'screen/scan_screen.dart';

class BluetoothPanel extends StatelessWidget {
  final String name;
  const BluetoothPanel({super.key, required this.name});

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
                onPressed: () {
                  Navigator.push(
                    context,
                    // Must use _ for context in builder, otherwise wrong context is looked up
                    MaterialPageRoute(builder: (_) {
                      return BlocProvider.value(
                        value: BlocProvider.of<BluetoothBloc>(context),
                        child: ScanScreen(name: name),
                      );
                    }),
                  );
                },
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
