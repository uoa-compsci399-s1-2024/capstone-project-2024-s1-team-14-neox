import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../child_home/cubit/child_profile_cubit.dart';
import '../../../child_home/cubit/device_pair_cubit.dart';
import '../../bloc/bluetooth_bloc.dart';
import '../tiles/scan_result_tile.dart';
import '../tiles/system_device_tile.dart';

class ScanScreen extends StatelessWidget {
  final String name;
  const ScanScreen({super.key, required this.name});

  //TODO might need to dispose BlocProvider.value bloc?

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            'Pair Success',
          ),
          actions: [
            ElevatedButton(
              child: const Text('Return to Home'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildScanButton(BuildContext context) {
    return BlocBuilder<BluetoothBloc, BluetoothState>(
      builder: (context, state) {
        if (state.status.isScanLoading) {
          return FloatingActionButton(
            onPressed: () =>
                context.read<BluetoothBloc>().add(BluetoothScanStopPressed()),
            backgroundColor: Colors.red,
            child: const Icon(Icons.stop),
          );
        }
        return FloatingActionButton(
          onPressed: () =>
              context.read<BluetoothBloc>().add(BluetoothScanStartPressed()),
          child: const Text("SCAN"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices for $name'),
      ),
      body: BlocConsumer<BluetoothBloc, BluetoothState>(
        listener: (context, state) {
          if (state.status.isConnectSuccess) {
            context.read<ChildProfileCubit>().updateDeviceRemoteId(
                name: name, deviceRemoteId: state.newDeviceRemoteId);
            showSuccessDialog(context);
          }
        },
        builder: (context, state) {
          return ListView(children: [
            Text("Discovered devices"),
            ...state.systemDevices
                .map(
                  (d) => SystemDeviceTile(
                    device: d,
                    onConnect: () => context.read<BluetoothBloc>().add(
                          BluetoothConnectPressed(
                              deviceRemoteId: d.remoteId.str),
                        ),
                    onDisconnect: () => context.read<BluetoothBloc>().add(
                          BluetoothDisconnectPressed(
                              deviceRemoteId: d.remoteId.str),
                        ),
                  ),
                )
                .toList(),
            Text("New devices"),
            ...state.scanResults
                .map(
                  (r) => ScanResultTile(
                    result: r,
                    onConnect: () => context.read<BluetoothBloc>().add(
                          BluetoothConnectPressed(
                              deviceRemoteId: r.device.remoteId.str),
                        ),
                    onDisconnect: () => context.read<BluetoothBloc>().add(
                          BluetoothDisconnectPressed(
                              deviceRemoteId: r.device.remoteId.str),
                        ),
                  ),
                )
                .toList(),
          ]);
        },
      ),
      floatingActionButton: buildScanButton(context),
    );
  }
}
