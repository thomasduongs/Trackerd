import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'default_exercises.dart';

part 'app_database.g.dart';

class ExerciseEntries extends Table {
  TextColumn get id => text()();
  TextColumn get muscleGroup => text().withDefault(const Constant('Misc.'))();
  TextColumn get exerciseName => text().withLength(min: 1, max: 120)();
  DateTimeColumn get performedAt => dateTime()();
  IntColumn get reps => integer().check(reps.isBetweenValues(0, 20))();
  IntColumn get weightTimesTen =>
      integer().check(weightTimesTen.isBetweenValues(0, 5000))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get muscleGroup => text().withLength(min: 1, max: 40)();
  TextColumn get exerciseName => text().withLength(min: 1, max: 120)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {muscleGroup, exerciseName},
  ];
}

@DriftDatabase(tables: [ExerciseEntries, Exercises])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'trackerd'));
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await customStatement(
        'CREATE INDEX exercise_entries_name_date_idx '
        'ON exercise_entries (exercise_name, performed_at)',
      );
      await _seedExercises();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 3) {
        await migrator.addColumn(exerciseEntries, exerciseEntries.muscleGroup);
      }
      if (from < 4) {
        if (from >= 2) {
          await customStatement(
            'ALTER TABLE custom_exercises RENAME TO exercises',
          );
        } else {
          await migrator.createTable(exercises);
        }
        await _seedExercises();
      }
    },
  );

  Future<void> _seedExercises() async {
    for (final group in defaultExercises.entries) {
      for (final name in group.value) {
        await addExercise(muscleGroup: group.key, exerciseName: name);
      }
    }
  }

  Future<bool> addExercise({
    required String muscleGroup,
    required String exerciseName,
  }) async {
    return transaction(() async {
      final name = exerciseName.trim();
      final group = muscleGroup.trim();
      _validateExercise(group, name);
      if (await _exerciseExists(group, name)) return false;
      await into(exercises).insert(
        ExercisesCompanion.insert(
          muscleGroup: group,
          exerciseName: name,
          createdAt: DateTime.now(),
        ),
      );
      return true;
    });
  }

  Future<bool> updateExercise({
    required int id,
    required String muscleGroup,
    required String exerciseName,
  }) {
    return transaction(() async {
      final name = exerciseName.trim();
      final group = muscleGroup.trim();
      _validateExercise(group, name);
      if (await _exerciseExists(group, name, excludingId: id)) return false;
      final changed =
          await (update(exercises)..where((row) => row.id.equals(id))).write(
            ExercisesCompanion(
              muscleGroup: Value(group),
              exerciseName: Value(name),
            ),
          );
      if (changed == 0) throw StateError('Exercise no longer exists.');
      return true;
    });
  }

  Future<bool> _exerciseExists(
    String group,
    String name, {
    int? excludingId,
  }) async {
    final row =
        await (select(exercises)
              ..where(
                (row) =>
                    row.muscleGroup.equals(group) &
                    row.exerciseName.lower().equals(name.toLowerCase()) &
                    (excludingId == null
                        ? const Constant(true)
                        : row.id.equals(excludingId).not()),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  static void _validateExercise(String group, String name) {
    if (group.isEmpty ||
        group.length > 40 ||
        name.isEmpty ||
        name.length > 120) {
      throw ArgumentError(
        'Enter a body part and an exercise name of 1–120 characters.',
      );
    }
  }

  Future<int> deleteExercise(int id) {
    // Logged sets retain the name and body part recorded at submission time.
    return (delete(exercises)..where((row) => row.id.equals(id))).go();
  }

  SimpleSelectStatement<$ExercisesTable, Exercise> _catalogQuery([
    String? muscleGroup,
  ]) {
    final query = select(exercises);
    if (muscleGroup != null) {
      query.where((row) => row.muscleGroup.equals(muscleGroup));
    }
    return query..orderBy([
      (row) => OrderingTerm.asc(row.muscleGroup),
      (row) => OrderingTerm.asc(row.exerciseName),
    ]);
  }

  Future<List<Exercise>> exerciseCatalog([String? muscleGroup]) =>
      _catalogQuery(muscleGroup).get();

  Stream<List<Exercise>> watchExerciseCatalog() => _catalogQuery().watch();

  Future<void> saveExerciseSets({
    required String muscleGroup,
    required String exerciseName,
    required DateTime performedAt,
    required List<ExerciseSetInput> sets,
  }) async {
    final normalizedName = exerciseName.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '-',
    );
    final date = _dateKey(performedAt);
    final submissionId =
        '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';

    await batch((batch) {
      batch.insertAll(exerciseEntries, [
        for (final indexedSet in sets.indexed)
          ExerciseEntriesCompanion.insert(
            id: '$normalizedName-$date-$submissionId-${indexedSet.$1 + 1}',
            muscleGroup: Value(muscleGroup),
            exerciseName: exerciseName.trim(),
            performedAt: performedAt,
            reps: indexedSet.$2.reps,
            weightTimesTen: (indexedSet.$2.weight * 10).round(),
          ),
      ]);
    });
  }

  Stream<List<ExerciseEntry>> watchAllExercises() {
    return (select(
      exerciseEntries,
    )..orderBy([(entry) => OrderingTerm.desc(entry.performedAt)])).watch();
  }

  Stream<List<ExerciseEntry>> watchExerciseHistory({
    required String muscleGroup,
    required String exerciseName,
  }) {
    return (select(exerciseEntries)
          ..where(
            (entry) =>
                entry.muscleGroup.equals(muscleGroup) &
                entry.exerciseName.equals(exerciseName),
          )
          ..orderBy([
            (entry) => OrderingTerm.desc(entry.performedAt),
            (entry) => OrderingTerm.asc(entry.id),
          ]))
        .watch();
  }

  Future<List<ExerciseEntry>> exercisesForDate(DateTime date) {
    return _exercisesForDateQuery(date).get();
  }

  Stream<List<ExerciseEntry>> watchExercisesForDate(DateTime date) {
    return _exercisesForDateQuery(date).watch();
  }

  Future<int> deleteExerciseSubmission({
    required String exerciseName,
    required DateTime performedAt,
  }) {
    return (delete(exerciseEntries)..where(
          (entry) =>
              entry.exerciseName.equals(exerciseName) &
              entry.performedAt.equals(performedAt),
        ))
        .go();
  }

  SimpleSelectStatement<$ExerciseEntriesTable, ExerciseEntry>
  _exercisesForDateQuery(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return (select(exerciseEntries)
      ..where(
        (entry) =>
            entry.performedAt.isBiggerOrEqualValue(start) &
            entry.performedAt.isSmallerThanValue(end),
      )
      ..orderBy([(entry) => OrderingTerm.desc(entry.performedAt)]));
  }

  static String _dateKey(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${date.year}${twoDigits(date.month)}${twoDigits(date.day)}';
  }
}

class ExerciseSetInput {
  const ExerciseSetInput({required this.reps, required this.weight});

  final int reps;
  final double weight;
}
