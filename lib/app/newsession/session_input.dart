import 'package:flutter/material.dart';
import 'package:trackerd_app/app/app_database_scope.dart';
import 'package:trackerd_app/app/navigation/app_router.dart';
import 'package:trackerd_app/data/database/app_database.dart';

import '../theme.dart';
import 'exercise_catalog_page.dart';

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
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 50,
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_sharp,
                color: AppColors.primary,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Manage exercises',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ExerciseCatalogPage(),
                  ),
                ),
                icon: const Icon(Icons.edit_note, color: AppColors.primary),
              ),
              IconButton(
                tooltip: 'Add a new exercise type',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.newExercise),
                icon: const Icon(Icons.add, size: 30, color: AppColors.primary),
              ),
            ],
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeOut,
              opacity: _scrolled ? 1.0 : 0.0,
              child: Text(
                _formattedSessionDate,
                style: TextStyle(fontSize: 16),
              ),
            ),
            flexibleSpace: AnimatedContainer(
              duration: const Duration(milliseconds: 60),
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            sliver: SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedWidgetHeader(
                height: (MediaQuery.of(context).size.width - 30) / 2 + 30,
                child: Builder(
                  builder: (context) {
                    return Column(
                      children: [
                        Stack(
                          children: [
                            GridView.builder(
                              itemCount: _muscleGroups.length,
                              padding: EdgeInsets.zero,
                              primary: false,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                  ),
                              itemBuilder: (context, index) {
                                final muscleGroup = _muscleGroups[index];

                                return Semantics(
                                  button: true,
                                  label: 'Choose ${muscleGroup.name}',
                                  child: Material(
                                    color: AppColors.surface,
                                    child: InkWell(
                                      onTap: () =>
                                          Navigator.of(context).pushNamed(
                                            AppRoutes.sessionExercise,
                                            arguments: SessionExerciseRouteArgs(
                                              muscleGroup: muscleGroup.name,
                                              performedAt: widget.sessionDate,
                                            ),
                                          ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 8,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ColorFiltered(
                                              colorFilter:
                                                  const ColorFilter.matrix(
                                                    <double>[
                                                      0.2126,
                                                      0.7152,
                                                      0.0722,
                                                      0,
                                                      0,
                                                      0.2126,
                                                      0.7152,
                                                      0.0722,
                                                      0,
                                                      0,
                                                      0.2126,
                                                      0.7152,
                                                      0.0722,
                                                      0,
                                                      0,
                                                      0,
                                                      0,
                                                      0,
                                                      1,
                                                      0,
                                                    ],
                                                  ),
                                              child: Image.asset(
                                                muscleGroup.assetPath,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.contain,
                                                filterQuality:
                                                    FilterQuality.medium,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              muscleGroup.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            ...List.generate(3, (index) {
                              return Positioned(
                                left:
                                    (index + 1) *
                                    (1 / 4) *
                                    (MediaQuery.of(context).size.width - 30),
                                top: 15,
                                height:
                                    MediaQuery.of(context).size.width * .5 - 45,
                                child: const VerticalDivider(
                                  thickness: 1,
                                  color: AppColors.search,
                                  width: 1,
                                ),
                              );
                            }),

                            Positioned(
                              top: (MediaQuery.of(context).size.width - 30) / 4,
                              left: 0,
                              right: 0,
                              child: const Divider(
                                thickness: 1,
                                color: AppColors.search,
                                indent: 15,
                                endIndent: 15,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(30, 5, 15, 15),
              child: Text(
                _formattedSessionDate,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
            sliver: SliverToBoxAdapter(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
                          message: 'No exercises recorded today.',
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
      bottomNavigationBar: Container(
        color: AppColors.bar,
        child: SafeArea(
          top: false,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.search, width: 0.8),
              ),
            ),
            child: BottomAppBar(
              color: AppColors.bar,
              padding: EdgeInsets.zero,
              child: StreamBuilder<List<ExerciseEntry>>(
                stream: _todayExercises(context),
                builder: (context, snapshot) {
                  final entries = snapshot.data ?? const <ExerciseEntry>[];
                  final exercises = _groupExerciseSets(entries);
                  final setCount = entries
                      .where((entry) => entry.reps > 0)
                      .length;
                  final exerciseLabel = exercises.length == 1
                      ? 'Exercise'
                      : 'Exercises';
                  final setLabel = setCount == 1 ? 'Set' : 'Sets';

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${exercises.length} $exerciseLabel'),
                      Text(
                        '$setCount $setLabel',
                        style: const TextStyle(color: AppColors.mutedText),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
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
            onPressed: onDelete,
            icon: const Icon(Icons.remove, size: 22, color: AppColors.primary),
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
    return SizedBox(
      height: maxExtent,
      child: Column(
        children: [
          Expanded(
            child: AnimatedTopClip(
              overlaps: shrinkOffset > 7,
              child: Container(color: AppColors.surface, child: child),
            ),
          ),
          Container(height: 30, color: AppColors.background),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_PinnedWidgetHeader oldDelegate) => false;
}

class AnimatedTopClip extends StatelessWidget {
  const AnimatedTopClip({
    super.key,
    required this.overlaps,
    required this.child,
    this.radius = 12,
    this.duration = const Duration(milliseconds: 60),
  });

  final bool overlaps;
  final Widget child;
  final double radius;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(overlaps),
      tween: Tween(
        begin: overlaps ? radius : 0.0,
        end: overlaps ? 0.0 : radius,
      ),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, r, _) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(r),
            bottom: Radius.circular(radius),
          ),
          child: child,
        );
      },
    );
  }
}
