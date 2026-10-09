import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trackerd_app/app/app_database_scope.dart';
import 'package:trackerd_app/data/database/app_database.dart';

import 'new_exercise_page.dart';
import '../theme.dart';
import '../components.dart';

class ExerciseCatalogPage extends StatefulWidget {
  const ExerciseCatalogPage({super.key});

  @override
  State<ExerciseCatalogPage> createState() => _ExerciseCatalogPageState();
}

class _ExerciseCatalogPageState extends State<ExerciseCatalogPage> {
  Stream<List<Exercise>>? _catalog;
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Delete ${exercise.exerciseName}?'),
        content: const Text(
          'This removes the exercise from the catalog. Your logged workouts will be kept.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
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
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back),
        ),
        actions: [
          IconButton(
            tooltip: 'Add a new exercise type',
            onPressed: () => _openEditor(),
            icon: const Icon(CupertinoIcons.add),
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
          final all = snapshot.data!;
          final exercises = all
              .where(
                (exercise) => '${exercise.exerciseName} ${exercise.muscleGroup}'
                    .toLowerCase()
                    .contains(_search.trim().toLowerCase()),
              )
              .toList();
          final groups = <String, List<Exercise>>{};
          for (final exercise in exercises) {
            groups.putIfAbsent(exercise.muscleGroup, () => []).add(exercise);
          }
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your exercise library',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${all.length} exercises · Tap an exercise to edit',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      CupertinoSearchTextField(
                        controller: _searchController,
                        placeholder: 'Find an exercise',
                        backgroundColor: AppColors.search,
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        onChanged: (value) => setState(() => _search = value),
                      ),
                    ],
                  ),
                ),
              ),
              if (groups.isEmpty)
                SliverToBoxAdapter(
                  child: AppEmptyState(
                    icon: CupertinoIcons.search,
                    title: all.isEmpty
                        ? 'Build your exercise library'
                        : 'No matching exercises',
                    message: all.isEmpty
                        ? 'Tap + to add your first exercise.'
                        : 'Try a different name or body part.',
                  ),
                ),
              for (final group in groups.entries) ...[
                SliverToBoxAdapter(child: AppSectionHeading(group.key)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.builder(
                    itemCount: group.value.length,
                    itemBuilder: (context, index) {
                      final exercise = group.value[index];
                      return Material(
                        color: AppColors.surface,
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.vertical(
                          top: index == 0
                              ? const Radius.circular(16)
                              : Radius.zero,
                          bottom: index == group.value.length - 1
                              ? const Radius.circular(16)
                              : Radius.zero,
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(exercise.exerciseName),
                              onTap: () => _openEditor(exercise),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit ${exercise.exerciseName}',
                                    onPressed: () => _openEditor(exercise),
                                    icon: const Icon(
                                      CupertinoIcons.pencil,
                                      size: 20,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete ${exercise.exerciseName}',
                                    onPressed: () => _delete(exercise),
                                    icon: const Icon(
                                      CupertinoIcons.minus_circle,
                                      size: 21,
                                      color: AppColors.destructive,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (index != group.value.length - 1)
                              const Divider(height: .5, indent: 16),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}
