import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../child_home/cubit/all_child_profile_cubit.dart';
import '../../child_home/cubit/child_device_cubit.dart';
import '../bloc/bluetooth_bloc.dart';
import 'screen/scan_screen.dart';

class BluetoothPanel extends StatelessWidget {
  const BluetoothPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChildDeviceCubit, ChildDeviceState>(
      listener: (context, state) {
        if (state is ChildDeviceConnectState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Paired device'),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ));
          context.read<AllChildProfileCubit>().updateDeviceRemoteId(
              childId: state.childId, deviceRemoteId: state.deviceRemoteId);
          context.read<AllChildProfileCubit>().updateAuthorisationCode(
              childId: state.childId,
              authorisationCode: state.authorisationCode);
        } else if (state is ChildDeviceErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.grey,
          ));
        } else if (state is ChildDeviceSyncSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Sync complete | ${state.message}"),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ));
        }

        if (state is ChildDeviceSyncingState) {
          context.loaderOverlay.show();
          context.loaderOverlay.progress(state.progress);
        } else {
          context.loaderOverlay.hide();
        }
      },
      child: BlocBuilder<ChildDeviceCubit, ChildDeviceState>(
        builder: (context, state) {
          if (state is ChildDeviceLoadingState) {
            return const CircularProgressIndicator();
          }

          if (state.deviceRemoteId.isEmpty) {
            return ElevatedButton(
              onPressed: () {
                // Automatically begin scanning
                BlocProvider.of<BluetoothBloc>(context)
                    .add(BluetoothScanStarted());

                Navigator.push(
                  context,
                  // Must use _ for context in builder, otherwise wrong context is looked up
                  MaterialPageRoute(builder: (_) {
                    return BlocProvider.value(
                      value: BlocProvider.of<ChildDeviceCubit>(context),
                      child: BlocProvider.value(
                        value: BlocProvider.of<BluetoothBloc>(context),
                        child: ScanScreen(name: state.childName),
                      ),
                    );
                  }),
                );
              },
              child: const Text("Pair device"),
            );
          }

          return ElevatedButton(
            onPressed: () {
              // context.read<ChildDeviceCubit>()._generateDefinedData(state.childId, DateTime(2024,05,14), DateTime.now()),
              Future(() => context.read<ChildDeviceCubit>().onSyncPressed(
                    childName: state.childName,
                    childId: state.childId,
                    deviceRemoteId: state.deviceRemoteId,
                    authorisationCode: state.authorisationCode,
                  )).then((value) {
                debugPrint("Bluetooth Panel Refreshing page");
                context.read<AllChildProfileCubit>().fetchChildProfiles();
              });
            },
            child: const Text("Sync device"),
          );
        },
      ),
    );
  }
}
