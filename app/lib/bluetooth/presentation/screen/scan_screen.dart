import 'package:capstone_project_2024_s1_team_14_neox/child_home/cubit/child_device_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bluetooth_bloc.dart';
import '../tiles/scan_result_tile.dart';

class ScanScreen extends StatelessWidget {
  final String name;
  ScanScreen({super.key, required this.name});
  
  final TextEditingController _textFieldController = TextEditingController();

  Future<void> _showAuthInputDialog(BuildContext context, { required void Function(String) action }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter 10-digit authentication code'),
              Text(
                'See the device manual for the code.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Authentication Code"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ValueListenableBuilder(valueListenable: _textFieldController, builder: (context, value, child) {
              if (value.text.trim().length != 10) {
                return const ElevatedButton(
                  onPressed: null,
                  child: Text('OK'),
                );
              }
              return ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  action(_textFieldController.text.trim());
                  Navigator.pop(context);
                },
              );
            }),
          ],
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
          if (state is BluetoothErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.errorMessage),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.grey,
            ));
          } else if (state is BluetoothConnectSuccessState) {
            context.read<ChildDeviceCubit>().onChildDeviceConnectPressed(
              state.newDeviceRemoteId,
              state.newAuthorisationCode,
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          if (state.scanResults.isEmpty) {
            return Center(
              child: Text(
                'No devices found',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            );
          }

          return ListView(children: [
            ...state.scanResults
              .map((r) => ScanResultTile(
                result: r,
                onConnect: () => _showAuthInputDialog(
                  context,
                  action: (authCode) {
                    context.read<BluetoothBloc>().add(BluetoothAuthCodeEntered(
                      deviceRemoteId: _formatRemoteDeviceId(r.advertisementData.manufacturerData.values.firstOrNull ?? []),
                      authorisationCode: authCode,
                    ));
                  },
                )
              )),
          ]);
        },
      ),
    );
  }

  static String _formatRemoteDeviceId(List<int> bytes) {
    return bytes.map((e) => e.toRadixString(16).toUpperCase().padLeft(2, '0')).join(':');
  }
}
