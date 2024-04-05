import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bluetooth_bloc.dart';
import '../tiles/scan_result_tile.dart';
import '../tiles/system_device_tile.dart';

class ScanScreen extends StatelessWidget {
  final String name;
  const ScanScreen({super.key, required this.name});

  //  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
  //   return _systemDevices
  //       .map(
  //         (d) => SystemDeviceTile(
  //           device: d,
  //           onOpen: () => Navigator.of(context).push(
  //             MaterialPageRoute(
  //               builder: (context) => DeviceScreen(device: d),
  //               settings: const RouteSettings(name: '/DeviceScreen'),
  //             ),
  //           ),
  //           onConnect: () => onConnectPressed(d),
  //         ),
  //       )
  //       .toList();
  // }

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
      body: BlocBuilder<BluetoothBloc, BluetoothState>(
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
