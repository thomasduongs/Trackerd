// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ExerciseEntriesTable extends ExerciseEntries
    with TableInfo<$ExerciseEntriesTable, ExerciseEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _performedAtMeta = const VerificationMeta(
    'performedAt',
  );
  @override
  late final GeneratedColumn<DateTime> performedAt = GeneratedColumn<DateTime>(
    'performed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    check: () => ComparableExpr(reps).isBetweenValues(0, 20),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightTimesTenMeta = const VerificationMeta(
    'weightTimesTen',
  );
  @override
  late final GeneratedColumn<int> weightTimesTen = GeneratedColumn<int>(
    'weight_times_ten',
    aliasedName,
    false,
    check: () => ComparableExpr(weightTimesTen).isBetweenValues(0, 5000),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseName,
    performedAt,
    reps,
    weightTimesTen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('performed_at')) {
      context.handle(
        _performedAtMeta,
        performedAt.isAcceptableOrUnknown(
          data['performed_at']!,
          _performedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_performedAtMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('weight_times_ten')) {
      context.handle(
        _weightTimesTenMeta,
        weightTimesTen.isAcceptableOrUnknown(
          data['weight_times_ten']!,
          _weightTimesTenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weightTimesTenMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      )!,
      performedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}performed_at'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      weightTimesTen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight_times_ten'],
      )!,
    );
  }

  @override
  $ExerciseEntriesTable createAlias(String alias) {
    return $ExerciseEntriesTable(attachedDatabase, alias);
  }
}

class ExerciseEntry extends DataClass implements Insertable<ExerciseEntry> {
  final String id;
  final String exerciseName;
  final DateTime performedAt;
  final int reps;
  final int weightTimesTen;
  const ExerciseEntry({
    required this.id,
    required this.exerciseName,
    required this.performedAt,
    required this.reps,
    required this.weightTimesTen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['exercise_name'] = Variable<String>(exerciseName);
    map['performed_at'] = Variable<DateTime>(performedAt);
    map['reps'] = Variable<int>(reps);
    map['weight_times_ten'] = Variable<int>(weightTimesTen);
    return map;
  }

  ExerciseEntriesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseEntriesCompanion(
      id: Value(id),
      exerciseName: Value(exerciseName),
      performedAt: Value(performedAt),
      reps: Value(reps),
      weightTimesTen: Value(weightTimesTen),
    );
  }

  factory ExerciseEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseEntry(
      id: serializer.fromJson<String>(json['id']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      performedAt: serializer.fromJson<DateTime>(json['performedAt']),
      reps: serializer.fromJson<int>(json['reps']),
      weightTimesTen: serializer.fromJson<int>(json['weightTimesTen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'performedAt': serializer.toJson<DateTime>(performedAt),
      'reps': serializer.toJson<int>(reps),
      'weightTimesTen': serializer.toJson<int>(weightTimesTen),
    };
  }

  ExerciseEntry copyWith({
    String? id,
    String? exerciseName,
    DateTime? performedAt,
    int? reps,
    int? weightTimesTen,
  }) => ExerciseEntry(
    id: id ?? this.id,
    exerciseName: exerciseName ?? this.exerciseName,
    performedAt: performedAt ?? this.performedAt,
    reps: reps ?? this.reps,
    weightTimesTen: weightTimesTen ?? this.weightTimesTen,
  );
  ExerciseEntry copyWithCompanion(ExerciseEntriesCompanion data) {
    return ExerciseEntry(
      id: data.id.present ? data.id.value : this.id,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      performedAt: data.performedAt.present
          ? data.performedAt.value
          : this.performedAt,
      reps: data.reps.present ? data.reps.value : this.reps,
      weightTimesTen: data.weightTimesTen.present
          ? data.weightTimesTen.value
          : this.weightTimesTen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseEntry(')
          ..write('id: $id, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('performedAt: $performedAt, ')
          ..write('reps: $reps, ')
          ..write('weightTimesTen: $weightTimesTen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, exerciseName, performedAt, reps, weightTimesTen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseEntry &&
          other.id == this.id &&
          other.exerciseName == this.exerciseName &&
          other.performedAt == this.performedAt &&
          other.reps == this.reps &&
          other.weightTimesTen == this.weightTimesTen);
}

class ExerciseEntriesCompanion extends UpdateCompanion<ExerciseEntry> {
  final Value<String> id;
  final Value<String> exerciseName;
  final Value<DateTime> performedAt;
  final Value<int> reps;
  final Value<int> weightTimesTen;
  final Value<int> rowid;
  const ExerciseEntriesCompanion({
    this.id = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.performedAt = const Value.absent(),
    this.reps = const Value.absent(),
    this.weightTimesTen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseEntriesCompanion.insert({
    required String id,
    required String exerciseName,
    required DateTime performedAt,
    required int reps,
    required int weightTimesTen,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       exerciseName = Value(exerciseName),
       performedAt = Value(performedAt),
       reps = Value(reps),
       weightTimesTen = Value(weightTimesTen);
  static Insertable<ExerciseEntry> custom({
    Expression<String>? id,
    Expression<String>? exerciseName,
    Expression<DateTime>? performedAt,
    Expression<int>? reps,
    Expression<int>? weightTimesTen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (performedAt != null) 'performed_at': performedAt,
      if (reps != null) 'reps': reps,
      if (weightTimesTen != null) 'weight_times_ten': weightTimesTen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? exerciseName,
    Value<DateTime>? performedAt,
    Value<int>? reps,
    Value<int>? weightTimesTen,
    Value<int>? rowid,
  }) {
    return ExerciseEntriesCompanion(
      id: id ?? this.id,
      exerciseName: exerciseName ?? this.exerciseName,
      performedAt: performedAt ?? this.performedAt,
      reps: reps ?? this.reps,
      weightTimesTen: weightTimesTen ?? this.weightTimesTen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (performedAt.present) {
      map['performed_at'] = Variable<DateTime>(performedAt.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (weightTimesTen.present) {
      map['weight_times_ten'] = Variable<int>(weightTimesTen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseEntriesCompanion(')
          ..write('id: $id, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('performedAt: $performedAt, ')
          ..write('reps: $reps, ')
          ..write('weightTimesTen: $weightTimesTen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomExercisesTable extends CustomExercises
    with TableInfo<$CustomExercisesTable, CustomExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _muscleGroupMeta = const VerificationMeta(
    'muscleGroup',
  );
  @override
  late final GeneratedColumn<String> muscleGroup = GeneratedColumn<String>(
    'muscle_group',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    muscleGroup,
    exerciseName,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('muscle_group')) {
      context.handle(
        _muscleGroupMeta,
        muscleGroup.isAcceptableOrUnknown(
          data['muscle_group']!,
          _muscleGroupMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_muscleGroupMeta);
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {muscleGroup, exerciseName},
  ];
  @override
  CustomExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      muscleGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_group'],
      )!,
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomExercisesTable createAlias(String alias) {
    return $CustomExercisesTable(attachedDatabase, alias);
  }
}

class CustomExercise extends DataClass implements Insertable<CustomExercise> {
  final int id;
  final String muscleGroup;
  final String exerciseName;
  final DateTime createdAt;
  const CustomExercise({
    required this.id,
    required this.muscleGroup,
    required this.exerciseName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['muscle_group'] = Variable<String>(muscleGroup);
    map['exercise_name'] = Variable<String>(exerciseName);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomExercisesCompanion toCompanion(bool nullToAbsent) {
    return CustomExercisesCompanion(
      id: Value(id),
      muscleGroup: Value(muscleGroup),
      exerciseName: Value(exerciseName),
      createdAt: Value(createdAt),
    );
  }

  factory CustomExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomExercise(
      id: serializer.fromJson<int>(json['id']),
      muscleGroup: serializer.fromJson<String>(json['muscleGroup']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'muscleGroup': serializer.toJson<String>(muscleGroup),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomExercise copyWith({
    int? id,
    String? muscleGroup,
    String? exerciseName,
    DateTime? createdAt,
  }) => CustomExercise(
    id: id ?? this.id,
    muscleGroup: muscleGroup ?? this.muscleGroup,
    exerciseName: exerciseName ?? this.exerciseName,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomExercise copyWithCompanion(CustomExercisesCompanion data) {
    return CustomExercise(
      id: data.id.present ? data.id.value : this.id,
      muscleGroup: data.muscleGroup.present
          ? data.muscleGroup.value
          : this.muscleGroup,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomExercise(')
          ..write('id: $id, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, muscleGroup, exerciseName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomExercise &&
          other.id == this.id &&
          other.muscleGroup == this.muscleGroup &&
          other.exerciseName == this.exerciseName &&
          other.createdAt == this.createdAt);
}

class CustomExercisesCompanion extends UpdateCompanion<CustomExercise> {
  final Value<int> id;
  final Value<String> muscleGroup;
  final Value<String> exerciseName;
  final Value<DateTime> createdAt;
  const CustomExercisesCompanion({
    this.id = const Value.absent(),
    this.muscleGroup = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String muscleGroup,
    required String exerciseName,
    required DateTime createdAt,
  }) : muscleGroup = Value(muscleGroup),
       exerciseName = Value(exerciseName),
       createdAt = Value(createdAt);
  static Insertable<CustomExercise> custom({
    Expression<int>? id,
    Expression<String>? muscleGroup,
    Expression<String>? exerciseName,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomExercisesCompanion copyWith({
    Value<int>? id,
    Value<String>? muscleGroup,
    Value<String>? exerciseName,
    Value<DateTime>? createdAt,
  }) {
    return CustomExercisesCompanion(
      id: id ?? this.id,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      exerciseName: exerciseName ?? this.exerciseName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (muscleGroup.present) {
      map['muscle_group'] = Variable<String>(muscleGroup.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomExercisesCompanion(')
          ..write('id: $id, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExerciseEntriesTable exerciseEntries = $ExerciseEntriesTable(
    this,
  );
  late final $CustomExercisesTable customExercises = $CustomExercisesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    exerciseEntries,
    customExercises,
  ];
}

typedef $$ExerciseEntriesTableCreateCompanionBuilder =
    ExerciseEntriesCompanion Function({
      required String id,
      required String exerciseName,
      required DateTime performedAt,
      required int reps,
      required int weightTimesTen,
      Value<int> rowid,
    });
typedef $$ExerciseEntriesTableUpdateCompanionBuilder =
    ExerciseEntriesCompanion Function({
      Value<String> id,
      Value<String> exerciseName,
      Value<DateTime> performedAt,
      Value<int> reps,
      Value<int> weightTimesTen,
      Value<int> rowid,
    });

class $$ExerciseEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseEntriesTable> {
  $$ExerciseEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weightTimesTen => $composableBuilder(
    column: $table.weightTimesTen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseEntriesTable> {
  $$ExerciseEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weightTimesTen => $composableBuilder(
    column: $table.weightTimesTen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseEntriesTable> {
  $$ExerciseEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get weightTimesTen => $composableBuilder(
    column: $table.weightTimesTen,
    builder: (column) => column,
  );
}

class $$ExerciseEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseEntriesTable,
          ExerciseEntry,
          $$ExerciseEntriesTableFilterComposer,
          $$ExerciseEntriesTableOrderingComposer,
          $$ExerciseEntriesTableAnnotationComposer,
          $$ExerciseEntriesTableCreateCompanionBuilder,
          $$ExerciseEntriesTableUpdateCompanionBuilder,
          (
            ExerciseEntry,
            BaseReferences<_$AppDatabase, $ExerciseEntriesTable, ExerciseEntry>,
          ),
          ExerciseEntry,
          PrefetchHooks Function()
        > {
  $$ExerciseEntriesTableTableManager(
    _$AppDatabase db,
    $ExerciseEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> exerciseName = const Value.absent(),
                Value<DateTime> performedAt = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> weightTimesTen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseEntriesCompanion(
                id: id,
                exerciseName: exerciseName,
                performedAt: performedAt,
                reps: reps,
                weightTimesTen: weightTimesTen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String exerciseName,
                required DateTime performedAt,
                required int reps,
                required int weightTimesTen,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseEntriesCompanion.insert(
                id: id,
                exerciseName: exerciseName,
                performedAt: performedAt,
                reps: reps,
                weightTimesTen: weightTimesTen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseEntriesTable,
      ExerciseEntry,
      $$ExerciseEntriesTableFilterComposer,
      $$ExerciseEntriesTableOrderingComposer,
      $$ExerciseEntriesTableAnnotationComposer,
      $$ExerciseEntriesTableCreateCompanionBuilder,
      $$ExerciseEntriesTableUpdateCompanionBuilder,
      (
        ExerciseEntry,
        BaseReferences<_$AppDatabase, $ExerciseEntriesTable, ExerciseEntry>,
      ),
      ExerciseEntry,
      PrefetchHooks Function()
    >;
typedef $$CustomExercisesTableCreateCompanionBuilder =
    CustomExercisesCompanion Function({
      Value<int> id,
      required String muscleGroup,
      required String exerciseName,
      required DateTime createdAt,
    });
typedef $$CustomExercisesTableUpdateCompanionBuilder =
    CustomExercisesCompanion Function({
      Value<int> id,
      Value<String> muscleGroup,
      Value<String> exerciseName,
      Value<DateTime> createdAt,
    });

class $$CustomExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomExercisesTable,
          CustomExercise,
          $$CustomExercisesTableFilterComposer,
          $$CustomExercisesTableOrderingComposer,
          $$CustomExercisesTableAnnotationComposer,
          $$CustomExercisesTableCreateCompanionBuilder,
          $$CustomExercisesTableUpdateCompanionBuilder,
          (
            CustomExercise,
            BaseReferences<
              _$AppDatabase,
              $CustomExercisesTable,
              CustomExercise
            >,
          ),
          CustomExercise,
          PrefetchHooks Function()
        > {
  $$CustomExercisesTableTableManager(
    _$AppDatabase db,
    $CustomExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> muscleGroup = const Value.absent(),
                Value<String> exerciseName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomExercisesCompanion(
                id: id,
                muscleGroup: muscleGroup,
                exerciseName: exerciseName,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String muscleGroup,
                required String exerciseName,
                required DateTime createdAt,
              }) => CustomExercisesCompanion.insert(
                id: id,
                muscleGroup: muscleGroup,
                exerciseName: exerciseName,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomExercisesTable,
      CustomExercise,
      $$CustomExercisesTableFilterComposer,
      $$CustomExercisesTableOrderingComposer,
      $$CustomExercisesTableAnnotationComposer,
      $$CustomExercisesTableCreateCompanionBuilder,
      $$CustomExercisesTableUpdateCompanionBuilder,
      (
        CustomExercise,
        BaseReferences<_$AppDatabase, $CustomExercisesTable, CustomExercise>,
      ),
      CustomExercise,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExerciseEntriesTableTableManager get exerciseEntries =>
      $$ExerciseEntriesTableTableManager(_db, _db.exerciseEntries);
  $$CustomExercisesTableTableManager get customExercises =>
      $$CustomExercisesTableTableManager(_db, _db.customExercises);
}
