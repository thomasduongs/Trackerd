import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackerd_app/app/app.dart';
import 'package:trackerd_app/app/exercise_history_page.dart';
import 'package:trackerd_app/app/newsession/session_exercise.dart';
import 'package:trackerd_app/app/newsession/session_input.dart';
import 'package:trackerd_app/data/database/app_database.dart';
import 'package:trackerd_app/main.dart';

void main() {
  testWidgets('starts on the home page', (tester) async {
    await _pumpApp(tester);

    expect(find.byType(Home), findsOneWidget);
    expect(find.text('Workout Tracker'), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('0 Workouts'), findsOneWidget);
    await _disposeApp(tester);
  });

  testWidgets('add and back buttons navigate between home and session input', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(CupertinoIcons.add));
    await tester.pumpAndSettle();
    expect(find.byType(SessionInput), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.back));
    await tester.pumpAndSettle();
    expect(find.byType(Home), findsOneWidget);
    await _disposeApp(tester);
  });

  testWidgets('muscle group opens the exercise page', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(CupertinoIcons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Biceps'));
    await tester.pumpAndSettle();

    expect(find.byType(SessionExercise), findsOneWidget);
    await _disposeApp(tester);
  });

  testWidgets('check button submits and returns to session input', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(CupertinoIcons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Biceps'));
    await tester.pumpAndSettle();
    await tester.drag(find.text('0').first, const Offset(0, -60));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(CupertinoIcons.check_mark));
    await tester.pumpAndSettle();

    expect(find.byType(SessionInput), findsOneWidget);
    expect(find.byType(SessionExercise), findsNothing);
    await _disposeApp(tester);
  });

  testWidgets('session input shows only today with newest exercise first', (
    tester,
  ) async {
    final database = await _pumpApp(tester);
    final current = DateTime.now();
    final now = DateTime(current.year, current.month, current.day, 12);

    await database.saveExerciseSets(
      muscleGroup: 'Biceps',
      exerciseName: 'Older Exercise',
      performedAt: now.subtract(const Duration(minutes: 10)),
      sets: const [ExerciseSetInput(reps: 8, weight: 20)],
    );
    await database.saveExerciseSets(
      muscleGroup: 'Biceps',
      exerciseName: 'Newest Exercise',
      performedAt: now,
      sets: const [
        ExerciseSetInput(reps: 15, weight: 20),
        ExerciseSetInput(reps: 8, weight: 30),
      ],
    );
    await database.saveExerciseSets(
      muscleGroup: 'Biceps',
      exerciseName: 'Yesterday Exercise',
      performedAt: now.subtract(const Duration(days: 1)),
      sets: const [ExerciseSetInput(reps: 12, weight: 15)],
    );

    await tester.tap(find.byIcon(CupertinoIcons.add));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Newest Exercise'), findsOneWidget);
    expect(find.text('Older Exercise'), findsOneWidget);
    expect(find.text('Yesterday Exercise'), findsNothing);
    expect(
      find.text('2 sets  •  Reps at max: 8 \nMax weight: 30 lbs'),
      findsOneWidget,
    );
    expect(find.text('2 Exercises'), findsOneWidget);
    expect(find.text('3 Sets'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Newest Exercise')).dy,
      lessThan(tester.getTopLeft(find.text('Older Exercise')).dy),
    );
    await _disposeApp(tester);
  });

  testWidgets('adds a custom exercise from the sliding page', (tester) async {
    final database = await _pumpApp(tester);

    await tester.tap(find.byIcon(CupertinoIcons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add a new exercise type'));
    await tester.pumpAndSettle();

    expect(find.text('New Exercise'), findsOneWidget);
    await tester.enterText(find.byType(CupertinoTextField), 'Preacher Curl');
    await tester.tap(find.byTooltip('Save exercise'));
    await tester.pumpAndSettle();

    expect(find.byType(SessionInput), findsOneWidget);
    expect(
      (await database.exerciseCatalog(
        'Biceps',
      )).any((e) => e.exerciseName == 'Preacher Curl'),
      isTrue,
    );
    await _disposeApp(tester);
  });

  testWidgets('manage exercises edits and deletes an exercise', (tester) async {
    final database = await _pumpApp(tester);
    await tester.tap(find.byIcon(CupertinoIcons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Manage exercises'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit Back Extensions'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(CupertinoTextField),
      'Corrected Back Extension',
    );
    await tester.tap(find.byTooltip('Save exercise'));
    await tester.pumpAndSettle();
    expect(
      (await database.exerciseCatalog(
        'Back',
      )).any((e) => e.exerciseName == 'Corrected Back Extension'),
      isTrue,
    );
    await tester.tap(find.byTooltip('Delete Corrected Back Extension'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CupertinoDialogAction, 'Delete'));
    await tester.pumpAndSettle();
    expect(
      (await database.exerciseCatalog(
        'Back',
      )).any((e) => e.exerciseName == 'Corrected Back Extension'),
      isFalse,
    );
    await _disposeApp(tester);
  });

  testWidgets('empty exercise group disables submission and supports adding', (
    tester,
  ) async {
    final database = await _pumpApp(tester);
    for (final exercise in await database.exerciseCatalog('Biceps')) {
      await database.deleteExercise(exercise.id);
    }
    await tester.tap(find.byIcon(CupertinoIcons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Biceps'));
    await tester.pumpAndSettle();
    expect(
      find.text('No exercises for this body part. Add one'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, CupertinoIcons.check_mark),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('No exercises for this body part. Add one'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add a new exercise type'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), 'My Curl');
    await tester.tap(find.byTooltip('Save exercise'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('My Curl'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, CupertinoIcons.check_mark),
          )
          .onPressed,
      isNotNull,
    );
    await _disposeApp(tester);
  });

  testWidgets('exercise library search filters by name and body part', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(CupertinoIcons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Manage exercises'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), 'Hamstrings');
    await tester.pumpAndSettle();
    expect(find.text('Seated Hamstring Curl'), findsOneWidget);
    expect(find.text('Stiff Leg Deadlift'), findsOneWidget);
    expect(find.text('Back Extensions'), findsNothing);
    await tester.enterText(find.byType(CupertinoTextField), 'no such exercise');
    await tester.pumpAndSettle();
    expect(find.text('No matching exercises'), findsOneWidget);
    await _disposeApp(tester);
  });

  testWidgets('small screen and larger text keep workout controls usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpApp(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(CupertinoIcons.add));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Biceps'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await _disposeApp(tester);
  });

  testWidgets('stats show all-time and latest-session heaviest sets', (
    tester,
  ) async {
    final database = await _pumpApp(tester);
    final current = DateTime.now();

    await database.saveExerciseSets(
      muscleGroup: 'Biceps',
      exerciseName: 'Barbell Curl',
      performedAt: current.subtract(const Duration(days: 7)),
      sets: const [ExerciseSetInput(reps: 6, weight: 50)],
    );
    await database.saveExerciseSets(
      muscleGroup: 'Biceps',
      exerciseName: 'Barbell Curl',
      performedAt: current,
      sets: const [
        ExerciseSetInput(reps: 10, weight: 40),
        ExerciseSetInput(reps: 8, weight: 45),
      ],
    );

    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    expect(find.text('Barbell Curl'), findsOneWidget);
    expect(find.textContaining('All-time: 6 x 50 lbs'), findsOneWidget);
    expect(find.textContaining('Recent: 8 x 45 lbs'), findsOneWidget);
    await _disposeApp(tester);
  });

  testWidgets('stats opens all instances newest first with every set', (
    tester,
  ) async {
    final database = await _pumpApp(tester);
    for (final record in [
      (DateTime(2026, 10, 8, 8), const [ExerciseSetInput(reps: 6, weight: 10)]),
      (DateTime(2026, 10, 9, 8), const [ExerciseSetInput(reps: 8, weight: 15)]),
      (
        DateTime(2026, 10, 9, 14),
        const [
          ExerciseSetInput(reps: 10, weight: 20.5),
          ExerciseSetInput(reps: 9, weight: 22.5),
        ],
      ),
    ]) {
      await database.saveExerciseSets(
        muscleGroup: 'Biceps',
        exerciseName: 'History Curl',
        performedAt: record.$1,
        sets: record.$2,
      );
    }
    await database.saveExerciseSets(
      muscleGroup: 'Biceps',
      exerciseName: 'History Curl',
      performedAt: DateTime(2026, 10, 9, 14),
      sets: const [ExerciseSetInput(reps: 12, weight: 25)],
    );
    await database.saveExerciseSets(
      muscleGroup: 'Chest',
      exerciseName: 'History Curl',
      performedAt: DateTime(2026, 10, 9, 15),
      sets: const [ExerciseSetInput(reps: 1, weight: 99)],
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History Curl').first);
    await tester.pumpAndSettle();
    expect(find.byType(ExerciseHistoryPage), findsOneWidget);
    expect(find.text('Biceps · 4 instances'), findsOneWidget);
    expect(find.text('10 reps × 20.5 lbs'), findsOneWidget);
    expect(find.text('9 reps × 22.5 lbs'), findsOneWidget);
    expect(find.text('8 reps × 15 lbs'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('10 reps × 20.5 lbs')).dy,
      lessThan(tester.getTopLeft(find.text('8 reps × 15 lbs')).dy),
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('6 reps × 10 lbs'), findsOneWidget);
    expect(find.text('1 reps × 99 lbs'), findsNothing);
    await tester.tap(find.byTooltip('Back to stats'));
    await tester.pumpAndSettle();
    expect(find.byType(Home), findsOneWidget);
    await _disposeApp(tester);
  });

  testWidgets('recent sessions summarize the latest five logged days', (
    tester,
  ) async {
    final database = await _pumpApp(tester);
    final current = DateTime.now();
    final today = DateTime(current.year, current.month, current.day, 12);

    for (var dayOffset = 0; dayOffset < 6; dayOffset++) {
      await database.saveExerciseSets(
        muscleGroup: dayOffset == 5 ? 'Misc.' : 'Biceps',
        exerciseName: 'Curl $dayOffset',
        performedAt: today.subtract(Duration(days: dayOffset)),
        sets: const [
          ExerciseSetInput(reps: 10, weight: 20),
          ExerciseSetInput(reps: 8, weight: 25),
        ],
      );
    }
    await database.saveExerciseSets(
      muscleGroup: 'Chest',
      exerciseName: 'Bench Press',
      performedAt: today,
      sets: const [ExerciseSetInput(reps: 6, weight: 40)],
    );

    await tester.pumpAndSettle();

    expect(find.text('Biceps • Chest'), findsOneWidget);
    expect(find.text('2 exercises\n3 sets'), findsOneWidget);
    expect(find.text('Misc.'), findsNothing);
    expect(find.text('6 Workouts'), findsOneWidget);
    await _disposeApp(tester);
  });

  testWidgets('tapping a recent session opens that session day', (
    tester,
  ) async {
    final database = await _pumpApp(tester);
    final sessionDay = DateTime(2026, 9, 6, 12);

    await database.saveExerciseSets(
      muscleGroup: 'Biceps',
      exerciseName: 'Past Curl',
      performedAt: sessionDay,
      sets: const [ExerciseSetInput(reps: 10, weight: 20)],
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.ancestor(
        of: find.text('9/6/2026').first,
        matching: find.byType(ListTile),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SessionInput), findsOneWidget);
    expect(find.text('Sep 6, 2026'), findsWidgets);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Past Curl'), findsOneWidget);
    await _disposeApp(tester);
  });
}

Future<AppDatabase> _pumpApp(WidgetTester tester) async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(database.close);
  await tester.pumpWidget(MyApp(database: database));
  return database;
}

Future<void> _disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}
