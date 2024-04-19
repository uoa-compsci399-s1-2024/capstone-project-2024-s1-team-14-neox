import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../child_home/cubit/all_child_profile_cubit.dart';
import '../../child_home/cubit/child_device_cubit.dart';
import '../bloc/bluetooth_bloc.dart';
import 'screen/scan_screen.dart';

class BluetoothPanel extends StatelessWidget {
  const BluetoothPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BluetoothBloc, BluetoothState>(
      listener: (context, state) {
        if (state.status.isConnectSuccess) {
          // TODO: Change repository function to update remote ID
          // TODO: may need to change the chain of updating deviceRemoteID, currently calling two functions
          context.read<AllChildProfileCubit>().updateDeviceRemoteId(
              childId: context.read<ChildDeviceCubit>().state.childId,
              deviceRemoteId: state.newDeviceRemoteId);

          context
              .read<ChildDeviceCubit>()
              .onChildDevicePairSuccess(state.newDeviceRemoteId);
        }
      },
      child: BlocBuilder<ChildDeviceCubit, ChildDeviceState>(
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
                          child: ScanScreen(
                              name: context
                                  .read<ChildDeviceCubit>()
                                  .state
                                  .childName),
                        );
                      }),
                    );
                  },
                  child: const Text("Pair device"),
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     print(context.read<AllChildProfileCubit>().state.profiles);
                //   },
                //   child: Text("Test"),
                // )
              ],
            );
          }
          return Column(
            children: [
              ElevatedButton(
                onPressed: () =>
                    context.read<BluetoothBloc>().add(BluetoothSyncPressed(
                          childName: state.childName,
                          deviceRemoteId: state.deviceRemoteId ?? "",
                          childId: state.childId,
                        )),
                child: Text("Sync device"),
              ),
              ElevatedButton(
                // Unpair means to remove deviceRemoteId from child repository
                onPressed: () {
                  // Disconnect bluetooth
                  context.read<BluetoothBloc>().add(BluetoothDisconnectPressed(
                      deviceRemoteId: state.deviceRemoteId ?? ""));
                  context.read<ChildDeviceCubit>().onChildDeviceUnpairSuccess();
                  // Update in child repository
                  context.read<AllChildProfileCubit>().deleteDeviceRemoteId(
                      childId: context.read<ChildDeviceCubit>().state.childId);
                },
                child: Text("Unpair device"),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     print(context.read<AllChildProfileCubit>().state.profiles);
              //   },
              //   child: Text("Test"),
              // )
            ],
          );
        },
      ),
    );
  }
}
