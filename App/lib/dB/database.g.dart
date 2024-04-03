// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ArduinoDatasTable extends ArduinoDatas
    with TableInfo<$ArduinoDatasTable, ArduinoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArduinoDatasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _uvMeta = const VerificationMeta('uv');
  @override
  late final GeneratedColumn<int> uv = GeneratedColumn<int>(
      'uv', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lightMeta = const VerificationMeta('light');
  @override
  late final GeneratedColumn<int> light = GeneratedColumn<int>(
      'light', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dataTimeMeta =
      const VerificationMeta('dataTime');
  @override
  late final GeneratedColumn<DateTime> dataTime = GeneratedColumn<DateTime>(
      'data_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [name, uv, light, dataTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'arduino_datas';
  @override
  VerificationContext validateIntegrity(Insertable<ArduinoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('uv')) {
      context.handle(_uvMeta, uv.isAcceptableOrUnknown(data['uv']!, _uvMeta));
    } else if (isInserting) {
      context.missing(_uvMeta);
    }
    if (data.containsKey('light')) {
      context.handle(
          _lightMeta, light.isAcceptableOrUnknown(data['light']!, _lightMeta));
    } else if (isInserting) {
      context.missing(_lightMeta);
    }
    if (data.containsKey('data_time')) {
      context.handle(_dataTimeMeta,
          dataTime.isAcceptableOrUnknown(data['data_time']!, _dataTimeMeta));
    } else if (isInserting) {
      context.missing(_dataTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ArduinoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArduinoData(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      uv: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}uv'])!,
      light: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}light'])!,
      dataTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}data_time'])!,
    );
  }

  @override
  $ArduinoDatasTable createAlias(String alias) {
    return $ArduinoDatasTable(attachedDatabase, alias);
  }
}

class ArduinoData extends DataClass implements Insertable<ArduinoData> {
  final String name;
  final int uv;
  final int light;
  final DateTime dataTime;
  const ArduinoData(
      {required this.name,
      required this.uv,
      required this.light,
      required this.dataTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['uv'] = Variable<int>(uv);
    map['light'] = Variable<int>(light);
    map['data_time'] = Variable<DateTime>(dataTime);
    return map;
  }

  ArduinoDatasCompanion toCompanion(bool nullToAbsent) {
    return ArduinoDatasCompanion(
      name: Value(name),
      uv: Value(uv),
      light: Value(light),
      dataTime: Value(dataTime),
    );
  }

  factory ArduinoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArduinoData(
      name: serializer.fromJson<String>(json['name']),
      uv: serializer.fromJson<int>(json['uv']),
      light: serializer.fromJson<int>(json['light']),
      dataTime: serializer.fromJson<DateTime>(json['dataTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'uv': serializer.toJson<int>(uv),
      'light': serializer.toJson<int>(light),
      'dataTime': serializer.toJson<DateTime>(dataTime),
    };
  }

  ArduinoData copyWith(
          {String? name, int? uv, int? light, DateTime? dataTime}) =>
      ArduinoData(
        name: name ?? this.name,
        uv: uv ?? this.uv,
        light: light ?? this.light,
        dataTime: dataTime ?? this.dataTime,
      );
  @override
  String toString() {
    return (StringBuffer('ArduinoData(')
          ..write('name: $name, ')
          ..write('uv: $uv, ')
          ..write('light: $light, ')
          ..write('dataTime: $dataTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, uv, light, dataTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArduinoData &&
          other.name == this.name &&
          other.uv == this.uv &&
          other.light == this.light &&
          other.dataTime == this.dataTime);
}

class ArduinoDatasCompanion extends UpdateCompanion<ArduinoData> {
  final Value<String> name;
  final Value<int> uv;
  final Value<int> light;
  final Value<DateTime> dataTime;
  final Value<int> rowid;
  const ArduinoDatasCompanion({
    this.name = const Value.absent(),
    this.uv = const Value.absent(),
    this.light = const Value.absent(),
    this.dataTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArduinoDatasCompanion.insert({
    required String name,
    required int uv,
    required int light,
    required DateTime dataTime,
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        uv = Value(uv),
        light = Value(light),
        dataTime = Value(dataTime);
  static Insertable<ArduinoData> custom({
    Expression<String>? name,
    Expression<int>? uv,
    Expression<int>? light,
    Expression<DateTime>? dataTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (uv != null) 'uv': uv,
      if (light != null) 'light': light,
      if (dataTime != null) 'data_time': dataTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArduinoDatasCompanion copyWith(
      {Value<String>? name,
      Value<int>? uv,
      Value<int>? light,
      Value<DateTime>? dataTime,
      Value<int>? rowid}) {
    return ArduinoDatasCompanion(
      name: name ?? this.name,
      uv: uv ?? this.uv,
      light: light ?? this.light,
      dataTime: dataTime ?? this.dataTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (uv.present) {
      map['uv'] = Variable<int>(uv.value);
    }
    if (light.present) {
      map['light'] = Variable<int>(light.value);
    }
    if (dataTime.present) {
      map['data_time'] = Variable<DateTime>(dataTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArduinoDatasCompanion(')
          ..write('name: $name, ')
          ..write('uv: $uv, ')
          ..write('light: $light, ')
          ..write('dataTime: $dataTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArduinoDevicesTable extends ArduinoDevices
    with TableInfo<$ArduinoDevicesTable, ArduinoDeviceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArduinoDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gattMeta = const VerificationMeta('gatt');
  @override
  late final GeneratedColumn<String> gatt = GeneratedColumn<String>(
      'gatt', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [uuid, gatt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'arduino_devices';
  @override
  VerificationContext validateIntegrity(
      Insertable<ArduinoDeviceEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('gatt')) {
      context.handle(
          _gattMeta, gatt.isAcceptableOrUnknown(data['gatt']!, _gattMeta));
    } else if (isInserting) {
      context.missing(_gattMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ArduinoDeviceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArduinoDeviceEntity(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      gatt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gatt'])!,
    );
  }

  @override
  $ArduinoDevicesTable createAlias(String alias) {
    return $ArduinoDevicesTable(attachedDatabase, alias);
  }
}

class ArduinoDevicesCompanion extends UpdateCompanion<ArduinoDeviceEntity> {
  final Value<String> uuid;
  final Value<String> gatt;
  final Value<int> rowid;
  const ArduinoDevicesCompanion({
    this.uuid = const Value.absent(),
    this.gatt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArduinoDevicesCompanion.insert({
    required String uuid,
    required String gatt,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        gatt = Value(gatt);
  static Insertable<ArduinoDeviceEntity> custom({
    Expression<String>? uuid,
    Expression<String>? gatt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (gatt != null) 'gatt': gatt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArduinoDevicesCompanion copyWith(
      {Value<String>? uuid, Value<String>? gatt, Value<int>? rowid}) {
    return ArduinoDevicesCompanion(
      uuid: uuid ?? this.uuid,
      gatt: gatt ?? this.gatt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (gatt.present) {
      map['gatt'] = Variable<String>(gatt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArduinoDevicesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('gatt: $gatt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChildModelsTable extends ChildModels
    with TableInfo<$ChildModelsTable, ChildModelEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES arduino_datas (name)'));
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES arduino_devices (uuid)'));
  @override
  List<GeneratedColumn> get $columns => [id, name, age, uuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'child_models';
  @override
  VerificationContext validateIntegrity(Insertable<ChildModelEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChildModelEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChildModelEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
    );
  }

  @override
  $ChildModelsTable createAlias(String alias) {
    return $ChildModelsTable(attachedDatabase, alias);
  }
}

class ChildModelsCompanion extends UpdateCompanion<ChildModelEntity> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> age;
  final Value<String> uuid;
  const ChildModelsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.uuid = const Value.absent(),
  });
  ChildModelsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int age,
    required String uuid,
  })  : name = Value(name),
        age = Value(age),
        uuid = Value(uuid);
  static Insertable<ChildModelEntity> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? age,
    Expression<String>? uuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (uuid != null) 'uuid': uuid,
    });
  }

  ChildModelsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? age,
      Value<String>? uuid}) {
    return ChildModelsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      uuid: uuid ?? this.uuid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildModelsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  late final $ArduinoDatasTable arduinoDatas = $ArduinoDatasTable(this);
  late final $ArduinoDevicesTable arduinoDevices = $ArduinoDevicesTable(this);
  late final $ChildModelsTable childModels = $ChildModelsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [arduinoDatas, arduinoDevices, childModels];
}
