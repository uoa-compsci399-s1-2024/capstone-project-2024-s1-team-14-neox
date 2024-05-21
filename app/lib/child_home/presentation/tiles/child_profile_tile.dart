import 'package:capstone_project_2024_s1_team_14_neox/child_home/presentation/screens/create_child_profile_screen.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/arduino_data_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/main.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../bluetooth/bloc/bluetooth_bloc.dart';
import '../../../bluetooth/presentation/bluetooth_panel.dart';
import '../../cubit/all_child_profile_cubit.dart';
import '../../cubit/child_device_cubit.dart';

class ChildProfileTile extends StatefulWidget {
  const ChildProfileTile({super.key});

  @override
  State<ChildProfileTile> createState() => _ChildProfileTileState();
}

class _ChildProfileTileState extends State<ChildProfileTile> {
  @override
  Widget build(BuildContext context) {
    ChildDeviceState state = context.read<ChildDeviceCubit>().state;

    int outdoorTimeToday = state.outdoorTimeToday;
    int outdoorTimeAvgWeek = state.outdoorTimeWeek;
    int outdoorTimeAvgMonth = state.outdoorTimeMonth;
    int target = App.sharedPreferences.getInt("daily_target")!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dummy invisible widget to balance out icon on the right.
              // This ensures that the text widget is perfectly centred.
              const Visibility(
                maintainSize: true, 
                maintainAnimation: true,
                maintainState: true,
                visible: false,
                child: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.edit),
                ),
              ),

              Flexible(
                child: Text(
                  state.childName,
                  style: const TextStyle(fontSize: 40),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 10),

              IconButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return BlocProvider.value(
                          value: BlocProvider.of<AllChildProfileCubit>(context),
                          child: BlocProvider.value(
                            value: BlocProvider.of<ChildDeviceCubit>(context),
                            child: const CreateChildProfileScreen(editing: true),
                          ),
                        );
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          BlocProvider(
            create: (_) => BluetoothBloc(),
            child: const BluetoothPanel(),
          ),
          
          if (kDebugMode)
            ElevatedButton(
              onPressed: () async {
                List<ArduinoDataEntity> randomData = await ArduinoDataEntity.createSampleArduinoDataList(
                  state.childId,
                  DateTime.now(),
                  30
                );
                await ArduinoDataEntity.saveListOfArduinoDataEntity(randomData);
              },
              child: const Text("Generate data"),
            ),

          const Spacer(),
          
          OutdoorTimeProgressIndicator(
            context: context,
            radius: 180,
            lineWidth: 18,
            percent: (outdoorTimeToday / target).clamp(0, 1),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Today",
                  style: TextStyle(fontSize: 30),
                ),
                Text("$outdoorTimeToday / $target minutes outdoors"),
              ],
            ),
          ),
          
          const Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutdoorTimeProgressIndicator(
                context: context,
                radius: 90,
                lineWidth: 10,
                percent: (outdoorTimeAvgWeek / target).clamp(0, 1),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Past week",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text("$outdoorTimeAvgWeek mins/day"),
                  ],
                ),
              ),
              OutdoorTimeProgressIndicator(
                context: context,
                radius: 90,
                lineWidth: 10,
                percent: (outdoorTimeAvgMonth / target).clamp(0, 1),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Past month",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text("$outdoorTimeAvgMonth mins/day"),
                  ],
                ),
              ),
            ],
          ),
          
          const Spacer(),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class OutdoorTimeProgressIndicator extends CircularPercentIndicator {
  OutdoorTimeProgressIndicator({
    super.key, 
    required BuildContext context,
    required super.radius,
    required super.lineWidth,
    required super.percent,
    required super.center,
  }) : super(
    animation: true,
    arcType: ArcType.FULL,
    arcBackgroundColor: Colors.grey.withOpacity(0.3),
    circularStrokeCap: CircularStrokeCap.round,
    progressColor: percent >= 1 ? const Color.fromARGB(255, 255, 204, 36) : Theme.of(context).primaryColor,
  );
}