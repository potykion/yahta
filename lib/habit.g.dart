// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Habit extends DataClass implements Insertable<Habit> {
  final int id;
  final String title;
  final HabitType type;
  Habit({@required this.id, @required this.title, @required this.type});
  factory Habit.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return Habit(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      title:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}title']),
      type: $HabitsTable.$converter0.mapToDart(
          intType.mapFromDatabaseResponse(data['${effectivePrefix}type'])),
    );
  }
  factory Habit.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<HabitType>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<HabitType>(type),
    };
  }

  @override
  HabitsCompanion createCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
    );
  }

  Habit copyWith({int id, String title, HabitType type}) => Habit(
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
      );
  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      $mrjf($mrjc(id.hashCode, $mrjc(title.hashCode, type.hashCode)));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<int> id;
  final Value<String> title;
  final Value<HabitType> type;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    @required String title,
    this.type = const Value.absent(),
  }) : title = Value(title);
  HabitsCompanion copyWith(
      {Value<int> id, Value<String> title, Value<HabitType> type}) {
    return HabitsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
    );
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  final GeneratedDatabase _db;
  final String _alias;
  $HabitsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _titleMeta = const VerificationMeta('title');
  GeneratedTextColumn _title;
  @override
  GeneratedTextColumn get title => _title ??= _constructTitle();
  GeneratedTextColumn _constructTitle() {
    return GeneratedTextColumn(
      'title',
      $tableName,
      false,
    );
  }

  final VerificationMeta _typeMeta = const VerificationMeta('type');
  GeneratedIntColumn _type;
  @override
  GeneratedIntColumn get type => _type ??= _constructType();
  GeneratedIntColumn _constructType() {
    return GeneratedIntColumn('type', $tableName, false,
        defaultValue: Constant(HabitType.positive.index));
  }

  @override
  List<GeneratedColumn> get $columns => [id, title, type];
  @override
  $HabitsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'habits';
  @override
  final String actualTableName = 'habits';
  @override
  VerificationContext validateIntegrity(HabitsCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.id.present) {
      context.handle(_idMeta, id.isAcceptableValue(d.id.value, _idMeta));
    }
    if (d.title.present) {
      context.handle(
          _titleMeta, title.isAcceptableValue(d.title.value, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Habit.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(HabitsCompanion d) {
    final map = <String, Variable>{};
    if (d.id.present) {
      map['id'] = Variable<int, IntType>(d.id.value);
    }
    if (d.title.present) {
      map['title'] = Variable<String, StringType>(d.title.value);
    }
    if (d.type.present) {
      final converter = $HabitsTable.$converter0;
      map['type'] = Variable<int, IntType>(converter.mapToSql(d.type.value));
    }
    return map;
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(_db, alias);
  }

  static TypeConverter<HabitType, int> $converter0 = const HabitTypeConverter();
}

class HabitMark extends DataClass implements Insertable<HabitMark> {
  final int id;
  final int habitId;
  final DateTime datetime;
  HabitMark(
      {@required this.id, @required this.habitId, @required this.datetime});
  factory HabitMark.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    return HabitMark(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      habitId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}habit_id']),
      datetime: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}datetime']),
    );
  }
  factory HabitMark.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return HabitMark(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      datetime: serializer.fromJson<DateTime>(json['datetime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'datetime': serializer.toJson<DateTime>(datetime),
    };
  }

  @override
  HabitMarksCompanion createCompanion(bool nullToAbsent) {
    return HabitMarksCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      habitId: habitId == null && nullToAbsent
          ? const Value.absent()
          : Value(habitId),
      datetime: datetime == null && nullToAbsent
          ? const Value.absent()
          : Value(datetime),
    );
  }

  HabitMark copyWith({int id, int habitId, DateTime datetime}) => HabitMark(
        id: id ?? this.id,
        habitId: habitId ?? this.habitId,
        datetime: datetime ?? this.datetime,
      );
  @override
  String toString() {
    return (StringBuffer('HabitMark(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('datetime: $datetime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      $mrjf($mrjc(id.hashCode, $mrjc(habitId.hashCode, datetime.hashCode)));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is HabitMark &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.datetime == this.datetime);
}

class HabitMarksCompanion extends UpdateCompanion<HabitMark> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<DateTime> datetime;
  const HabitMarksCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.datetime = const Value.absent(),
  });
  HabitMarksCompanion.insert({
    this.id = const Value.absent(),
    @required int habitId,
    this.datetime = const Value.absent(),
  }) : habitId = Value(habitId);
  HabitMarksCompanion copyWith(
      {Value<int> id, Value<int> habitId, Value<DateTime> datetime}) {
    return HabitMarksCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      datetime: datetime ?? this.datetime,
    );
  }
}

class $HabitMarksTable extends HabitMarks
    with TableInfo<$HabitMarksTable, HabitMark> {
  final GeneratedDatabase _db;
  final String _alias;
  $HabitMarksTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _habitIdMeta = const VerificationMeta('habitId');
  GeneratedIntColumn _habitId;
  @override
  GeneratedIntColumn get habitId => _habitId ??= _constructHabitId();
  GeneratedIntColumn _constructHabitId() {
    return GeneratedIntColumn(
      'habit_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _datetimeMeta = const VerificationMeta('datetime');
  GeneratedDateTimeColumn _datetime;
  @override
  GeneratedDateTimeColumn get datetime => _datetime ??= _constructDatetime();
  GeneratedDateTimeColumn _constructDatetime() {
    return GeneratedDateTimeColumn('datetime', $tableName, false,
        defaultValue: currentDateAndTime);
  }

  @override
  List<GeneratedColumn> get $columns => [id, habitId, datetime];
  @override
  $HabitMarksTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'habit_marks';
  @override
  final String actualTableName = 'habit_marks';
  @override
  VerificationContext validateIntegrity(HabitMarksCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.id.present) {
      context.handle(_idMeta, id.isAcceptableValue(d.id.value, _idMeta));
    }
    if (d.habitId.present) {
      context.handle(_habitIdMeta,
          habitId.isAcceptableValue(d.habitId.value, _habitIdMeta));
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (d.datetime.present) {
      context.handle(_datetimeMeta,
          datetime.isAcceptableValue(d.datetime.value, _datetimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitMark map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return HabitMark.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(HabitMarksCompanion d) {
    final map = <String, Variable>{};
    if (d.id.present) {
      map['id'] = Variable<int, IntType>(d.id.value);
    }
    if (d.habitId.present) {
      map['habit_id'] = Variable<int, IntType>(d.habitId.value);
    }
    if (d.datetime.present) {
      map['datetime'] = Variable<DateTime, DateTimeType>(d.datetime.value);
    }
    return map;
  }

  @override
  $HabitMarksTable createAlias(String alias) {
    return $HabitMarksTable(_db, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $HabitsTable _habits;
  $HabitsTable get habits => _habits ??= $HabitsTable(this);
  $HabitMarksTable _habitMarks;
  $HabitMarksTable get habitMarks => _habitMarks ??= $HabitMarksTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [habits, habitMarks];
}
