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
      await database.addCustomExercise(
        muscleGroup: 'Biceps',
        exerciseName: 'Preacher Curl',
      );
      await database.addCustomExercise(
        muscleGroup: 'Biceps',
        exerciseName: 'Preacher Curl',
      );

      expect(await database.customExerciseNames('Biceps'), ['Preacher Curl']);
      expect(await database.customExerciseNames('Chest'), isEmpty);
    },
  );
}
