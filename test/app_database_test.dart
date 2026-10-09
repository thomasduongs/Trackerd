import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackerd_app/data/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('stores each completed set as a separate exercise entry', () async {
    final performedAt = DateTime(2026, 9, 13, 8, 30);

    await database.saveExerciseSets(
      muscleGroup: 'Biceps',
      exerciseName: 'Barbell Curl',
      performedAt: performedAt,
      sets: const [
        ExerciseSetInput(reps: 10, weight: 22.5),
        ExerciseSetInput(reps: 8, weight: 25),
      ],
    );

    final entries = await database.exercisesForDate(performedAt);

    expect(entries, hasLength(2));
    expect(
      entries.every((entry) => entry.exerciseName == 'Barbell Curl'),
      isTrue,
    );
    expect(entries.map((entry) => entry.reps), [10, 8]);
    expect(entries.map((entry) => entry.weightTimesTen), [225, 250]);
    expect(entries.every((entry) => entry.id.contains('20260913')), isTrue);
    expect(entries.map((entry) => entry.id).toSet(), hasLength(2));
  });

  test('deletes every set belonging to one exercise submission', () async {
    final performedAt = DateTime(2026, 9, 13, 8, 30);
    await database.saveExerciseSets(
      muscleGroup: 'Biceps',
      exerciseName: 'Barbell Curl',
      performedAt: performedAt,
      sets: const [
        ExerciseSetInput(reps: 10, weight: 22.5),
        ExerciseSetInput(reps: 8, weight: 25),
      ],
    );

    final deleted = await database.deleteExerciseSubmission(
      exerciseName: 'Barbell Curl',
      performedAt: performedAt,
    );

    expect(deleted, 2);
    expect(await database.exercisesForDate(performedAt), isEmpty);
  });

  test(
    'stores custom exercises under their body part without duplicates',
    () async {
      await database.addExercise(
        muscleGroup: 'Biceps',
        exerciseName: 'Preacher Curl',
      );
      await database.addExercise(
        muscleGroup: 'Biceps',
        exerciseName: 'Preacher Curl',
      );

      expect(
        (await database.exerciseCatalog(
          'Biceps',
        )).where((e) => e.exerciseName == 'Preacher Curl'),
        hasLength(1),
      );
      expect(
        (await database.exerciseCatalog(
          'Chest',
        )).any((e) => e.exerciseName == 'Preacher Curl'),
        isFalse,
      );
    },
  );
  test('exercise history filters body part and name, newest first', () async {
    final early = DateTime(2026, 10, 9, 8);
    final late = DateTime(2026, 10, 9, 14);
    for (final record in [
      ('Chest', 'Dip', early, 10.0),
      ('Chest', 'Dip', late, 20.0),
      ('Triceps', 'Dip', late, 99.0),
      ('Chest', 'Chest Fly', late, 88.0),
    ]) {
      await database.saveExerciseSets(
        muscleGroup: record.$1,
        exerciseName: record.$2,
        performedAt: record.$3,
        sets: [ExerciseSetInput(reps: 10, weight: record.$4)],
      );
    }
    final entries = await database
        .watchExerciseHistory(muscleGroup: 'Chest', exerciseName: 'Dip')
        .first;
    expect(entries, hasLength(2));
    expect(entries.map((e) => e.performedAt), [late, early]);
    expect(entries.map((e) => e.weightTimesTen), [200, 100]);
  });

  test('seeds the requested catalog with Dip in both body parts', () async {
    final catalog = await database.exerciseCatalog();
    expect(catalog, hasLength(34));
    expect(
      catalog.where((e) => e.exerciseName == 'Dip').map((e) => e.muscleGroup),
      ['Chest', 'Triceps'],
    );
    expect(
      (await database.exerciseCatalog('Biceps')).map((e) => e.exerciseName),
      [
        'Cable Reverse Curl',
        'Dumbbell Preacher Curl',
        'EZ-Bar Preacher Curl',
        'Machine Preacher Curl',
        'Seated Dumbbell Curl',
        'Standing Dumbbell Curl',
      ],
    );
    expect(catalog.any((e) => e.exerciseName == 'Barbell Curl'), isFalse);
    expect(catalog.any((e) => e.exerciseName == 'Custom Exercise'), isFalse);
  });

  test('edits and deletes defaults without changing logged workouts', () async {
    final exercise = (await database.exerciseCatalog('Hamstrings')).first;
    final date = DateTime(2026, 10, 9);
    await database.saveExerciseSets(
      muscleGroup: exercise.muscleGroup,
      exerciseName: exercise.exerciseName,
      performedAt: date,
      sets: const [ExerciseSetInput(reps: 10, weight: 20)],
    );
    expect(
      await database.updateExercise(
        id: exercise.id,
        muscleGroup: 'Back',
        exerciseName: 'Corrected Name',
      ),
      isTrue,
    );
    expect(
      (await database.exerciseCatalog(
        'Back',
      )).any((e) => e.id == exercise.id && e.exerciseName == 'Corrected Name'),
      isTrue,
    );
    expect(
      (await database.exerciseCatalog(
        'Hamstrings',
      )).any((e) => e.id == exercise.id),
      isFalse,
    );
    await database.deleteExercise(exercise.id);
    expect(
      (await database.exerciseCatalog()).any((e) => e.id == exercise.id),
      isFalse,
    );
    final logged = await database.exercisesForDate(date);
    expect(logged.single.exerciseName, exercise.exerciseName);
    expect(logged.single.muscleGroup, exercise.muscleGroup);
  });

  test(
    'rejects duplicate names within a body part and invalid input',
    () async {
      expect(
        await database.addExercise(
          muscleGroup: 'Chest',
          exerciseName: '  dip  ',
        ),
        isFalse,
      );
      final exercise = (await database.exerciseCatalog(
        'Chest',
      )).firstWhere((e) => e.exerciseName != 'Dip');
      expect(
        await database.updateExercise(
          id: exercise.id,
          muscleGroup: 'Chest',
          exerciseName: 'DIP',
        ),
        isFalse,
      );
      expect(
        (await database.exerciseCatalog(
          'Chest',
        )).singleWhere((e) => e.id == exercise.id).exerciseName,
        exercise.exerciseName,
      );
      expect(
        database.addExercise(muscleGroup: 'Biceps', exerciseName: '  '),
        throwsArgumentError,
      );
    },
  );

  for (final version in [1, 2, 3]) {
    test('migrates version $version preserving custom exercises and history', () async {
      await database.close();
      final old = NativeDatabase.memory(
        setup: (db) {
          db.execute(
            'CREATE TABLE exercise_entries (id TEXT PRIMARY KEY, ${version >= 3 ? "muscle_group TEXT NOT NULL DEFAULT 'Misc.'," : ""} exercise_name TEXT NOT NULL, performed_at INTEGER NOT NULL, reps INTEGER NOT NULL, weight_times_ten INTEGER NOT NULL)',
          );
          db.execute(
            "INSERT INTO exercise_entries (id, exercise_name, performed_at, reps, weight_times_ten) VALUES ('old', 'Old Curl', 0, 10, 200)",
          );
          if (version >= 2) {
            db.execute(
              'CREATE TABLE custom_exercises (id INTEGER PRIMARY KEY AUTOINCREMENT, muscle_group TEXT NOT NULL, exercise_name TEXT NOT NULL, created_at INTEGER NOT NULL, UNIQUE(muscle_group, exercise_name))',
            );
            db.execute(
              "INSERT INTO custom_exercises VALUES (1, 'Biceps', 'My Curl', 0), (2, 'Chest', 'Dip', 0)",
            );
          }
          db.execute('PRAGMA user_version = $version');
        },
      );
      final migrated = AppDatabase.forTesting(old);
      addTearDown(migrated.close);
      final catalog = await migrated.exerciseCatalog();
      expect(catalog, hasLength(version >= 2 ? 35 : 34));
      if (version >= 2) {
        expect(catalog.singleWhere((e) => e.exerciseName == 'My Curl').id, 1);
      }
      expect(
        (await migrated.watchAllExercises().first).single.exerciseName,
        'Old Curl',
      );
      final tables = await migrated
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .get();
      expect(
        tables.any((row) => row.read<String>('name') == 'custom_exercises'),
        isFalse,
      );
    });
  }

  test('deleted and edited defaults stay changed after reopening', () async {
    await database.close();
    final folder = await Directory.systemTemp.createTemp('trackerd-catalog-');
    final file = File('${folder.path}/test.sqlite');
    final first = AppDatabase.forTesting(NativeDatabase(file));
    final exercises = await first.exerciseCatalog('Hamstrings');
    await first.deleteExercise(exercises.first.id);
    await first.updateExercise(
      id: exercises.last.id,
      muscleGroup: 'Hamstrings',
      exerciseName: 'My Deadlift',
    );
    await first.close();
    final reopened = AppDatabase.forTesting(NativeDatabase(file));
    try {
      expect(
        (await reopened.exerciseCatalog(
          'Hamstrings',
        )).map((e) => e.exerciseName),
        ['My Deadlift'],
      );
    } finally {
      await reopened.close();
      await folder.delete(recursive: true);
    }
  });
}
