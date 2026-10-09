import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trackerd_app/app/app_database_scope.dart';
import 'package:trackerd_app/app/navigation/app_router.dart';
import 'package:trackerd_app/data/database/app_database.dart';

import '../theme.dart';
import 'exercise_catalog_page.dart';
import '../components.dart';

class SessionInput extends StatefulWidget {
  SessionInput({super.key, DateTime? sessionDate})
    : sessionDate = sessionDate ?? DateTime.now();

  final DateTime sessionDate;
  @override
  State<SessionInput> createState() => _SessionInputState();
}

class _SessionInputState extends State<SessionInput> {
  static const _muscleGroups = [
    _MuscleGroup('Biceps', 'lib/app/assets/muscles/biceps.png'),
    _MuscleGroup('Triceps', 'lib/app/assets/muscles/triceps.png'),
    _MuscleGroup('Shoulders', 'lib/app/assets/muscles/shoulders.png'),
    _MuscleGroup('Chest', 'lib/app/assets/muscles/chest.png'),
    _MuscleGroup('Back', 'lib/app/assets/muscles/back.png'),
    _MuscleGroup('Quads', 'lib/app/assets/muscles/quads.png'),
    _MuscleGroup('Hamstrings', 'lib/app/assets/muscles/hamstrings.png'),
    _MuscleGroup('Misc.', 'lib/app/assets/muscles/abs.png'),
  ];

  final _scrollController = ScrollController();
  Stream<List<ExerciseEntry>>? _todayExerciseEntries;
  DateTime? _todayDate;
  bool _scrolled = false;
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final next = _scrollController.offset > 56; // threshold
      if (next != _scrolled) setState(() => _scrolled = next);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(12) / 12;
    final columns = MediaQuery.sizeOf(context).width < 360 || textScale > 1.35
        ? 2
        : 4;
    final cellHeight = columns == 4 ? 104.0 : 100.0 + 20 * textScale;
    final grid = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GridView.builder(
        itemCount: _muscleGroups.length,
        padding: EdgeInsets.zero,
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisExtent: cellHeight,
        ),
        itemBuilder: (context, index) {
          final group = _muscleGroups[index];
          return _MuscleGroupTile(
            group: group,
            rightBorder: (index + 1) % columns != 0,
            bottomBorder: index < _muscleGroups.length - columns,
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.sessionExercise,
              arguments: SessionExerciseRouteArgs(
                muscleGroup: group.name,
                performedAt: widget.sessionDate,
              ),
            ),
          );
        },
      ),
    );
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 52,
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(CupertinoIcons.back, color: AppColors.primary),
            ),
            actions: [
              IconButton(
                tooltip: 'Manage exercises',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ExerciseCatalogPage(),
                  ),
                ),
                icon: const Icon(
                  CupertinoIcons.pencil,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                tooltip: 'Add a new exercise type',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.newExercise),
                icon: const Icon(
                  CupertinoIcons.add,
                  size: 25,
                  color: AppColors.primary,
                ),
              ),
            ],
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              opacity: _scrolled ? 1.0 : 0.0,
              child: Text(
                _formattedSessionDate,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            flexibleSpace: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: _scrolled ? AppColors.bar : AppColors.background,
                border: Border(
                  bottom: BorderSide(
                    color: _scrolled ? AppColors.search : AppColors.background,
                    width: .8,
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: AppSectionHeading(
              'Choose a body part',
              subtitle: 'Select an exercise to add to your session.',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            sliver: columns == 4
                ? SliverPersistentHeader(
                    pinned: true,
                    delegate: _PinnedWidgetHeader(
                      height: cellHeight * 2 + 20,
                      child: grid,
                    ),
                  )
                : SliverToBoxAdapter(child: grid),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                _formattedSessionDate,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverToBoxAdapter(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColoredBox(
                  color: AppColors.surface,
                  child: StreamBuilder<List<ExerciseEntry>>(
                    stream: _todayExercises(context),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const _ListMessage(
                          message: 'Could not load today\'s exercises.',
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final exercises = _groupExerciseSets(snapshot.data!);
                      if (exercises.isEmpty) {
                        return const _ListMessage(
                          message:
                              'No exercises recorded for this session. Choose a body part to start.',
                        );
                      }

                      return ListView.separated(
                        primary: false,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: exercises.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: AppColors.search,
                        ),
                        itemBuilder: (context, index) {
                          final exercise = exercises[index];
                          return _ExerciseListTile(
                            exercise: exercise,
                            onDelete: () => AppDatabaseScope.of(context)
                                .deleteExerciseSubmission(
                                  exerciseName: exercise.name,
                                  performedAt: exercise.performedAt,
                                ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: StreamBuilder<List<ExerciseEntry>>(
        stream: _todayExercises(context),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? const <ExerciseEntry>[];
          final count = _groupExerciseSets(entries).length;
          final sets = entries.where((entry) => entry.reps > 0).length;
          return AppSummaryBar(
            primary: '$count ${count == 1 ? 'Exercise' : 'Exercises'}',
            secondary: '$sets ${sets == 1 ? 'Set' : 'Sets'}',
          );
        },
      ),
    );
  }

  Stream<List<ExerciseEntry>> _todayExercises(BuildContext context) {
    final day = DateTime(
      widget.sessionDate.year,
      widget.sessionDate.month,
      widget.sessionDate.day,
    );
    if (_todayDate != day) {
      _todayDate = day;
      _todayExerciseEntries = AppDatabaseScope.of(
        context,
      ).watchExercisesForDate(day);
    }
    return _todayExerciseEntries!;
  }

  String get _formattedSessionDate {
    return '${months[widget.sessionDate.month - 1]} ${widget.sessionDate.day}, ${widget.sessionDate.year}';
  }
}

List<_ExerciseSummary> _groupExerciseSets(List<ExerciseEntry> entries) {
  final grouped = <String, _ExerciseSummary>{};

  for (final entry in entries) {
    final key =
        '${entry.exerciseName}-${entry.performedAt.microsecondsSinceEpoch}';
    grouped.putIfAbsent(
      key,
      () => _ExerciseSummary(
        name: entry.exerciseName,
        performedAt: entry.performedAt,
        sets: [],
      ),
    );
    grouped[key]!.sets.add(entry);
  }

  return grouped.values.toList();
}

class _ExerciseSummary {
  _ExerciseSummary({
    required this.name,
    required this.performedAt,
    required this.sets,
  });

  final String name;
  final DateTime performedAt;
  final List<ExerciseEntry> sets;
}

class _ExerciseListTile extends StatelessWidget {
  const _ExerciseListTile({required this.exercise, required this.onDelete});

  final _ExerciseSummary exercise;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final completedSets = exercise.sets.where((set) => set.reps > 0).toList();
    ExerciseEntry? heaviestSet;
    for (final set in completedSets) {
      if (heaviestSet == null ||
          set.weightTimesTen > heaviestSet.weightTimesTen) {
        heaviestSet = set;
      }
    }
    final setLabel = completedSets.length == 1 ? 'set' : 'sets';

    return Stack(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 52, 8),
          title: Text(exercise.name),
          subtitle: Text(
            '${completedSets.length} $setLabel  •  '
            'Reps at max: ${heaviestSet?.reps ?? 0} \n'
            'Max weight: ${_formatWeight((heaviestSet?.weightTimesTen ?? 0) / 10)} lbs',
          ),
        ),
        Positioned(
          top: 2,
          right: 4,
          child: IconButton(
            tooltip: 'Delete ${exercise.name}',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog.adaptive(
                  title: Text('Remove ${exercise.name}?'),
                  content: const Text(
                    'This removes its sets from this session.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Remove',
                        style: TextStyle(color: AppColors.destructive),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) await onDelete();
            },
            icon: const Icon(
              CupertinoIcons.minus_circle,
              size: 22,
              color: AppColors.destructive,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatWeight(double weight) {
    return weight == weight.roundToDouble()
        ? weight.toStringAsFixed(0)
        : weight.toStringAsFixed(1);
  }
}

class _ListMessage extends StatelessWidget {
  const _ListMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: AppColors.mutedText),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _MuscleGroup {
  const _MuscleGroup(this.name, this.assetPath);

  final String name;
  final String assetPath;
}

class _PinnedWidgetHeader extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _PinnedWidgetHeader({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // The grid owns its rounded clip. An opaque background masks scrolling
    // content without painting a second white shape behind the grid corners.
    return ColoredBox(
      color: AppColors.background,
      child: SizedBox(
        height: maxExtent,
        child: Column(
          children: [
            Expanded(child: child),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_PinnedWidgetHeader oldDelegate) =>
      height != oldDelegate.height || child != oldDelegate.child;
}

class _MuscleGroupTile extends StatelessWidget {
  const _MuscleGroupTile({
    required this.group,
    required this.rightBorder,
    required this.bottomBorder,
    required this.onTap,
  });
  final _MuscleGroup group;
  final bool rightBorder;
  final bool bottomBorder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Choose ${group.name}',
    excludeSemantics: true,
    child: Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: rightBorder
                  ? const BorderSide(color: AppColors.search, width: .5)
                  : BorderSide.none,
              bottom: bottomBorder
                  ? const BorderSide(color: AppColors.search, width: .5)
                  : BorderSide.none,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  .2126,
                  .7152,
                  .0722,
                  0,
                  0,
                  .2126,
                  .7152,
                  .0722,
                  0,
                  0,
                  .2126,
                  .7152,
                  .0722,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ]),
                child: Image.asset(
                  group.assetPath,
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                group.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -.15,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
