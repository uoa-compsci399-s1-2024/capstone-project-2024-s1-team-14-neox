// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ArduinoDevicesTable extends ArduinoDevices
    with TableInfo<$ArduinoDevicesTable, ArduinoDeviceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArduinoDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceRemoteIdMeta =
      const VerificationMeta('deviceRemoteId');
  @override
  late final GeneratedColumn<String> deviceRemoteId = GeneratedColumn<String>(
      'device_remote_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorisationCodeMeta =
      const VerificationMeta('authorisationCode');
  @override
  late final GeneratedColumn<String> authorisationCode =
      GeneratedColumn<String>('authorisation_code', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [deviceRemoteId, authorisationCode];
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
    if (data.containsKey('device_remote_id')) {
      context.handle(
          _deviceRemoteIdMeta,
          deviceRemoteId.isAcceptableOrUnknown(
              data['device_remote_id']!, _deviceRemoteIdMeta));
    } else if (isInserting) {
      context.missing(_deviceRemoteIdMeta);
    }
    if (data.containsKey('authorisation_code')) {
      context.handle(
          _authorisationCodeMeta,
          authorisationCode.isAcceptableOrUnknown(
              data['authorisation_code']!, _authorisationCodeMeta));
    } else if (isInserting) {
      context.missing(_authorisationCodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ArduinoDeviceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArduinoDeviceEntity(
      deviceRemoteId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}device_remote_id'])!,
      authorisationCode: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}authorisation_code'])!,
    );
  }

  @override
  $ArduinoDevicesTable createAlias(String alias) {
    return $ArduinoDevicesTable(attachedDatabase, alias);
  }
}

class ArduinoDevicesCompanion extends UpdateCompanion<ArduinoDeviceEntity> {
  final Value<String> deviceRemoteId;
  final Value<String> authorisationCode;
  final Value<int> rowid;
  const ArduinoDevicesCompanion({
    this.deviceRemoteId = const Value.absent(),
    this.authorisationCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArduinoDevicesCompanion.insert({
    required String deviceRemoteId,
    required String authorisationCode,
    this.rowid = const Value.absent(),
  })  : deviceRemoteId = Value(deviceRemoteId),
        authorisationCode = Value(authorisationCode);
  static Insertable<ArduinoDeviceEntity> custom({
    Expression<String>? deviceRemoteId,
    Expression<String>? authorisationCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceRemoteId != null) 'device_remote_id': deviceRemoteId,
      if (authorisationCode != null) 'authorisation_code': authorisationCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArduinoDevicesCompanion copyWith(
      {Value<String>? deviceRemoteId,
      Value<String>? authorisationCode,
      Value<int>? rowid}) {
    return ArduinoDevicesCompanion(
      deviceRemoteId: deviceRemoteId ?? this.deviceRemoteId,
      authorisationCode: authorisationCode ?? this.authorisationCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceRemoteId.present) {
      map['device_remote_id'] = Variable<String>(deviceRemoteId.value);
    }
    if (authorisationCode.present) {
      map['authorisation_code'] = Variable<String>(authorisationCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArduinoDevicesCompanion(')
          ..write('deviceRemoteId: $deviceRemoteId, ')
          ..write('authorisationCode: $authorisationCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChildrenTable extends Children
    with TableInfo<$ChildrenTable, ChildEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildrenTable(this.attachedDatabase, [this._alias]);
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
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deviceRemoteIdMeta =
      const VerificationMeta('deviceRemoteId');
  @override
  late final GeneratedColumn<String> deviceRemoteId = GeneratedColumn<String>(
      'device_remote_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES arduino_devices (device_remote_id)'));
  @override
  List<GeneratedColumn> get $columns => [id, name, birthDate, deviceRemoteId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'children';
  @override
  VerificationContext validateIntegrity(Insertable<ChildEntity> instance,
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
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('device_remote_id')) {
      context.handle(
          _deviceRemoteIdMeta,
          deviceRemoteId.isAcceptableOrUnknown(
              data['device_remote_id']!, _deviceRemoteIdMeta));
    } else if (isInserting) {
      context.missing(_deviceRemoteIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChildEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChildEntity(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date'])!,
      deviceRemoteId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}device_remote_id'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
    );
  }

  @override
  $ChildrenTable createAlias(String alias) {
    return $ChildrenTable(attachedDatabase, alias);
  }
}

class ChildrenCompanion extends UpdateCompanion<ChildEntity> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> birthDate;
  final Value<String> deviceRemoteId;
  const ChildrenCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.deviceRemoteId = const Value.absent(),
  });
  ChildrenCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime birthDate,
    required String deviceRemoteId,
  })  : name = Value(name),
        birthDate = Value(birthDate),
        deviceRemoteId = Value(deviceRemoteId);
  static Insertable<ChildEntity> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? birthDate,
    Expression<String>? deviceRemoteId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthDate != null) 'birth_date': birthDate,
      if (deviceRemoteId != null) 'device_remote_id': deviceRemoteId,
    });
  }

  ChildrenCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<DateTime>? birthDate,
      Value<String>? deviceRemoteId}) {
    return ChildrenCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      deviceRemoteId: deviceRemoteId ?? this.deviceRemoteId,
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
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (deviceRemoteId.present) {
      map['device_remote_id'] = Variable<String>(deviceRemoteId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildrenCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('deviceRemoteId: $deviceRemoteId')
          ..write(')'))
        .toString();
  }
}

class $ArduinoDatasTable extends ArduinoDatas
    with TableInfo<$ArduinoDatasTable, ArduinoDataEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArduinoDatasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES children (id)'));
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
  static const VerificationMeta _datetimeMeta =
      const VerificationMeta('datetime');
  @override
  late final GeneratedColumn<DateTime> datetime = GeneratedColumn<DateTime>(
      'datetime', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _accelXMeta = const VerificationMeta('accelX');
  @override
  late final GeneratedColumn<int> accelX = GeneratedColumn<int>(
      'accel_x', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _accelYMeta = const VerificationMeta('accelY');
  @override
  late final GeneratedColumn<int> accelY = GeneratedColumn<int>(
      'accel_y', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _accelZMeta = const VerificationMeta('accelZ');
  @override
  late final GeneratedColumn<int> accelZ = GeneratedColumn<int>(
      'accel_z', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [name, id, uv, light, datetime, accelX, accelY, accelZ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'arduino_datas';
  @override
  VerificationContext validateIntegrity(Insertable<ArduinoDataEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('datetime')) {
      context.handle(_datetimeMeta,
          datetime.isAcceptableOrUnknown(data['datetime']!, _datetimeMeta));
    } else if (isInserting) {
      context.missing(_datetimeMeta);
    }
    if (data.containsKey('accel_x')) {
      context.handle(_accelXMeta,
          accelX.isAcceptableOrUnknown(data['accel_x']!, _accelXMeta));
    } else if (isInserting) {
      context.missing(_accelXMeta);
    }
    if (data.containsKey('accel_y')) {
      context.handle(_accelYMeta,
          accelY.isAcceptableOrUnknown(data['accel_y']!, _accelYMeta));
    } else if (isInserting) {
      context.missing(_accelYMeta);
    }
    if (data.containsKey('accel_z')) {
      context.handle(_accelZMeta,
          accelZ.isAcceptableOrUnknown(data['accel_z']!, _accelZMeta));
    } else if (isInserting) {
      context.missing(_accelZMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ArduinoDataEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArduinoDataEntity(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      uv: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}uv'])!,
      light: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}light'])!,
      datetime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}datetime'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
    );
  }

  @override
  $ArduinoDatasTable createAlias(String alias) {
    return $ArduinoDatasTable(attachedDatabase, alias);
  }
}

class ArduinoDatasCompanion extends UpdateCompanion<ArduinoDataEntity> {
  final Value<String> name;
  final Value<int> id;
  final Value<int> uv;
  final Value<int> light;
  final Value<DateTime> datetime;
  final Value<int> accelX;
  final Value<int> accelY;
  final Value<int> accelZ;
  final Value<int> rowid;
  const ArduinoDatasCompanion({
    this.name = const Value.absent(),
    this.id = const Value.absent(),
    this.uv = const Value.absent(),
    this.light = const Value.absent(),
    this.datetime = const Value.absent(),
    this.accelX = const Value.absent(),
    this.accelY = const Value.absent(),
    this.accelZ = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArduinoDatasCompanion.insert({
    required String name,
    required int id,
    required int uv,
    required int light,
    required DateTime datetime,
    required int accelX,
    required int accelY,
    required int accelZ,
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        id = Value(id),
        uv = Value(uv),
        light = Value(light),
        datetime = Value(datetime),
        accelX = Value(accelX),
        accelY = Value(accelY),
        accelZ = Value(accelZ);
  static Insertable<ArduinoDataEntity> custom({
    Expression<String>? name,
    Expression<int>? id,
    Expression<int>? uv,
    Expression<int>? light,
    Expression<DateTime>? datetime,
    Expression<int>? accelX,
    Expression<int>? accelY,
    Expression<int>? accelZ,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (id != null) 'id': id,
      if (uv != null) 'uv': uv,
      if (light != null) 'light': light,
      if (datetime != null) 'datetime': datetime,
      if (accelX != null) 'accel_x': accelX,
      if (accelY != null) 'accel_y': accelY,
      if (accelZ != null) 'accel_z': accelZ,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArduinoDatasCompanion copyWith(
      {Value<String>? name,
      Value<int>? id,
      Value<int>? uv,
      Value<int>? light,
      Value<DateTime>? datetime,
      Value<int>? accelX,
      Value<int>? accelY,
      Value<int>? accelZ,
      Value<int>? rowid}) {
    return ArduinoDatasCompanion(
      name: name ?? this.name,
      id: id ?? this.id,
      uv: uv ?? this.uv,
      light: light ?? this.light,
      datetime: datetime ?? this.datetime,
      accelX: accelX ?? this.accelX,
      accelY: accelY ?? this.accelY,
      accelZ: accelZ ?? this.accelZ,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uv.present) {
      map['uv'] = Variable<int>(uv.value);
    }
    if (light.present) {
      map['light'] = Variable<int>(light.value);
    }
    if (datetime.present) {
      map['datetime'] = Variable<DateTime>(datetime.value);
    }
    if (accelX.present) {
      map['accel_x'] = Variable<int>(accelX.value);
    }
    if (accelY.present) {
      map['accel_y'] = Variable<int>(accelY.value);
    }
    if (accelZ.present) {
      map['accel_z'] = Variable<int>(accelZ.value);
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
          ..write('id: $id, ')
          ..write('uv: $uv, ')
          ..write('light: $light, ')
          ..write('datetime: $datetime, ')
          ..write('accelX: $accelX, ')
          ..write('accelY: $accelY, ')
          ..write('accelZ: $accelZ, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  late final $ArduinoDevicesTable arduinoDevices = $ArduinoDevicesTable(this);
  late final $ChildrenTable children = $ChildrenTable(this);
  late final $ArduinoDatasTable arduinoDatas = $ArduinoDatasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [arduinoDevices, children, arduinoDatas];
}
