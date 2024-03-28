// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EmployeeTable extends Employee
    with TableInfo<$EmployeeTable, EmployeeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmployeeTable(this.attachedDatabase, [this._alias]);
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
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _postMeta = const VerificationMeta('post');
  @override
  late final GeneratedColumn<String> post = GeneratedColumn<String>(
      'post', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _salaryMeta = const VerificationMeta('salary');
  @override
  late final GeneratedColumn<int> salary = GeneratedColumn<int>(
      'salary', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, post, salary];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employee';
  @override
  VerificationContext validateIntegrity(Insertable<EmployeeData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('post')) {
      context.handle(
          _postMeta, post.isAcceptableOrUnknown(data['post']!, _postMeta));
    }
    if (data.containsKey('salary')) {
      context.handle(_salaryMeta,
          salary.isAcceptableOrUnknown(data['salary']!, _salaryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmployeeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmployeeData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      post: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}post']),
      salary: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}salary']),
    );
  }

  @override
  $EmployeeTable createAlias(String alias) {
    return $EmployeeTable(attachedDatabase, alias);
  }
}

class EmployeeData extends DataClass implements Insertable<EmployeeData> {
  final int id;
  final String? name;
  final String? post;
  final int? salary;
  const EmployeeData({required this.id, this.name, this.post, this.salary});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || post != null) {
      map['post'] = Variable<String>(post);
    }
    if (!nullToAbsent || salary != null) {
      map['salary'] = Variable<int>(salary);
    }
    return map;
  }

  EmployeeCompanion toCompanion(bool nullToAbsent) {
    return EmployeeCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      post: post == null && nullToAbsent ? const Value.absent() : Value(post),
      salary:
          salary == null && nullToAbsent ? const Value.absent() : Value(salary),
    );
  }

  factory EmployeeData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmployeeData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      post: serializer.fromJson<String?>(json['post']),
      salary: serializer.fromJson<int?>(json['salary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'post': serializer.toJson<String?>(post),
      'salary': serializer.toJson<int?>(salary),
    };
  }

  EmployeeData copyWith(
          {int? id,
          Value<String?> name = const Value.absent(),
          Value<String?> post = const Value.absent(),
          Value<int?> salary = const Value.absent()}) =>
      EmployeeData(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
        post: post.present ? post.value : this.post,
        salary: salary.present ? salary.value : this.salary,
      );
  @override
  String toString() {
    return (StringBuffer('EmployeeData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('post: $post, ')
          ..write('salary: $salary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, post, salary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmployeeData &&
          other.id == this.id &&
          other.name == this.name &&
          other.post == this.post &&
          other.salary == this.salary);
}

class EmployeeCompanion extends UpdateCompanion<EmployeeData> {
  final Value<int> id;
  final Value<String?> name;
  final Value<String?> post;
  final Value<int?> salary;
  const EmployeeCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.post = const Value.absent(),
    this.salary = const Value.absent(),
  });
  EmployeeCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.post = const Value.absent(),
    this.salary = const Value.absent(),
  });
  static Insertable<EmployeeData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? post,
    Expression<int>? salary,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (post != null) 'post': post,
      if (salary != null) 'salary': salary,
    });
  }

  EmployeeCompanion copyWith(
      {Value<int>? id,
      Value<String?>? name,
      Value<String?>? post,
      Value<int?>? salary}) {
    return EmployeeCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      post: post ?? this.post,
      salary: salary ?? this.salary,
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
    if (post.present) {
      map['post'] = Variable<String>(post.value);
    }
    if (salary.present) {
      map['salary'] = Variable<int>(salary.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmployeeCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('post: $post, ')
          ..write('salary: $salary')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  late final $EmployeeTable employee = $EmployeeTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [employee];
}
