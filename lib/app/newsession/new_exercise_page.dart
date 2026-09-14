import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trackerd_app/app/app_database_scope.dart';
import 'package:trackerd_app/app/theme.dart';

class NewExercisePage extends StatefulWidget {
  const NewExercisePage({super.key});

  @override
  State<NewExercisePage> createState() => _NewExercisePageState();
}

class _NewExercisePageState extends State<NewExercisePage> {
  static const _muscleGroups = [
    'Biceps',
    'Triceps',
    'Shoulders',
    'Chest',
    'Back',
    'Quads',
    'Hamstrings',
    'Misc.',
  ];

  final _nameController = TextEditingController();
  String _muscleGroup = _muscleGroups.first;
  String? _nameError;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.keyboard_arrow_up, color: AppColors.primary),
        ),
        title: const Text('New Exercise'),
        actions: [
          IconButton(
            tooltip: 'Save exercise',
            onPressed: _isSaving ? null : _save,
            icon: const Icon(Icons.check, color: AppColors.primary),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            const _FieldLabel('BODY PART'),
            const SizedBox(height: 7),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: CupertinoColors.systemGrey6.resolveFrom(context),
              borderRadius: BorderRadius.circular(10),
              onPressed: _chooseMuscleGroup,
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.person_crop_circle,
                    size: 20,
                    color: CupertinoColors.secondaryLabel,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _muscleGroup,
                      style: TextStyle(
                        fontSize: 17,
                        color: CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.chevron_down,
                    size: 17,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _FieldLabel('EXERCISE NAME'),
            const SizedBox(height: 7),
            CupertinoTextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              placeholder: 'e.g. Preacher Curl',
              prefix: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(
                  CupertinoIcons.search,
                  size: 20,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              clearButtonMode: OverlayVisibilityMode.editing,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.resolveFrom(context),
                borderRadius: BorderRadius.circular(10),
              ),
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
              onSubmitted: (_) => _save(),
            ),
            if (_nameError != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 6),
                child: Text(
                  _nameError!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Enter an exercise name.');
      return;
    }

    setState(() => _isSaving = true);
    await AppDatabaseScope.of(context).addCustomExercise(
      muscleGroup: _muscleGroup,
      exerciseName: _nameController.text,
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _chooseMuscleGroup() async {
    final selected = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Choose a body part'),
        actions: [
          for (final group in _muscleGroups)
            CupertinoActionSheetAction(
              isDefaultAction: group == _muscleGroup,
              onPressed: () => Navigator.of(context).pop(group),
              child: Text(group),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _muscleGroup = selected);
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: CupertinoColors.secondaryLabel,
        ),
      ),
    );
  }
}
