import 'dart:typed_data';

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
  Future<void> _generateLargeData(int childId) async {
    var startTime = DateTime(2023, 1, 1);
    var endTime = DateTime.now();
    int numberOfWeeks = endTime.difference(startTime).inDays ~/ 7;
    // 0.1 is around 96 mins per day, 0.2 is around 192 mins per day, recommend 0.13
    double threshold = 0.13;
    DateTime time = startTime;
    // For loop to prevent exceeding memory
    for (int i = 0; i <= numberOfWeeks; i++) {
      time = time.add(const Duration(days: 7));
      time = DateTime(time.year, time.month, time.day);
      print("Creating week for: $time");
      List<ArduinoDataEntity> randomData =
          await ArduinoDataEntity.createSampleArduinoDataList(
              childId, time, time.add(const Duration(days: 7)), threshold);
      await ArduinoDataEntity.saveListOfArduinoDataEntity(randomData);
    }
  }

  Future<void> _generateSmallData(int childId) async {
    double threshold = 0.13;
    DateTime time = DateTime.now().subtract(const Duration(days: 5));

    time = time.add(const Duration(days: 2));
    time = DateTime(time.year, time.month, time.day);
    print("Creating small data for: $time");
    List<ArduinoDataEntity> randomData =
        await ArduinoDataEntity.createSampleArduinoDataList(
            childId, time, time.add(const Duration(days: 1)), threshold);
    await ArduinoDataEntity.saveListOfArduinoDataEntity(randomData);
  }

  Future<void> _generateTenData(int childId) async {
    double threshold = 0.13;
    DateTime time = DateTime(2024, 05, 06);

    List<ArduinoDataEntity> randomData = [];
    int num = 100;
    for (int i = 0; i < 10; i++) {
      num += 1;
      randomData.add(
        ArduinoDataEntity(
          uv: num,
          light: num,
          datetime: time.add(Duration(days: 1)).add(Duration(hours:i)),
          accel: Int16List.fromList([num, num, num]),
          serverSynced: 0,
          appClass: 0, // Generates either 0 or 1 randomly
          childId: childId,
        ),
      );
    }

    print(randomData.length);
    print("Creating Ten data for: $time");
    await ArduinoDataEntity.saveListOfArduinoDataEntity(randomData);
  }

  @override
  Widget build(BuildContext context) {
    ChildDeviceState state = context.read<ChildDeviceCubit>().state;

    int outdoorTimeToday = state.outdoorTimeToday;
    int outdoorTimeAvgWeek = state.outdoorTimeWeek;
    int outdoorTimeAvgMonth = state.outdoorTimeMonth;
    int target = App.sharedPreferences.getInt("daily_target")!;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return BlocProvider.value(
                              value: BlocProvider.of<AllChildProfileCubit>(
                                  context),
                              child: BlocProvider.value(
                                value:
                                    BlocProvider.of<ChildDeviceCubit>(context),
                                child: const CreateChildProfileScreen(
                                    editing: true),
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
                // ElevatedButton(
                //   onPressed: () => _generateLargeData(state.childId),
                //   child: const Text("Generate large data"),
                // ),
              if (kDebugMode)
                // ElevatedButton(
                //   onPressed: () => _generateSmallData(state.childId),
                //   child: const Text("Generate small data"),
                // ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Column(
                      children: [
                        const Spacer(),
                        OutdoorTimeProgressIndicator(
                          context: context,
                          radius: constraints.maxWidth / 2 * 0.8,
                          lineWidth: 18,
                          percent: (outdoorTimeToday / target).clamp(0, 1),
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Today",
                                style: TextStyle(fontSize: 30),
                              ),
                              Text(
                                  "$outdoorTimeToday/$target ${outdoorTimeToday == 1 ? "min" : "mins"} outdoors"),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutdoorTimeProgressIndicator(
                              context: context,
                              radius: constraints.maxWidth / 4 * 0.8,
                              lineWidth: 10,
                              percent:
                                  (outdoorTimeAvgWeek / target).clamp(0, 1),
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Past week",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    "$outdoorTimeAvgWeek ${outdoorTimeAvgWeek == 1 ? "min" : "mins"}/day",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            OutdoorTimeProgressIndicator(
                              context: context,
                              radius: constraints.maxWidth / 4 * 0.8,
                              lineWidth: 10,
                              percent:
                                  (outdoorTimeAvgMonth / target).clamp(0, 1),
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Past month",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    "$outdoorTimeAvgMonth ${outdoorTimeAvgMonth == 1 ? "min" : "mins"}/day",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
          progressColor: percent >= 1
              ? const Color.fromARGB(255, 255, 204, 36)
              : Theme.of(context).primaryColor,
        );
}
