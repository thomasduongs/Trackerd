import 'package:flutter/material.dart';
import 'package:trackerd_app/app/app_database_scope.dart';
import 'package:trackerd_app/data/database/app_database.dart';

import 'new_exercise_page.dart';

class ExerciseCatalogPage extends StatefulWidget {
  const ExerciseCatalogPage({super.key});

  @override
  State<ExerciseCatalogPage> createState() => _ExerciseCatalogPageState();
}

class _ExerciseCatalogPageState extends State<ExerciseCatalogPage> {
  Stream<List<Exercise>>? _catalog;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _catalog ??= AppDatabaseScope.of(context).watchExerciseCatalog();
  }

  void _openEditor([Exercise? exercise]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NewExercisePage(exercise: exercise),
      ),
    );
  }

  Future<void> _delete(Exercise exercise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${exercise.exerciseName}?'),
        content: const Text(
          'This removes the exercise from the catalog. Your logged workouts will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await AppDatabaseScope.of(context).deleteExercise(exercise.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete exercise. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        actions: [
          IconButton(
            tooltip: 'Add a new exercise type',
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<List<Exercise>>(
        stream: _catalog,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load exercises.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final exercises = snapshot.data!;
          if (exercises.isEmpty) {
            return const Center(
              child: Text('No exercises yet. Tap + to add one.'),
            );
          }
          return ListView.separated(
            itemCount: exercises.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ListTile(
                title: Text(exercise.exerciseName),
                subtitle: Text(exercise.muscleGroup),
                onTap: () => _openEditor(exercise),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit ${exercise.exerciseName}',
                      onPressed: () => _openEditor(exercise),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Delete ${exercise.exerciseName}',
                      onPressed: () => _delete(exercise),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
