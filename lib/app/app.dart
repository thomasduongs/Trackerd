import 'package:flutter/material.dart';
import 'package:trackerd_app/app/app_database_scope.dart';
import 'package:trackerd_app/app/navigation/app_router.dart';
import 'package:trackerd_app/data/database/app_database.dart';
import 'theme.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scrollController = ScrollController();
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
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                tooltip: 'Start a new session',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.sessionInput),
                icon: const Icon(Icons.add, size: 30, color: AppColors.primary),
              ),
            ],
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeOut,
              opacity: _scrolled ? 1.0 : 0.0,
              child: const Text(
                'Workout Tracker',
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
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 5, 15, 15),
              child: Text(
                'Workout Tracker',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Recent Sessions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    stream: AppDatabaseScope.of(context).watchAllExercises(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final sessions = _recentSessions(snapshot.data!);
                      if (sessions.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No sessions recorded yet.',
                              style: TextStyle(color: AppColors.mutedText),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        primary: false,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sessions.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: AppColors.search,
                        ),
                        itemBuilder: (context, index) => _RecentSessionTile(
                          session: sessions[index],
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.sessionInput,
                            arguments: sessions[index].date,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Stats',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    stream: AppDatabaseScope.of(context).watchAllExercises(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final stats = _exerciseStats(snapshot.data!);
                      if (stats.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No exercise history yet.',
                              style: TextStyle(color: AppColors.mutedText),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        primary: false,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: stats.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: AppColors.search,
                        ),
                        itemBuilder: (context, index) =>
                            _ExerciseStatTile(stat: stats[index]),
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
                stream: AppDatabaseScope.of(context).watchAllExercises(),
                builder: (context, snapshot) {
                  final workoutDays = snapshot.hasData
                      ? _loggedWorkoutDays(snapshot.data!)
                      : 0;
                  final workoutLabel = workoutDays == 1
                      ? 'Workout'
                      : 'Workouts';

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$workoutDays $workoutLabel'),
                      Text(
                        '${months[DateTime.now().month - 1]} ${DateTime.now().day}, ${DateTime.now().year}',
                        style: TextStyle(color: AppColors.mutedText),
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
}

const _muscleGroupOrder = [
  'Biceps',
  'Triceps',
  'Shoulders',
  'Chest',
  'Back',
  'Quads',
  'Hamstrings',
  'Misc.',
];

List<_SessionDaySummary> _recentSessions(List<ExerciseEntry> entries) {
  final sessionsByDay = <DateTime, List<ExerciseEntry>>{};
  for (final entry in entries) {
    final day = DateTime(
      entry.performedAt.year,
      entry.performedAt.month,
      entry.performedAt.day,
    );
    sessionsByDay.putIfAbsent(day, () => []).add(entry);
  }

  final summaries = sessionsByDay.entries.map((entry) {
    final bodyParts = entry.value.map((set) => set.muscleGroup).toSet().toList()
      ..sort((left, right) => _groupRank(left).compareTo(_groupRank(right)));
    final exercises = entry.value
        .map(
          (set) =>
              '${set.muscleGroup}\u0000${set.exerciseName}\u0000${set.performedAt.microsecondsSinceEpoch}',
        )
        .toSet();

    return _SessionDaySummary(
      date: entry.key,
      bodyParts: bodyParts,
      exerciseCount: exercises.length,
      setCount: entry.value.where((set) => set.reps > 0).length,
    );
  }).toList()..sort((left, right) => right.date.compareTo(left.date));

  return summaries.take(5).toList();
}

int _loggedWorkoutDays(List<ExerciseEntry> entries) {
  return {
    for (final entry in entries)
      if (entry.reps > 0)
        DateTime(
          entry.performedAt.year,
          entry.performedAt.month,
          entry.performedAt.day,
        ),
  }.length;
}

List<_ExerciseStat> _exerciseStats(List<ExerciseEntry> entries) {
  final grouped = <String, List<ExerciseEntry>>{};
  for (final entry in entries) {
    grouped
        .putIfAbsent(
          '${entry.muscleGroup}\u0000${entry.exerciseName}',
          () => [],
        )
        .add(entry);
  }

  final stats = grouped.values.map((sets) {
    final latestTime = sets
        .map((set) => set.performedAt)
        .reduce((latest, date) => date.isAfter(latest) ? date : latest);
    final latestSessionSets = sets
        .where((set) => set.performedAt == latestTime)
        .toList();
    final allTimeBest = _heaviestSet(sets);
    final recentBest = _heaviestSet(latestSessionSets);

    return _ExerciseStat(
      muscleGroup: sets.first.muscleGroup,
      exerciseName: sets.first.exerciseName,
      allTimeBest: allTimeBest,
      recentBest: recentBest,
    );
  }).toList();

  stats.sort((left, right) {
    final groupDifference = _groupRank(
      left.muscleGroup,
    ).compareTo(_groupRank(right.muscleGroup));
    if (groupDifference != 0) return groupDifference;
    return left.exerciseName.toLowerCase().compareTo(
      right.exerciseName.toLowerCase(),
    );
  });
  return stats;
}

ExerciseEntry _heaviestSet(List<ExerciseEntry> sets) {
  return sets.reduce(
    (heaviest, set) =>
        set.weightTimesTen > heaviest.weightTimesTen ? set : heaviest,
  );
}

int _groupRank(String muscleGroup) {
  final index = _muscleGroupOrder.indexOf(muscleGroup);
  return index == -1 ? _muscleGroupOrder.length : index;
}

class _ExerciseStat {
  const _ExerciseStat({
    required this.muscleGroup,
    required this.exerciseName,
    required this.allTimeBest,
    required this.recentBest,
  });

  final String muscleGroup;
  final String exerciseName;
  final ExerciseEntry allTimeBest;
  final ExerciseEntry recentBest;
}

class _SessionDaySummary {
  const _SessionDaySummary({
    required this.date,
    required this.bodyParts,
    required this.exerciseCount,
    required this.setCount,
  });

  final DateTime date;
  final List<String> bodyParts;
  final int exerciseCount;
  final int setCount;
}

class _RecentSessionTile extends StatelessWidget {
  const _RecentSessionTile({required this.session, required this.onTap});

  final _SessionDaySummary session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final exerciseLabel = session.exerciseCount == 1 ? 'exercise' : 'exercises';
    final setLabel = session.setCount == 1 ? 'set' : 'sets';

    return ListTile(
      onTap: onTap,
      title: Text(_formatDate(session.date)),
      subtitle: Text(session.bodyParts.join(' • ')),
      trailing: Text(
        '${session.exerciseCount} $exerciseLabel\n${session.setCount} $setLabel',
        textAlign: TextAlign.right,
        style: const TextStyle(color: AppColors.mutedText),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _ExerciseStatTile extends StatelessWidget {
  const _ExerciseStatTile({required this.stat});

  final _ExerciseStat stat;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(stat.exerciseName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stat.muscleGroup),
          const SizedBox(height: 3),
          _StatMetricRow(
            label: 'All-time: ${_setLabel(stat.allTimeBest)}',
            date: _formatDate(stat.allTimeBest.performedAt),
          ),
          _StatMetricRow(
            label: 'Recent: ${_setLabel(stat.recentBest)}',
            date: _formatDate(stat.recentBest.performedAt),
          ),
        ],
      ),
    );
  }

  String _setLabel(ExerciseEntry set) {
    final weight = set.weightTimesTen / 10;
    final formattedWeight = weight == weight.roundToDouble()
        ? weight.toStringAsFixed(0)
        : weight.toStringAsFixed(1);
    return '${set.reps} x $formattedWeight lbs';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _StatMetricRow extends StatelessWidget {
  const _StatMetricRow({required this.label, required this.date});

  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 8),
        Text(date, style: const TextStyle(color: AppColors.mutedText)),
      ],
    );
  }
}
