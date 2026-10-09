import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trackerd_app/app/app_database_scope.dart';
import 'package:trackerd_app/app/theme.dart';
import 'package:trackerd_app/data/database/app_database.dart';
import 'exercise_catalog_page.dart';

class SessionExercise extends StatefulWidget {
  const SessionExercise({
    super.key,
    required this.muscleGroup,
    required this.performedAt,
  });

  final String muscleGroup;
  final DateTime performedAt;

  @override
  State<SessionExercise> createState() => _SessionExerciseState();
}

class _SessionExerciseState extends State<SessionExercise> {
  final _reps = List<int>.filled(4, 0);
  final _weights = List<double>.filled(4, 0);
  List<Exercise> _exercises = const [];
  bool _isLoading = true;
  bool _loadFailed = false;
  int _pickerRevision = 0;
  late final List<FixedExtentScrollController> _repsControllers;
  late final List<FixedExtentScrollController> _weightControllers;
  int _selectedExercise = 0;
  bool _isSubmitting = false;
  bool _loadedExercises = false;

  @override
  void initState() {
    super.initState();
    _repsControllers = List.generate(4, (_) => FixedExtentScrollController());
    _weightControllers = List.generate(4, (_) => FixedExtentScrollController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedExercises) return;
    _loadedExercises = true;
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final exercises = await AppDatabaseScope.of(
        context,
      ).exerciseCatalog(widget.muscleGroup);
      if (!mounted) return;
      setState(() {
        _exercises = exercises;
        _selectedExercise = 0;
        _pickerRevision++;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _manageExercises() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ExerciseCatalogPage()),
    );
    if (mounted) await _loadExercises();
  }

  @override
  void dispose() {
    for (final controller in _repsControllers) {
      controller.dispose();
    }
    for (final controller in _weightControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Back to muscle groups',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_sharp,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Manage exercises',
            onPressed: _isSubmitting ? null : _manageExercises,
            icon: const Icon(Icons.edit_note, color: AppColors.primary),
          ),
          IconButton(
            tooltip: 'Submit exercise',
            onPressed:
                _isSubmitting || _isLoading || _loadFailed || _exercises.isEmpty
                ? null
                : _submitExercise,
            icon: const Icon(Icons.check, size: 30, color: AppColors.primary),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadFailed
                    ? Center(
                        child: TextButton(
                          onPressed: _loadExercises,
                          child: const Text('Could not load exercises. Retry'),
                        ),
                      )
                    : _exercises.isEmpty
                    ? Center(
                        child: TextButton(
                          onPressed: _manageExercises,
                          child: const Text(
                            'No exercises for this body part. Add one',
                          ),
                        ),
                      )
                    : CupertinoPicker(
                        key: ValueKey(_pickerRevision),
                        itemExtent: 40,
                        diameterRatio: 1.4,
                        squeeze: 1,
                        useMagnifier: true,
                        magnification: 1.05,
                        onSelectedItemChanged: (index) {
                          setState(() => _selectedExercise = index);
                        },
                        children: _exercises
                            .map(
                              (exercise) => Center(
                                child: Text(
                                  exercise.exerciseName,
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
              const SizedBox(height: 40),
              const Row(
                children: [
                  SizedBox(width: 48),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                'Reps',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(width: 1),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Weight',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 36),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const maximumRowsHeight = (90.0 * 4) + (8.0 * 3);
                    final rowsHeight = constraints.maxHeight < maximumRowsHeight
                        ? constraints.maxHeight
                        : maximumRowsHeight;

                    return Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: rowsHeight,
                        child: Column(
                          children: List.generate(4, (index) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == 3 ? 0 : 8,
                                ),
                                child: _SetRow(
                                  number: index + 1,
                                  repsController: _repsControllers[index],
                                  weightController: _weightControllers[index],
                                  onRepsChanged: (value) =>
                                      _updateRepsFrom(index, value),
                                  onWeightChanged: (value) =>
                                      _updateWeightFrom(index, value),
                                  onClear: index == 0
                                      ? null
                                      : () => _clearSet(index),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitExercise() async {
    if (_isSubmitting || _isLoading || _loadFailed || _exercises.isEmpty) {
      return;
    }
    final completedSets = [
      for (var index = 0; index < _reps.length; index++)
        if (_reps[index] > 0)
          ExerciseSetInput(reps: _reps[index], weight: _weights[index]),
    ];

    if (completedSets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select reps for at least one set.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await AppDatabaseScope.of(context).saveExerciseSets(
        muscleGroup: widget.muscleGroup,
        exerciseName: _exercises[_selectedExercise].exerciseName,
        performedAt: widget.performedAt,
        sets: completedSets,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save exercise. Try again.')),
      );
    }
  }

  void _updateRepsFrom(int startingIndex, int value) {
    setState(() {
      for (var index = startingIndex; index < _reps.length; index++) {
        _reps[index] = value;
        if (index > startingIndex && _repsControllers[index].hasClients) {
          _repsControllers[index].jumpToItem(value);
        }
      }
    });
  }

  void _updateWeightFrom(int startingIndex, double value) {
    setState(() {
      for (var index = startingIndex; index < _weights.length; index++) {
        _weights[index] = value;
        if (index > startingIndex && _weightControllers[index].hasClients) {
          _weightControllers[index].jumpToItem((value / 2.5).round());
        }
      }
    });
  }

  void _clearSet(int index) {
    setState(() {
      _reps[index] = 0;
      _weights[index] = 0;
      if (_repsControllers[index].hasClients) {
        _repsControllers[index].jumpToItem(0);
      }
      if (_weightControllers[index].hasClients) {
        _weightControllers[index].jumpToItem(0);
      }
    });
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.number,
    required this.repsController,
    required this.weightController,
    required this.onRepsChanged,
    required this.onWeightChanged,
    required this.onClear,
  });

  final int number;
  final FixedExtentScrollController repsController;
  final FixedExtentScrollController weightController;
  final ValueChanged<int> onRepsChanged;
  final ValueChanged<double> onWeightChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            '$number:',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 23),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NumberPicker(
                      controller: repsController,
                      itemCount: 21,
                      labelBuilder: (index) => '$index',
                      onChanged: (index) => onRepsChanged(index),
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppColors.search,
                  ),
                  Expanded(
                    child: _NumberPicker(
                      controller: weightController,
                      itemCount: 201,
                      labelBuilder: (index) => _formatWeight(index * 2.5),
                      onChanged: (index) => onWeightChanged(index * 2.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: onClear == null
              ? null
              : IconButton(
                  tooltip: 'Clear set $number',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.remove,
                    size: 20,
                    color: AppColors.primary,
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

class _NumberPicker extends StatelessWidget {
  const _NumberPicker({
    required this.controller,
    required this.itemCount,
    required this.labelBuilder,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker.builder(
      scrollController: controller,
      itemExtent: 34,
      diameterRatio: 1.2,
      squeeze: 1,
      useMagnifier: true,
      magnification: 1.08,
      selectionOverlay: const SizedBox.shrink(),
      changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
      onSelectedItemChanged: onChanged,
      childCount: itemCount,
      itemBuilder: (_, index) => Center(
        child: Text(
          labelBuilder(index),
          style: const TextStyle(fontSize: 21, color: AppColors.mutedText),
        ),
      ),
    );
  }
}
