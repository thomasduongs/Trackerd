// Used only when creating or upgrading the exercise catalog. The UI reads the
// database, so edits and deletions are never replaced by these seed values.
const defaultExercises = <String, List<String>>{
  'Biceps': [
    'Standing Dumbbell Curl',
    'Seated Dumbbell Curl',
    'Cable Reverse Curl',
    'Machine Preacher Curl',
    'Dumbbell Preacher Curl',
    'EZ-Bar Preacher Curl',
  ],
  'Triceps': ['Single-Arm Tricep Extension', 'Seated Machine Dip', 'Dip'],
  'Shoulders': [
    'Dumbbell Shoulder Press',
    'Cable Lateral Raise',
    'Seated Machine Lateral Raise',
    'Cable Rear Delt Fly',
  ],
  'Chest': [
    'Dumbbell Incline Press',
    'Pec Dec Chest Fly',
    'Dip',
    'Smith Machine Bench Press',
  ],
  'Back': [
    'Pull-Up',
    'Lat Pulldown',
    'One-Arm Chest-Supported Machine Row',
    'Chest-Supported Machine Row',
    'T-Bar Row',
    'Back Extensions',
  ],
  'Quads': ['Barbell Back Squat', 'Leg Extension', 'Single-Leg Leg Extension'],
  'Hamstrings': ['Stiff Leg Deadlift', 'Seated Hamstring Curl'],
  'Misc.': [
    'Ab Crunch Machine',
    'Cable Forearm Curls',
    'Crunch',
    'Leg Raise',
    'Machine Calf Raises',
    'Single-Leg Machine Calf Raises',
  ],
};
