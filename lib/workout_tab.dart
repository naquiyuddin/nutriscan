import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'local_storage_service.dart';
import 'theme.dart';

// --- EXERCISE MODEL ---
class Exercise {
  final String name;
  final String primaryMuscle;
  final double met; // MET value for calorie calc
  final IconData icon;
  final List<String> formCues;
  final List<String> commonMistakes;
  final String breathingTip;

  Exercise({
    required this.name,
    required this.primaryMuscle,
    required this.met,
    required this.icon,
    required this.formCues,
    required this.commonMistakes,
    required this.breathingTip,
  });
}

// --- WORKOUT ROUTINE MODEL ---
class WorkoutRoutine {
  final String id;
  final String name;
  final List<String> muscles;
  final String difficulty;
  final int durationMinutes;
  final List<Exercise> exercises;
  final IconData icon;

  WorkoutRoutine({
    required this.id,
    required this.name,
    required this.muscles,
    required this.difficulty,
    required this.durationMinutes,
    required this.exercises,
    required this.icon,
  });

  double get minutesPerExercise => durationMinutes / exercises.length;
}

// --- BODY STATS (pulled from the saved profile) ---
class BodyStats {
  final double weightKg;
  final double heightCm;
  final int age;
  final String gender;

  const BodyStats({
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
  });

  factory BodyStats.fromProfile(UserProfile? u) => BodyStats(
        weightKg: u?.weightKg ?? 75.0,
        heightCm: u?.heightCm ?? 175.0,
        age: u?.age ?? 30,
        gender: u?.gender ?? 'Male',
      );

  double burn(Exercise ex, double minutes) => CalorieCalculator.calculateBurn(
        met: ex.met,
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        gender: gender,
        durationMinutes: minutes,
      );
}

// --- CALORIE CALCULATION HELPER ---
class CalorieCalculator {
  /// Calories = MET × weight(kg) × duration(hours), with modest height,
  /// age and gender adjustments.
  static double calculateBurn({
    required double met,
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required double durationMinutes,
  }) {
    final durationHours = durationMinutes / 60.0;
    final heightFactor = 0.85 + (heightCm / 170.0) * 0.15;
    final baseBurn = met * weightKg * durationHours * heightFactor;

    double ageFactor = 1.0;
    if (age > 25) ageFactor = 1.0 - ((age - 25) * 0.005);
    if (ageFactor < 0.85) ageFactor = 0.85;

    final genderFactor = gender.toLowerCase() == 'female' ? 0.95 : 1.0;
    return baseBurn * ageFactor * genderFactor;
  }
}

// --- SHARED LOGGING HELPER (calories burned + workout name) ---
Future<void> logWorkoutToDiary({
  required String label,
  required double caloriesBurned,
}) async {
  final ls = LocalStorageService.instance;
  final log = ls.getTodayLog();
  await ls.updateTodayLog(
    caloriesBurned: log.caloriesBurned + caloriesBurned,
    completedWorkouts: [...log.completedWorkouts, label],
  );
}

// --- EXERCISE LIBRARY ---
final List<Exercise> kExercises = [
  // CHEST
  Exercise(
    name: 'Standard Push-Ups', primaryMuscle: 'Chest', met: 8.0,
    icon: Icons.accessibility_new,
    formCues: [
      'Start in a high plank with hands shoulder-width apart.',
      'Keep your body in a straight line from head to heels.',
      'Lower your chest until it is 2 inches from the floor.',
      'Push back up by driving through your palms.',
    ],
    commonMistakes: ['Sagging hips', 'Flaring elbows past 45°', 'Looking up'],
    breathingTip: 'Inhale on the way down, exhale forcefully on the way up.',
  ),
  Exercise(
    name: 'Incline Push-Ups', primaryMuscle: 'Chest', met: 6.0,
    icon: Icons.accessibility_new,
    formCues: [
      'Place hands on a sturdy chair or bench.',
      'Keep core tight and body straight.',
      'Lower your chest to the elevated surface.',
      'Push back to the starting position.',
    ],
    commonMistakes: ['Bending at the hips', 'Letting elbows flare', 'Rushing the descent'],
    breathingTip: 'Inhale down, exhale up. Control the tempo.',
  ),
  Exercise(
    name: 'Diamond Push-Ups', primaryMuscle: 'Chest', met: 8.5,
    icon: Icons.accessibility_new,
    formCues: [
      'Form a diamond shape with your thumbs and index fingers.',
      'Lower your chest to the diamond.',
      'Keep elbows tucked close to your body.',
      'Push back up with control.',
    ],
    commonMistakes: ['Sagging hips', 'Hands too far forward', 'Locking elbows at top'],
    breathingTip: 'Inhale as you lower, exhale as you press.',
  ),
  Exercise(
    name: 'Wide Push-Ups', primaryMuscle: 'Chest', met: 8.0,
    icon: Icons.accessibility_new,
    formCues: [
      'Place hands wider than shoulder-width apart.',
      'Engage your core and keep your body straight.',
      'Lower your chest to near the floor.',
      'Push back up smoothly.',
    ],
    commonMistakes: ['Going too deep', 'Hips sagging', 'Not engaging the core'],
    breathingTip: 'Exhale through pursed lips on the push.',
  ),

  // BACK
  Exercise(
    name: 'Superman Hold', primaryMuscle: 'Back', met: 4.0,
    icon: Icons.airline_seat_recline_normal,
    formCues: [
      'Lie face down with arms extended forward.',
      'Lift your arms, chest, and legs off the floor simultaneously.',
      'Squeeze your glutes and shoulder blades.',
      'Hold for 2-3 seconds, then lower.',
    ],
    commonMistakes: ['Looking up (crick in neck)', 'Only lifting one side', 'Bouncing'],
    breathingTip: 'Breathe steadily; do not hold your breath.',
  ),
  Exercise(
    name: 'Bird Dog', primaryMuscle: 'Back', met: 3.5,
    icon: Icons.airline_seat_recline_normal,
    formCues: [
      'Start on all fours, hands under shoulders.',
      'Extend your right arm and left leg simultaneously.',
      'Keep hips level and back flat.',
      'Return to start and switch sides.',
    ],
    commonMistakes: ['Rotating hips', 'Arching lower back', 'Rushing reps'],
    breathingTip: 'Inhale extend, exhale return.',
  ),
  Exercise(
    name: 'Reverse Snow Angels', primaryMuscle: 'Back', met: 4.0,
    icon: Icons.airline_seat_recline_normal,
    formCues: [
      'Lie face down with arms by your sides.',
      'Sweep your arms overhead, keeping them off the floor.',
      'Return to your sides with control.',
      'Keep chin tucked and neck neutral.',
    ],
    commonMistakes: ['Lifting head', 'Rushing reps', 'Losing shoulder contact'],
    breathingTip: 'Inhale reach overhead, exhale sweep down.',
  ),
  Exercise(
    name: 'Doorway Rows', primaryMuscle: 'Back', met: 5.0,
    icon: Icons.airline_seat_recline_normal,
    formCues: [
      'Stand in a doorway, grab the frame with both hands.',
      'Lean back with straight arms.',
      'Pull your chest toward the doorway.',
      'Slowly return to start.',
    ],
    commonMistakes: ['Not leaning back enough', 'Bending elbows too early', 'Door not secure'],
    breathingTip: 'Exhale pull, inhale return.',
  ),

  // LEGS
  Exercise(
    name: 'Bodyweight Squats', primaryMuscle: 'Legs', met: 5.0,
    icon: Icons.directions_run,
    formCues: [
      'Stand with feet shoulder-width apart.',
      'Push hips back as if sitting in a chair.',
      'Lower until thighs are parallel to the floor.',
      'Drive through heels to stand.',
    ],
    commonMistakes: ['Knees caving in', 'Knees past toes', 'Heels lifting'],
    breathingTip: 'Inhale down, exhale as you stand.',
  ),
  Exercise(
    name: 'Forward Lunges', primaryMuscle: 'Legs', met: 5.5,
    icon: Icons.directions_run,
    formCues: [
      'Step forward into a lunge position.',
      'Keep front knee over ankle.',
      'Lower back knee towards floor.',
      'Push through front heel to return.',
    ],
    commonMistakes: ['Front knee going past toes', 'Leaning forward', 'Short steps'],
    breathingTip: 'Inhale down, exhale up.',
  ),
  Exercise(
    name: 'Glute Bridges', primaryMuscle: 'Legs', met: 3.0,
    icon: Icons.directions_run,
    formCues: [
      'Lie on your back with knees bent, feet flat.',
      'Squeeze glutes to lift hips.',
      'Create a straight line from shoulders to knees.',
      'Lower with control.',
    ],
    commonMistakes: ['Hyperextending back', 'Not squeezing glutes', 'Feet too far away'],
    breathingTip: 'Exhale lift, inhale lower.',
  ),
  Exercise(
    name: 'Calf Raises', primaryMuscle: 'Legs', met: 3.0,
    icon: Icons.directions_run,
    formCues: [
      'Stand tall with feet hip-width apart.',
      'Raise up onto the balls of your feet.',
      'Pause at the top, then slowly lower.',
      'Keep core engaged throughout.',
    ],
    commonMistakes: ['Bouncing', 'Rolling ankles', 'Not going through full range'],
    breathingTip: 'Exhale up, inhale down.',
  ),

  // CORE
  Exercise(
    name: 'Standard Plank', primaryMuscle: 'Core', met: 4.0,
    icon: Icons.self_improvement,
    formCues: [
      'Rest on forearms and toes.',
      'Keep body in a straight line.',
      'Engage core and squeeze glutes.',
      'Hold, breathing steadily.',
    ],
    commonMistakes: ['Hips sagging', 'Hips too high', 'Holding breath'],
    breathingTip: 'Breathe slowly and evenly throughout.',
  ),
  Exercise(
    name: 'Bicycle Crunches', primaryMuscle: 'Core', met: 5.0,
    icon: Icons.self_improvement,
    formCues: [
      'Lie on back with hands behind head.',
      'Lift shoulders off the floor.',
      'Bring opposite elbow to knee while extending other leg.',
      'Alternate sides in a pedaling motion.',
    ],
    commonMistakes: ['Pulling neck', 'Rushing', 'Not twisting torso'],
    breathingTip: 'Exhale with each twist.',
  ),
  Exercise(
    name: 'Leg Raises', primaryMuscle: 'Core', met: 4.0,
    icon: Icons.self_improvement,
    formCues: [
      'Lie flat on back with legs straight.',
      'Keep lower back pressed to the floor.',
      'Raise legs to 90 degrees.',
      'Lower slowly, stopping before touching the floor.',
    ],
    commonMistakes: ['Arching back', 'Using momentum', 'Dropping legs too fast'],
    breathingTip: 'Exhale raise, inhale lower.',
  ),
  Exercise(
    name: 'Russian Twists', primaryMuscle: 'Core', met: 4.5,
    icon: Icons.self_improvement,
    formCues: [
      'Sit with knees bent, feet slightly off the floor.',
      'Lean back slightly, keeping chest lifted.',
      'Twist torso left, then right.',
      'Touch hands to floor beside hips if possible.',
    ],
    commonMistakes: ['Rounding back', 'Moving arms only', 'Rushing the twists'],
    breathingTip: 'Exhale with each twist.',
  ),

  // SHOULDERS
  Exercise(
    name: 'Pike Push-Ups', primaryMuscle: 'Shoulders', met: 7.0,
    icon: Icons.sports_gymnastics,
    formCues: [
      'Start in downward dog position.',
      'Bend elbows to lower head towards floor.',
      'Press back up to start.',
      'Keep legs as straight as possible.',
    ],
    commonMistakes: ['Flaring elbows', 'Head hitting floor', 'Bending knees'],
    breathingTip: 'Inhale down, exhale press up.',
  ),
  Exercise(
    name: 'Lateral Arm Raises', primaryMuscle: 'Shoulders', met: 3.0,
    icon: Icons.sports_gymnastics,
    formCues: [
      'Hold light weights (or water bottles) by your sides.',
      'Raise arms out to shoulder height.',
      'Keep a slight bend in elbows.',
      'Lower slowly with control.',
    ],
    commonMistakes: ['Using momentum', 'Shrugging shoulders', 'Going too heavy'],
    breathingTip: 'Exhale raise, inhale lower.',
  ),
  Exercise(
    name: 'Arm Circles', primaryMuscle: 'Shoulders', met: 2.5,
    icon: Icons.sports_gymnastics,
    formCues: [
      'Extend arms out to sides at shoulder height.',
      'Make small circles, gradually increasing size.',
      'Reverse direction halfway through.',
      'Keep core engaged.',
    ],
    commonMistakes: ['Too fast', 'Tensing neck', 'Uneven circles'],
    breathingTip: 'Breathe steadily.',
  ),

  // ARMS
  Exercise(
    name: 'Bicep Curls', primaryMuscle: 'Arms', met: 3.5,
    icon: Icons.fitness_center,
    formCues: [
      'Stand with weights in hands, palms forward.',
      'Keep elbows pinned to your sides.',
      'Curl weights towards shoulders.',
      'Lower slowly with control.',
    ],
    commonMistakes: ['Swinging body', 'Elbows moving forward', 'Going too heavy'],
    breathingTip: 'Exhale curl, inhale lower.',
  ),
  Exercise(
    name: 'Tricep Dips', primaryMuscle: 'Arms', met: 5.5,
    icon: Icons.fitness_center,
    formCues: [
      'Sit on edge of a sturdy chair.',
      'Slide hips forward, supporting with hands.',
      'Bend elbows to lower body.',
      'Press back up through triceps.',
    ],
    commonMistakes: ['Elbows flaring out', 'Going too deep', 'Chair not stable'],
    breathingTip: 'Inhale down, exhale press up.',
  ),
  Exercise(
    name: 'Hammer Curls', primaryMuscle: 'Arms', met: 3.5,
    icon: Icons.fitness_center,
    formCues: [
      'Hold weights with palms facing each other.',
      'Curl up keeping thumbs up.',
      'Elbows stay pinned to sides.',
      'Lower slowly.',
    ],
    commonMistakes: ['Rotating wrists', 'Swinging body', 'Rushing'],
    breathingTip: 'Exhale up, inhale down.',
  ),
  Exercise(
    name: 'Overhead Tricep Extension', primaryMuscle: 'Arms', met: 3.5,
    icon: Icons.fitness_center,
    formCues: [
      'Hold one weight overhead with both hands.',
      'Lower weight behind your head by bending elbows.',
      'Keep elbows pointing forward.',
      'Press back up to straight arms.',
    ],
    commonMistakes: ['Elbows flaring out', 'Arching back', 'Going too heavy'],
    breathingTip: 'Inhale down, exhale press.',
  ),
];

Exercise _ex(String name) => kExercises.firstWhere((e) => e.name == name);

// --- COMBO ROUTINES ---
final List<WorkoutRoutine> kRoutines = [
  WorkoutRoutine(
    id: 'push', name: 'Push Day', muscles: ['Chest', 'Shoulders', 'Arms'],
    difficulty: 'Intermediate', durationMinutes: 35, icon: Icons.fitness_center,
    exercises: [_ex('Standard Push-Ups'), _ex('Pike Push-Ups'), _ex('Diamond Push-Ups'), _ex('Tricep Dips')],
  ),
  WorkoutRoutine(
    id: 'pull', name: 'Pull Day', muscles: ['Back', 'Arms'],
    difficulty: 'Intermediate', durationMinutes: 30, icon: Icons.airline_seat_recline_normal,
    exercises: [_ex('Doorway Rows'), _ex('Superman Hold'), _ex('Bicep Curls'), _ex('Hammer Curls')],
  ),
  WorkoutRoutine(
    id: 'chest_tri', name: 'Chest + Triceps', muscles: ['Chest', 'Arms'],
    difficulty: 'Intermediate', durationMinutes: 25, icon: Icons.accessibility_new,
    exercises: [_ex('Standard Push-Ups'), _ex('Diamond Push-Ups'), _ex('Tricep Dips'), _ex('Overhead Tricep Extension')],
  ),
  WorkoutRoutine(
    id: 'back_bi', name: 'Back + Biceps', muscles: ['Back', 'Arms'],
    difficulty: 'Intermediate', durationMinutes: 25, icon: Icons.airline_seat_recline_normal,
    exercises: [_ex('Doorway Rows'), _ex('Bird Dog'), _ex('Bicep Curls'), _ex('Hammer Curls')],
  ),
  WorkoutRoutine(
    id: 'legs_glutes', name: 'Legs + Glutes', muscles: ['Legs'],
    difficulty: 'Beginner', durationMinutes: 30, icon: Icons.directions_run,
    exercises: [_ex('Bodyweight Squats'), _ex('Forward Lunges'), _ex('Glute Bridges'), _ex('Calf Raises')],
  ),
];

// --- MAIN WORKOUT TAB ---
class WorkoutTab extends StatefulWidget {
  const WorkoutTab({super.key});

  @override
  State<WorkoutTab> createState() => _WorkoutTabState();
}

class _WorkoutTabState extends State<WorkoutTab> {
  String _selectedFilter = 'All';

  final List<String> _filters = const [
    'All',
    'Chest',
    'Back',
    'Legs',
    'Core',
    'Shoulders',
    'Arms',
    'Chest + Triceps',
    'Back + Biceps',
    'Legs + Glutes',
    'Push Day',
    'Pull Day',
  ];

  static const _comboFilters = [
    'Chest + Triceps',
    'Back + Biceps',
    'Legs + Glutes',
    'Push Day',
    'Pull Day',
  ];

  bool get _isComboMode => _comboFilters.contains(_selectedFilter);

  List<WorkoutRoutine> get _displayedRoutines {
    if (_selectedFilter == 'All') return kRoutines;
    if (_isComboMode) {
      return kRoutines.where((r) => r.name == _selectedFilter).toList();
    }
    return [];
  }

  List<Exercise> get _displayedExercises {
    if (_selectedFilter == 'All' || _isComboMode) return [];
    return kExercises.where((e) => e.primaryMuscle == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocalStorageService.instance,
      builder: (context, _) {
        final ls = LocalStorageService.instance;
        final body = BodyStats.fromProfile(ls.userProfile);
        final today = ls.getTodayLog();
        final routines = _displayedRoutines;
        final exercises = _displayedExercises;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(title: const Text('Workouts')),
          body: Column(
            children: [
              // FILTER CHIPS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _selectedFilter = filter),
                        selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                        backgroundColor: AppTheme.surface,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                            color:
                                isSelected ? AppTheme.primary : AppTheme.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  }).toList(),
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                  children: [
                    _todaySummary(today),
                    const SizedBox(height: 16),
                    if (routines.isNotEmpty) ...[
                      Text('Combo Routines',
                          style: AppTheme.darkTheme.textTheme.titleLarge),
                      const SizedBox(height: 12),
                      ...routines.map((r) => _buildRoutineCard(r, body)),
                    ],
                    if (exercises.isNotEmpty) ...[
                      Text('$_selectedFilter Exercises',
                          style: AppTheme.darkTheme.textTheme.titleLarge),
                      const SizedBox(height: 12),
                      ...exercises.map((ex) => _buildExerciseCard(ex, body)),
                    ],
                    if (routines.isEmpty && exercises.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text('No exercises found.',
                              style: AppTheme.darkTheme.textTheme.bodyMedium),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TODAY SUMMARY ---
  Widget _todaySummary(DailyLog log) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentCoral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentCoral.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department,
              color: AppTheme.accentCoral, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${log.caloriesBurned.round()} kcal burned today',
                    style: AppTheme.darkTheme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  log.completedWorkouts.isEmpty
                      ? 'No workouts logged yet'
                      : '${log.completedWorkouts.length} logged: ${log.completedWorkouts.join(', ')}',
                  style: AppTheme.darkTheme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ROUTINE CARD ---
  Widget _buildRoutineCard(WorkoutRoutine routine, BodyStats body) {
    final sessionBurn = routine.exercises.fold<double>(
      0,
      (sum, ex) => sum + body.burn(ex, routine.minutesPerExercise),
    );

    final Color diffColor = routine.difficulty == 'Beginner'
        ? Colors.green
        : routine.difficulty == 'Intermediate'
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ComboSessionScreen(routine: routine)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(routine.icon,
                          color: AppTheme.primary, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(routine.name,
                              style: AppTheme.darkTheme.textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(routine.muscles.join(' • '),
                              style: AppTheme.darkTheme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.play_circle_fill,
                        color: AppTheme.primary, size: 40),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: diffColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(routine.difficulty,
                          style: TextStyle(
                              color: diffColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                        '${routine.durationMinutes} min • ${routine.exercises.length} exercises',
                        style: AppTheme.darkTheme.textTheme.bodySmall),
                    const Spacer(),
                    const Icon(Icons.local_fire_department,
                        color: AppTheme.accentCoral, size: 14),
                    Text(' ${sessionBurn.round()} kcal',
                        style: const TextStyle(
                            color: AppTheme.accentCoral,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- EXERCISE CARD ---
  Widget _buildExerciseCard(Exercise ex, BodyStats body) {
    final burn10 = body.burn(ex, 10);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.selectionClick();
            _showFormGuide(ex, body);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(ex.icon, color: AppTheme.primary, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex.name,
                          style: AppTheme.darkTheme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department,
                              color: AppTheme.accentCoral, size: 12),
                          Text(' ~${burn10.round()} kcal / 10 min',
                              style: AppTheme.darkTheme.textTheme.bodySmall),
                          const SizedBox(width: 12),
                          Text('MET ${ex.met}',
                              style: AppTheme.darkTheme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.info_outline, color: AppTheme.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- FORM GUIDE + LOG BOTTOM SHEET ---
  void _showFormGuide(Exercise ex, BodyStats body) {
    final messenger = ScaffoldMessenger.of(context);
    int minutes = 10;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => StatefulBuilder(
          builder: (_, setSheetState) {
            final burn = body.burn(ex, minutes.toDouble());

            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16)),
                              child: Icon(ex.icon,
                                  color: AppTheme.primary, size: 36),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ex.name,
                                      style: AppTheme
                                          .darkTheme.textTheme.headlineMedium),
                                  const SizedBox(height: 4),
                                  Text('Target: ${ex.primaryMuscle}',
                                      style: AppTheme
                                          .darkTheme.textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _guideSection('Step-by-Step Form',
                            Icons.format_list_numbered, Colors.blue, ex.formCues),
                        const SizedBox(height: 16),
                        _guideSection(
                            'Breathing', Icons.air, Colors.teal, [ex.breathingTip]),
                        const SizedBox(height: 16),
                        _guideSection('Avoid These Mistakes',
                            Icons.warning_amber_rounded, AppTheme.accentCoral,
                            ex.commonMistakes),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // LOG PANEL (pinned to the bottom)
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                    decoration: const BoxDecoration(
                      color: AppTheme.surfaceHighlight,
                      border: Border(top: BorderSide(color: AppTheme.border)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Log this exercise',
                            style: AppTheme.darkTheme.textTheme.titleMedium),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [5, 10, 15, 20, 30].map((m) {
                            final sel = minutes == m;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setSheetState(() => minutes = m);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppTheme.primary
                                      : AppTheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: sel
                                          ? AppTheme.primary
                                          : AppTheme.border),
                                ),
                                child: Text('${m}m',
                                    style: TextStyle(
                                      color: sel
                                          ? AppTheme.background
                                          : AppTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: Text('Log $minutes min • ~${burn.round()} kcal'),
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            await logWorkoutToDiary(
                              label: '${ex.name} ($minutes min)',
                              caloriesBurned: burn,
                            );
                            if (sheetContext.mounted) Navigator.pop(sheetContext);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Logged ${ex.name}: ${burn.round()} kcal burned'),
                                backgroundColor: AppTheme.primary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _guideSection(
      String title, IconData icon, Color color, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ',
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(item,
                        style: AppTheme.darkTheme.textTheme.bodyMedium
                            ?.copyWith(color: AppTheme.textPrimary)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- COMBO SESSION SCREEN ---
class ComboSessionScreen extends StatefulWidget {
  final WorkoutRoutine routine;
  const ComboSessionScreen({super.key, required this.routine});

  @override
  State<ComboSessionScreen> createState() => _ComboSessionScreenState();
}

class _ComboSessionScreenState extends State<ComboSessionScreen> {
  int _index = 0;
  final Set<String> _completed = {};
  Timer? _restTimer;
  int _restRemaining = 0;
  bool _finishing = false;

  WorkoutRoutine get _routine => widget.routine;
  Exercise get _current => _routine.exercises[_index];
  bool get _isLast => _index == _routine.exercises.length - 1;

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  // --- REST TIMER (uses the default rest from Settings) ---
  void _startRest() {
    final secs = LocalStorageService.instance.settings.defaultRestSeconds;
    if (secs <= 0) return;
    _restTimer?.cancel();
    setState(() => _restRemaining = secs);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_restRemaining <= 1) {
        t.cancel();
        HapticFeedback.heavyImpact();
        setState(() => _restRemaining = 0);
      } else {
        setState(() => _restRemaining--);
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() => _restRemaining = 0);
  }

  // --- ACTIONS ---
  void _completeCurrent() {
    HapticFeedback.mediumImpact();
    _completed.add(_current.name);
    if (_isLast) {
      _finish();
    } else {
      setState(() => _index++);
      _startRest();
    }
  }

  void _skip() {
    if (_isLast) return;
    _skipRest();
    setState(() => _index++);
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    _restTimer?.cancel();

    final messenger = ScaffoldMessenger.of(context);

    if (_completed.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No exercises completed — nothing logged.')),
      );
      if (mounted) Navigator.pop(context);
      return;
    }

    final body = BodyStats.fromProfile(LocalStorageService.instance.userProfile);
    double totalBurn = 0;
    for (final ex in _routine.exercises) {
      if (_completed.contains(ex.name)) {
        totalBurn += body.burn(ex, _routine.minutesPerExercise);
      }
    }

    final allDone = _completed.length == _routine.exercises.length;
    await logWorkoutToDiary(
      label: allDone
          ? _routine.name
          : '${_routine.name} (${_completed.length}/${_routine.exercises.length})',
      caloriesBurned: totalBurn,
    );

    messenger.showSnackBar(
      SnackBar(
        content: Text('🎉 ${_routine.name} done! Burned ${totalBurn.round()} kcal'),
        backgroundColor: AppTheme.primary,
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final body = BodyStats.fromProfile(LocalStorageService.instance.userProfile);
    final perMin = _routine.minutesPerExercise;
    final currentBurn = body.burn(_current, perMin);
    final totalBurn = _routine.exercises
        .fold<double>(0, (sum, ex) => sum + body.burn(ex, perMin));
    final resting = _restRemaining > 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_routine.name),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_completed.isNotEmpty)
            TextButton(
              onPressed: _finish,
              child: const Text('Finish',
                  style: TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _completed.length / _routine.exercises.length,
                backgroundColor: AppTheme.surfaceHighlight,
                valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_completed.length} / ${_routine.exercises.length} completed',
              style: AppTheme.darkTheme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.border),
                ),
                child: resting ? _restView() : _exerciseView(currentBurn, totalBurn, perMin),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLast ? null : _skip,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.border),
                      foregroundColor: AppTheme.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _completeCurrent,
                    child: Text(_isLast ? 'Complete & Finish' : 'Complete Exercise'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _exerciseView(double currentBurn, double totalBurn, double perMin) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle),
          child: Icon(_current.icon, color: AppTheme.primary, size: 56),
        ),
        const SizedBox(height: 20),
        Text(_current.name,
            style: AppTheme.darkTheme.textTheme.headlineMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('${perMin.round()} min • ~${currentBurn.round()} kcal',
            style: AppTheme.darkTheme.textTheme.bodyMedium),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: AppTheme.accentCoral.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20)),
          child: Text('Session Burn: ${totalBurn.round()} kcal',
              style: const TextStyle(
                  color: AppTheme.accentCoral,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppTheme.surfaceHighlight,
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key form cue:',
                  style: AppTheme.darkTheme.textTheme.bodySmall
                      ?.copyWith(color: AppTheme.primary)),
              const SizedBox(height: 4),
              Text(_current.formCues.first,
                  style: AppTheme.darkTheme.textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _restView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.timer_outlined, color: AppTheme.primary, size: 48),
        const SizedBox(height: 16),
        Text('Rest', style: AppTheme.darkTheme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          '$_restRemaining',
          style: AppTheme.darkTheme.textTheme.displayLarge
              ?.copyWith(color: AppTheme.primary),
        ),
        const SizedBox(height: 8),
        Text('Up next: ${_current.name}',
            style: AppTheme.darkTheme.textTheme.bodyLarge,
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        TextButton(
          onPressed: _skipRest,
          child: const Text('Skip rest',
              style: TextStyle(color: AppTheme.primary)),
        ),
      ],
    );
  }
}