import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackerd_app/app/app.dart';
import 'package:trackerd_app/app/newsession/session_exercise.dart';
import 'package:trackerd_app/app/newsession/session_input.dart';
import 'package:trackerd_app/data/database/app_database.dart';
import 'package:trackerd_app/main.dart';

void main() {
  testWidgets('starts on the home page', (tester) async {
    await _pumpApp(tester);

    expect(find.byType(Home), findsOneWidget);
    expect(find.text('Workout Tracker'), findsWidgets);
    await _disposeApp(tester);
  });

  testWidgets('add and back buttons navigate between home and session input', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byType(SessionInput), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_sharp));
    await tester.pumpAndSettle();
    expect(find.byType(Home), findsOneWidget);
    await _disposeApp(tester);
  });

  testWidgets('muscle group opens the exercise page', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.add));
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

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Biceps'));
    await tester.pumpAndSettle();
    await tester.drag(find.text('0').first, const Offset(0, -60));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.check));
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
      exerciseName: 'Older Exercise',
      performedAt: now.subtract(const Duration(minutes: 10)),
      sets: const [ExerciseSetInput(reps: 8, weight: 20)],
    );
    await database.saveExerciseSets(
      exerciseName: 'Newest Exercise',
      performedAt: now,
      sets: const [
        ExerciseSetInput(reps: 15, weight: 20),
        ExerciseSetInput(reps: 8, weight: 30),
      ],
    );
    await database.saveExerciseSets(
      exerciseName: 'Yesterday Exercise',
      performedAt: now.subtract(const Duration(days: 1)),
      sets: const [ExerciseSetInput(reps: 12, weight: 15)],
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Newest Exercise'), findsOneWidget);
    expect(find.text('Older Exercise'), findsOneWidget);
    expect(find.text('Yesterday Exercise'), findsNothing);
    expect(
      find.text('2 sets  •  Reps at max: 8  •  Max weight: 30'),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.text('Newest Exercise')).dy,
      lessThan(tester.getTopLeft(find.text('Older Exercise')).dy),
    );
    await _disposeApp(tester);
  });

  testWidgets('adds a custom exercise from the sliding page', (tester) async {
    final database = await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add a new exercise type'));
    await tester.pumpAndSettle();

    expect(find.text('New Exercise'), findsOneWidget);
    await tester.enterText(find.byType(CupertinoTextField), 'Preacher Curl');
    await tester.tap(find.byTooltip('Save exercise'));
    await tester.pumpAndSettle();

    expect(find.byType(SessionInput), findsOneWidget);
    expect(await database.customExerciseNames('Biceps'), ['Preacher Curl']);
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
