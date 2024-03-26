import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io'; // Library used to check platform of device

import '../utils/snackbar.dart';

/*
Screen displayed when Bluetooth is off
*/

class BluetoothOffScreen extends StatelessWidget {
  // Use super parameter: BAD - const BluetoothOffScreen({Key? key, this.adapterState}) : super(key: key);
  const BluetoothOffScreen({super.key, this.adapterState});

  final BluetoothAdapterState? adapterState;

  // Create widgeted for bluetooth off icon
  Widget buildBluetoothOffIcon(BuildContext context) {
    return const Icon(
      Icons.bluetooth_disabled,
      size: 200.0,
      color: Colors.white54,
    );
  }

  Widget buildTitle(BuildContext context) {
    String? state = adapterState?.toString().split(".").last;
    return Text(
      'Bluetooth Adapter is ${state ?? 'not available'}',
      style: Theme.of(context)
          .primaryTextTheme
          .titleSmall
          ?.copyWith(color: Colors.white),
    );
  }

  // Turn of if Androd, use SnackbarBluetooth from snackbar.dart
  Widget buildTurnOnButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: () async {
          try {
            if (Platform.isAndroid) {
              await FlutterBluePlus.turnOn();
            }
          } catch (e) {
            SnackbarBluetooth.show(ABC.a, prettyException("Error Turning On:", e), success: false);
          }
        },
        child: const Text('TURN ON'),
      ),
    );
  }

  // Build the widgets above in children <Widget>[]
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: SnackbarBluetooth.snackBarKeyA,
      child: Scaffold(
        backgroundColor: Colors.lightBlue,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildBluetoothOffIcon(context),
              buildTitle(context),
              if (Platform.isAndroid) buildTurnOnButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
