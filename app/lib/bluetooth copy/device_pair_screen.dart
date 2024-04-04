
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/device_pair_bloc.dart';

// import 'widgets/scan_result_tile.dart';

class DevicePairScreen extends StatefulWidget {
  const DevicePairScreen({super.key});

  @override
  State<DevicePairScreen> createState() => _DevicePairScreenState();
}

class _DevicePairScreenState extends State<DevicePairScreen> {
  //   List<Widget> _buildScanResultTiles(BuildContext context) {
  //   return context.sate
  //       .map(
  //         (r) => ScanResultTile(
  //           result: r,
  //           onTap: () => onConnectPressed(r.device),
  //         ),
  //       )
  //       .toList();
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pair with Neox Sens"),
      ),
      body: Column(
        children: [
          BlocBuilder<DevicePairBloc, DevicePairState>(
            builder: (context, state) {
              if (state.status.isScanLoading) {
                return ElevatedButton(
                    onPressed: () => context
                        .read<DevicePairBloc>()
                        .add(DeviceScanStopPressed()),
                    child: const Text("Stop Scanning"));
              } else {
                return ElevatedButton(
                    onPressed: () => context
                        .read<DevicePairBloc>()
                        .add(DeviceScanStartPressed()),
                    child: const Text("Start scanning"));
              }
            },
          ),
          BlocBuilder<DevicePairBloc, DevicePairState>(builder: (context, state){
            return ElevatedButton(onPressed: null, child: Text(state.scanResults.toString()));     })
        ],
      ),
    );
  }
}
