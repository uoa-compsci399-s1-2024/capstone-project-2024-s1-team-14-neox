
import 'dart:collection';

import 'package:drift/drift.dart';

//@UseRowClass(ArduinoDataEntity)
class ArduinoDatas extends Table {
  TextColumn get name => text()();
  IntColumn get uv => integer()();
  IntColumn get light => integer()();
  DateTimeColumn get dataTime => dateTime()();
}


