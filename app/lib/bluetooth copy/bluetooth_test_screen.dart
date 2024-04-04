import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'bloc/device_pair_bloc.dart';
import 'device_pair_screen.dart';

class BluetoothSyncScreen extends StatefulWidget {
  const BluetoothSyncScreen({super.key});

  @override
  State<BluetoothSyncScreen> createState() => _BluetoothSyncScreenState();
}



class _BluetoothSyncScreenState extends State<BluetoothSyncScreen> {
 
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Connect with Neox Sens"),
        ),
        body: BlocBuilder<DevicePairBloc, DevicePairState>(
          builder: (context, state) {
            print("DEVICE SYNC SCREEN: ${state.status}");
            if (!state.status.isPaired) {
              return Column(
                children: [
                  const Text("This child does not have a paired device"),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DevicePairScreen()),
                    ),
                    // onPressed: () => context
                    //     .read<DevicePairBloc>()
                    //     .add(DeviceScanStartPressed()),
                    child: const Text("Scan for Neox Sens Devices"),
                  ),
                ],
              );
            }
            return const Text("In Bloc Builder");
          },
        ));
  }
}