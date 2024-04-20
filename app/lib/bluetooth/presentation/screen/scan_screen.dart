import 'package:capstone_project_2024_s1_team_14_neox/child_home/cubit/child_device_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bluetooth_bloc.dart';
import '../tiles/scan_result_tile.dart';

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
        if (state is BluetoothScanLoadingState) {
          return FloatingActionButton(
            onPressed: () => context.read<BluetoothBloc>().add(BluetoothScanStopPressed()),
            backgroundColor: Colors.red,
            child: const Icon(Icons.stop),
          );
        } else if (state is BluetoothConnectLoadingState) {
          return FloatingActionButton(
            onPressed: () => context.read<BluetoothBloc>().add(BluetoothScanStartPressed()),
            child: const CircularProgressIndicator(),
          );
        } else {
          return FloatingActionButton(
            onPressed: () => context.read<BluetoothBloc>().add(BluetoothScanStartPressed()),
            child: const Text("SCAN"),
          );
        }
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
          if (state is BluetoothErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.errorMessage),
              duration: const Duration(seconds: 2),
            ));
          } else if (state is BluetoothConnectSuccessState) {
            context.read<ChildDeviceCubit>().onChildDeviceConnectPressed(state.newDeviceRemoteId);
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          return ListView(children: [
            const Text("Devices:"),
            ...state.scanResults
              .map((r) => ScanResultTile(
                result: r,
                onConnect: () => context.read<BluetoothBloc>().add(BluetoothConnectPressed(deviceRemoteId: r.device.remoteId.str)),
              )),
          ]);
        },
      ),
      floatingActionButton: buildScanButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
