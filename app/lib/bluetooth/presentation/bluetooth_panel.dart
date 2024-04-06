import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../child_home/cubit/child_profile_cubit.dart';
import '../../child_home/cubit/device_pair_cubit.dart';
import '../bloc/bluetooth_bloc.dart';
import 'screen/scan_screen.dart';

class BluetoothPanel extends StatelessWidget {
  final String name;
  const BluetoothPanel({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BluetoothBloc, BluetoothState>(
      listener: (context, state) {
        if (state.status.isConnectSuccess) {
          // TODO: Change repository function to update remote ID
          // TODO: may need to change the chain of updating deviceRemoteID, currently calling two functions
          context.read<ChildProfileCubit>().updateDeviceRemoteId(
              name: name, deviceRemoteId: state.newDeviceRemoteId);

          context
              .read<DevicePairCubit>()
              .onDevicePairSuccess(state.newDeviceRemoteId);
        }
      },
      child: BlocBuilder<DevicePairCubit, DevicePairState>(
        builder: (context, state) {
          if (state.status.isLoading) {
            return CircularProgressIndicator();
          }
          if (state.status.isUnknown || state.status.isUnpairSuccess) {
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
                ElevatedButton(
                  onPressed: () {
                    print(context.read<ChildProfileCubit>().state.profiles);
                  },
                  child: Text("Test"),
                )
              ],
            );
          }
          return Column(
            children: [
              ElevatedButton(
                onPressed: () => context.read<BluetoothBloc>().add(
                          BluetoothConnectPressed(
                              deviceRemoteId: state.deviceRemoteId ?? "")),
                child: Text("Sync device"),
              ),
              ElevatedButton(
                onPressed: null,
                child: Text("Unpair device"),
              ),
              ElevatedButton(
                onPressed: () {
                  print(context.read<ChildProfileCubit>().state.profiles);
                },
                child: Text("Test"),
              )
            ],
          );
        },
      ),
    );
  }
}
