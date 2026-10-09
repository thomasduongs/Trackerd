import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trackerd_app/data/database/app_database.dart';

import 'app_database_scope.dart';
import 'components.dart';
import 'theme.dart';

class ExerciseHistoryPage extends StatefulWidget {
  const ExerciseHistoryPage({
    super.key,
    required this.exerciseName,
    required this.muscleGroup,
  });

  final String exerciseName;
  final String muscleGroup;

  @override
  State<ExerciseHistoryPage> createState() => _ExerciseHistoryPageState();
}

class _ExerciseHistoryPageState extends State<ExerciseHistoryPage> {
  Stream<List<ExerciseEntry>>? _history;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _history ??= AppDatabaseScope.of(context).watchExerciseHistory(
      muscleGroup: widget.muscleGroup,
      exerciseName: widget.exerciseName,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Exercise History'),
      leading: IconButton(
        tooltip: 'Back to stats',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(CupertinoIcons.back),
      ),
    ),
    body: StreamBuilder<List<ExerciseEntry>>(
      stream: _history,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Could not load exercise history.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        // Each submission contains one entry per set. Keep those sets together,
        // while retaining separate instances even when logged on the same day.
        final submissions = <String, List<ExerciseEntry>>{};
        for (final entry in snapshot.data!) {
          final submissionId = entry.id.substring(0, entry.id.lastIndexOf('-'));
          submissions.putIfAbsent(submissionId, () => []).add(entry);
        }
        final instances = submissions.entries.toList()
          ..sort((a, b) {
            final dateOrder = b.value.first.performedAt.compareTo(
              a.value.first.performedAt,
            );
            return dateOrder != 0 ? dateOrder : b.key.compareTo(a.key);
          });
        for (final instance in instances) {
          instance.value.sort((a, b) => _setNumber(a).compareTo(_setNumber(b)));
        }
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.exerciseName,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.muscleGroup} · ${instances.length} ${instances.length == 1 ? 'instance' : 'instances'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'MOST RECENT FIRST',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
            if (instances.isEmpty)
              const SliverToBoxAdapter(
                child: AppEmptyState(
                  icon: CupertinoIcons.calendar,
                  title: 'No history yet',
                  message: 'Logged sets for this exercise will appear here.',
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList.builder(
                itemCount: instances.length,
                itemBuilder: (context, index) => _HistoryCard(
                  date: instances[index].value.first.performedAt,
                  sets: instances[index].value,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  static int _setNumber(ExerciseEntry entry) =>
      int.tryParse(entry.id.split('-').last) ?? 0;
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.date, required this.sets});
  final DateTime date;
  final List<ExerciseEntry> sets;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            MaterialLocalizations.of(context).formatMediumDate(date),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date))} · ${sets.length} ${sets.length == 1 ? 'set' : 'sets'}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 13),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          for (final indexed in sets.indexed)
            Padding(
              padding: EdgeInsets.only(
                bottom: indexed.$1 == sets.length - 1 ? 0 : 10,
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 24,
                runSpacing: 4,
                children: [
                  Text(
                    'Set ${indexed.$1 + 1}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${indexed.$2.reps} reps × ${_weight(indexed.$2.weightTimesTen)} lbs',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );

  static String _weight(int timesTen) => timesTen % 10 == 0
      ? '${timesTen ~/ 10}'
      : (timesTen / 10).toStringAsFixed(1);
}
