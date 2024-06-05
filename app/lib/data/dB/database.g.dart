// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
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
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorisationCodeMeta =
      const VerificationMeta('authorisationCode');
  @override
  late final GeneratedColumn<String> authorisationCode =
      GeneratedColumn<String>('authorisation_code', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        name,
        birthDate,
        deviceRemoteId,
        authorisationCode,
        gender
      ];
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
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    } else if (isInserting) {
      context.missing(_serverIdMeta);
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
    if (data.containsKey('authorisation_code')) {
      context.handle(
          _authorisationCodeMeta,
          authorisationCode.isAcceptableOrUnknown(
              data['authorisation_code']!, _authorisationCodeMeta));
    } else if (isInserting) {
      context.missing(_authorisationCodeMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    } else if (isInserting) {
      context.missing(_genderMeta);
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
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date'])!,
      deviceRemoteId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}device_remote_id'])!,
      authorisationCode: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}authorisation_code'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id'])!,
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
  final Value<String> serverId;
  final Value<String> name;
  final Value<DateTime> birthDate;
  final Value<String> deviceRemoteId;
  final Value<String> authorisationCode;
  final Value<String> gender;
  const ChildrenCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.deviceRemoteId = const Value.absent(),
    this.authorisationCode = const Value.absent(),
    this.gender = const Value.absent(),
  });
  ChildrenCompanion.insert({
    this.id = const Value.absent(),
    required String serverId,
    required String name,
    required DateTime birthDate,
    required String deviceRemoteId,
    required String authorisationCode,
    required String gender,
  })  : serverId = Value(serverId),
        name = Value(name),
        birthDate = Value(birthDate),
        deviceRemoteId = Value(deviceRemoteId),
        authorisationCode = Value(authorisationCode),
        gender = Value(gender);
  static Insertable<ChildEntity> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? name,
    Expression<DateTime>? birthDate,
    Expression<String>? deviceRemoteId,
    Expression<String>? authorisationCode,
    Expression<String>? gender,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (birthDate != null) 'birth_date': birthDate,
      if (deviceRemoteId != null) 'device_remote_id': deviceRemoteId,
      if (authorisationCode != null) 'authorisation_code': authorisationCode,
      if (gender != null) 'gender': gender,
    });
  }

  ChildrenCompanion copyWith(
      {Value<int>? id,
      Value<String>? serverId,
      Value<String>? name,
      Value<DateTime>? birthDate,
      Value<String>? deviceRemoteId,
      Value<String>? authorisationCode,
      Value<String>? gender}) {
    return ChildrenCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      deviceRemoteId: deviceRemoteId ?? this.deviceRemoteId,
      authorisationCode: authorisationCode ?? this.authorisationCode,
      gender: gender ?? this.gender,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
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
    if (authorisationCode.present) {
      map['authorisation_code'] = Variable<String>(authorisationCode.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildrenCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('deviceRemoteId: $deviceRemoteId, ')
          ..write('authorisationCode: $authorisationCode, ')
          ..write('gender: $gender')
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
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
      'child_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES children(id) ON DELETE CASCADE');
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
  static const VerificationMeta _serverSyncedMeta =
      const VerificationMeta('serverSynced');
  @override
  late final GeneratedColumn<int> serverSynced = GeneratedColumn<int>(
      'server_synced', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _appClassMeta =
      const VerificationMeta('appClass');
  @override
  late final GeneratedColumn<int> appClass = GeneratedColumn<int>(
      'app_class', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _redMeta = const VerificationMeta('red');
  @override
  late final GeneratedColumn<int> red = GeneratedColumn<int>(
      'red', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _greenMeta = const VerificationMeta('green');
  @override
  late final GeneratedColumn<int> green = GeneratedColumn<int>(
      'green', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _blueMeta = const VerificationMeta('blue');
  @override
  late final GeneratedColumn<int> blue = GeneratedColumn<int>(
      'blue', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _clearMeta = const VerificationMeta('clear');
  @override
  late final GeneratedColumn<int> clear = GeneratedColumn<int>(
      'clear', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _colourTemperatureMeta =
      const VerificationMeta('colourTemperature');
  @override
  late final GeneratedColumn<int> colourTemperature = GeneratedColumn<int>(
      'colour_temperature', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        childId,
        uv,
        light,
        datetime,
        accelX,
        accelY,
        accelZ,
        serverSynced,
        appClass,
        red,
        green,
        blue,
        clear,
        colourTemperature
      ];
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
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
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
    if (data.containsKey('server_synced')) {
      context.handle(
          _serverSyncedMeta,
          serverSynced.isAcceptableOrUnknown(
              data['server_synced']!, _serverSyncedMeta));
    } else if (isInserting) {
      context.missing(_serverSyncedMeta);
    }
    if (data.containsKey('app_class')) {
      context.handle(_appClassMeta,
          appClass.isAcceptableOrUnknown(data['app_class']!, _appClassMeta));
    } else if (isInserting) {
      context.missing(_appClassMeta);
    }
    if (data.containsKey('red')) {
      context.handle(
          _redMeta, red.isAcceptableOrUnknown(data['red']!, _redMeta));
    } else if (isInserting) {
      context.missing(_redMeta);
    }
    if (data.containsKey('green')) {
      context.handle(
          _greenMeta, green.isAcceptableOrUnknown(data['green']!, _greenMeta));
    } else if (isInserting) {
      context.missing(_greenMeta);
    }
    if (data.containsKey('blue')) {
      context.handle(
          _blueMeta, blue.isAcceptableOrUnknown(data['blue']!, _blueMeta));
    } else if (isInserting) {
      context.missing(_blueMeta);
    }
    if (data.containsKey('clear')) {
      context.handle(
          _clearMeta, clear.isAcceptableOrUnknown(data['clear']!, _clearMeta));
    } else if (isInserting) {
      context.missing(_clearMeta);
    }
    if (data.containsKey('colour_temperature')) {
      context.handle(
          _colourTemperatureMeta,
          colourTemperature.isAcceptableOrUnknown(
              data['colour_temperature']!, _colourTemperatureMeta));
    } else if (isInserting) {
      context.missing(_colourTemperatureMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId, datetime};
  @override
  ArduinoDataEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArduinoDataEntity(
      uv: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}uv'])!,
      light: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}light'])!,
      datetime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}datetime'])!,
      appClass: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}app_class'])!,
      serverSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_synced'])!,
      green: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}green'])!,
      blue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}blue'])!,
      red: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}red'])!,
      clear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}clear'])!,
      colourTemperature: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}colour_temperature'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}child_id'])!,
    );
  }

  @override
  $ArduinoDatasTable createAlias(String alias) {
    return $ArduinoDatasTable(attachedDatabase, alias);
  }
}

class ArduinoDatasCompanion extends UpdateCompanion<ArduinoDataEntity> {
  final Value<int> childId;
  final Value<int> uv;
  final Value<int> light;
  final Value<DateTime> datetime;
  final Value<int> accelX;
  final Value<int> accelY;
  final Value<int> accelZ;
  final Value<int> serverSynced;
  final Value<int> appClass;
  final Value<int> red;
  final Value<int> green;
  final Value<int> blue;
  final Value<int> clear;
  final Value<int> colourTemperature;
  final Value<int> rowid;
  const ArduinoDatasCompanion({
    this.childId = const Value.absent(),
    this.uv = const Value.absent(),
    this.light = const Value.absent(),
    this.datetime = const Value.absent(),
    this.accelX = const Value.absent(),
    this.accelY = const Value.absent(),
    this.accelZ = const Value.absent(),
    this.serverSynced = const Value.absent(),
    this.appClass = const Value.absent(),
    this.red = const Value.absent(),
    this.green = const Value.absent(),
    this.blue = const Value.absent(),
    this.clear = const Value.absent(),
    this.colourTemperature = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArduinoDatasCompanion.insert({
    required int childId,
    required int uv,
    required int light,
    required DateTime datetime,
    required int accelX,
    required int accelY,
    required int accelZ,
    required int serverSynced,
    required int appClass,
    required int red,
    required int green,
    required int blue,
    required int clear,
    required int colourTemperature,
    this.rowid = const Value.absent(),
  })  : childId = Value(childId),
        uv = Value(uv),
        light = Value(light),
        datetime = Value(datetime),
        accelX = Value(accelX),
        accelY = Value(accelY),
        accelZ = Value(accelZ),
        serverSynced = Value(serverSynced),
        appClass = Value(appClass),
        red = Value(red),
        green = Value(green),
        blue = Value(blue),
        clear = Value(clear),
        colourTemperature = Value(colourTemperature);
  static Insertable<ArduinoDataEntity> custom({
    Expression<int>? childId,
    Expression<int>? uv,
    Expression<int>? light,
    Expression<DateTime>? datetime,
    Expression<int>? accelX,
    Expression<int>? accelY,
    Expression<int>? accelZ,
    Expression<int>? serverSynced,
    Expression<int>? appClass,
    Expression<int>? red,
    Expression<int>? green,
    Expression<int>? blue,
    Expression<int>? clear,
    Expression<int>? colourTemperature,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (uv != null) 'uv': uv,
      if (light != null) 'light': light,
      if (datetime != null) 'datetime': datetime,
      if (accelX != null) 'accel_x': accelX,
      if (accelY != null) 'accel_y': accelY,
      if (accelZ != null) 'accel_z': accelZ,
      if (serverSynced != null) 'server_synced': serverSynced,
      if (appClass != null) 'app_class': appClass,
      if (red != null) 'red': red,
      if (green != null) 'green': green,
      if (blue != null) 'blue': blue,
      if (clear != null) 'clear': clear,
      if (colourTemperature != null) 'colour_temperature': colourTemperature,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArduinoDatasCompanion copyWith(
      {Value<int>? childId,
      Value<int>? uv,
      Value<int>? light,
      Value<DateTime>? datetime,
      Value<int>? accelX,
      Value<int>? accelY,
      Value<int>? accelZ,
      Value<int>? serverSynced,
      Value<int>? appClass,
      Value<int>? red,
      Value<int>? green,
      Value<int>? blue,
      Value<int>? clear,
      Value<int>? colourTemperature,
      Value<int>? rowid}) {
    return ArduinoDatasCompanion(
      childId: childId ?? this.childId,
      uv: uv ?? this.uv,
      light: light ?? this.light,
      datetime: datetime ?? this.datetime,
      accelX: accelX ?? this.accelX,
      accelY: accelY ?? this.accelY,
      accelZ: accelZ ?? this.accelZ,
      serverSynced: serverSynced ?? this.serverSynced,
      appClass: appClass ?? this.appClass,
      red: red ?? this.red,
      green: green ?? this.green,
      blue: blue ?? this.blue,
      clear: clear ?? this.clear,
      colourTemperature: colourTemperature ?? this.colourTemperature,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
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
    if (serverSynced.present) {
      map['server_synced'] = Variable<int>(serverSynced.value);
    }
    if (appClass.present) {
      map['app_class'] = Variable<int>(appClass.value);
    }
    if (red.present) {
      map['red'] = Variable<int>(red.value);
    }
    if (green.present) {
      map['green'] = Variable<int>(green.value);
    }
    if (blue.present) {
      map['blue'] = Variable<int>(blue.value);
    }
    if (clear.present) {
      map['clear'] = Variable<int>(clear.value);
    }
    if (colourTemperature.present) {
      map['colour_temperature'] = Variable<int>(colourTemperature.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArduinoDatasCompanion(')
          ..write('childId: $childId, ')
          ..write('uv: $uv, ')
          ..write('light: $light, ')
          ..write('datetime: $datetime, ')
          ..write('accelX: $accelX, ')
          ..write('accelY: $accelY, ')
          ..write('accelZ: $accelZ, ')
          ..write('serverSynced: $serverSynced, ')
          ..write('appClass: $appClass, ')
          ..write('red: $red, ')
          ..write('green: $green, ')
          ..write('blue: $blue, ')
          ..write('clear: $clear, ')
          ..write('colourTemperature: $colourTemperature, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyTable extends Study with TableInfo<$StudyTable, StudyEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _studyCodeMeta =
      const VerificationMeta('studyCode');
  @override
  late final GeneratedColumn<String> studyCode = GeneratedColumn<String>(
      'study_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, studyCode, name, description, startDate, endDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study';
  @override
  VerificationContext validateIntegrity(Insertable<StudyEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('study_code')) {
      context.handle(_studyCodeMeta,
          studyCode.isAcceptableOrUnknown(data['study_code']!, _studyCodeMeta));
    } else if (isInserting) {
      context.missing(_studyCodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudyEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      studyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}study_code'])!,
    );
  }

  @override
  $StudyTable createAlias(String alias) {
    return $StudyTable(attachedDatabase, alias);
  }
}

class StudyCompanion extends UpdateCompanion<StudyEntity> {
  final Value<int> id;
  final Value<String> studyCode;
  final Value<String> name;
  final Value<String> description;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  const StudyCompanion({
    this.id = const Value.absent(),
    this.studyCode = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
  });
  StudyCompanion.insert({
    this.id = const Value.absent(),
    required String studyCode,
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  })  : studyCode = Value(studyCode),
        name = Value(name),
        description = Value(description),
        startDate = Value(startDate),
        endDate = Value(endDate);
  static Insertable<StudyEntity> custom({
    Expression<int>? id,
    Expression<String>? studyCode,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studyCode != null) 'study_code': studyCode,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
  }

  StudyCompanion copyWith(
      {Value<int>? id,
      Value<String>? studyCode,
      Value<String>? name,
      Value<String>? description,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate}) {
    return StudyCompanion(
      id: id ?? this.id,
      studyCode: studyCode ?? this.studyCode,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studyCode.present) {
      map['study_code'] = Variable<String>(studyCode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyCompanion(')
          ..write('id: $id, ')
          ..write('studyCode: $studyCode, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }
}

class $ChildStudyTable extends ChildStudy
    with TableInfo<$ChildStudyTable, ChildStudyAssociationsEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildStudyTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
      'child_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _studyCodeMeta =
      const VerificationMeta('studyCode');
  @override
  late final GeneratedColumn<String> studyCode = GeneratedColumn<String>(
      'study_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [childId, studyCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'child_study';
  @override
  VerificationContext validateIntegrity(
      Insertable<ChildStudyAssociationsEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('study_code')) {
      context.handle(_studyCodeMeta,
          studyCode.isAcceptableOrUnknown(data['study_code']!, _studyCodeMeta));
    } else if (isInserting) {
      context.missing(_studyCodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId, studyCode};
  @override
  ChildStudyAssociationsEntity map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChildStudyAssociationsEntity(
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}child_id'])!,
      studyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}study_code'])!,
    );
  }

  @override
  $ChildStudyTable createAlias(String alias) {
    return $ChildStudyTable(attachedDatabase, alias);
  }
}

class ChildStudyCompanion
    extends UpdateCompanion<ChildStudyAssociationsEntity> {
  final Value<int> childId;
  final Value<String> studyCode;
  final Value<int> rowid;
  const ChildStudyCompanion({
    this.childId = const Value.absent(),
    this.studyCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChildStudyCompanion.insert({
    required int childId,
    required String studyCode,
    this.rowid = const Value.absent(),
  })  : childId = Value(childId),
        studyCode = Value(studyCode);
  static Insertable<ChildStudyAssociationsEntity> custom({
    Expression<int>? childId,
    Expression<String>? studyCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (studyCode != null) 'study_code': studyCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChildStudyCompanion copyWith(
      {Value<int>? childId, Value<String>? studyCode, Value<int>? rowid}) {
    return ChildStudyCompanion(
      childId: childId ?? this.childId,
      studyCode: studyCode ?? this.studyCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (studyCode.present) {
      map['study_code'] = Variable<String>(studyCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildStudyCompanion(')
          ..write('childId: $childId, ')
          ..write('studyCode: $studyCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  late final $ChildrenTable children = $ChildrenTable(this);
  late final $ArduinoDatasTable arduinoDatas = $ArduinoDatasTable(this);
  late final $StudyTable study = $StudyTable(this);
  late final $ChildStudyTable childStudy = $ChildStudyTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [children, arduinoDatas, study, childStudy];
}
