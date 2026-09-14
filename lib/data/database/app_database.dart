import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class ExerciseEntries extends Table {
  TextColumn get id => text()();
  TextColumn get exerciseName => text().withLength(min: 1, max: 120)();
  DateTimeColumn get performedAt => dateTime()();
  IntColumn get reps => integer().check(reps.isBetweenValues(0, 20))();
  IntColumn get weightTimesTen =>
      integer().check(weightTimesTen.isBetweenValues(0, 5000))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CustomExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get muscleGroup => text().withLength(min: 1, max: 40)();
  TextColumn get exerciseName => text().withLength(min: 1, max: 120)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {muscleGroup, exerciseName},
  ];
}

@DriftDatabase(tables: [ExerciseEntries, CustomExercises])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'trackerd'));
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await customStatement(
        'CREATE INDEX exercise_entries_name_date_idx '
        'ON exercise_entries (exercise_name, performed_at)',
      );
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(customExercises);
      }
    },
  );

  Future<void> addCustomExercise({
    required String muscleGroup,
    required String exerciseName,
  }) async {
    await into(customExercises).insert(
      CustomExercisesCompanion.insert(
        muscleGroup: muscleGroup.trim(),
        exerciseName: exerciseName.trim(),
        createdAt: DateTime.now(),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<List<String>> customExerciseNames(String muscleGroup) async {
    final rows =
        await (select(customExercises)
              ..where((exercise) => exercise.muscleGroup.equals(muscleGroup))
              ..orderBy([
                (exercise) => OrderingTerm.asc(exercise.exerciseName),
              ]))
            .get();
    return rows.map((exercise) => exercise.exerciseName).toList();
  }

  Future<void> saveExerciseSets({
    required String exerciseName,
    required DateTime performedAt,
    required List<ExerciseSetInput> sets,
  }) async {
    final normalizedName = exerciseName.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '-',
    );
    final date = _dateKey(performedAt);
    final submissionId = performedAt.microsecondsSinceEpoch;

    await batch((batch) {
      batch.insertAll(exerciseEntries, [
        for (final indexedSet in sets.indexed)
          ExerciseEntriesCompanion.insert(
            id: '$normalizedName-$date-$submissionId-${indexedSet.$1 + 1}',
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
