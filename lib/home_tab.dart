import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'local_storage_service.dart';
import 'theme.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  DateTime _selectedDate = DateTime.now();

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  String _formatWeight(double weightKg, String unitsSystem) {
    if (unitsSystem == 'imperial') {
      final lbs = weightKg * 2.20462;
      return '${lbs.toStringAsFixed(1)} lbs';
    }
    return '${weightKg.toStringAsFixed(1)} kg';
  }

  List<Map<String, dynamic>> _buildWeekDays() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return List.generate(7, (i) {
      final date = weekStart.add(Duration(days: i));
      return {
        'label': labels[i],
        'date': date,
        'isSelected': date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day,
        'isToday': date.year == now.year &&
            date.month == now.month &&
            date.day == now.day,
        'isFuture': date.isAfter(DateTime(now.year, now.month, now.day)),
      };
    });
  }

  Future<void> _showLogWeightDialog() async {
    final ls = LocalStorageService.instance;
    final user = ls.userProfile;
    if (user == null) return;

    final isImperial = ls.settings.unitsSystem == 'imperial';
    double newWeightKg = user.weightKg;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final displayLabel =
              _formatWeight(newWeightKg, ls.settings.unitsSystem);
          return Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Log Today\'s Weight',
                  style: AppTheme.darkTheme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    displayLabel,
                    style: AppTheme.darkTheme.textTheme.displayMedium
                        ?.copyWith(color: AppTheme.primary),
                  ),
                ),
                Slider(
                  value: newWeightKg.clamp(40.0, 200.0),
                  min: 40,
                  max: 200,
                  divisions: 320,
                  activeColor: AppTheme.primary,
                  label: isImperial
                      ? '${(newWeightKg * 2.20462).toStringAsFixed(1)} lbs'
                      : '${newWeightKg.toStringAsFixed(1)} kg',
                  onChanged: (val) => setModalState(() => newWeightKg = val),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await LocalStorageService.instance.addWeight(newWeightKg);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Weight logged: ${_formatWeight(newWeightKg, ls.settings.unitsSystem)}',
                        ),
                        backgroundColor: AppTheme.primary,
                      ),
                    );
                  },
                  child: const Text('Save Weight'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocalStorageService.instance,
      builder: (context, _) {
        final ls = LocalStorageService.instance;
        final user = ls.userProfile;
        final settings = ls.settings;
        final log = ls.getLog(_selectedDate);
        final weekDays = _buildWeekDays();

        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        final totalBudget = user.dailyCalorieGoal + log.caloriesBurned;
        final double progress = totalBudget > 0
            ? (log.caloriesEaten / totalBudget).clamp(0.0, 1.0)
            : 0.0;
        final double remaining =
            user.dailyCalorieGoal - log.caloriesEaten + log.caloriesBurned;

        final weightHistory = ls.weightHistory;
        final List<FlSpot> weightSpots = weightHistory.isEmpty
            ? [FlSpot(0, user.weightKg)]
            : weightHistory
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.weightKg))
                .toList();

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(user, ls.userName, settings.streakCount),
                  const SizedBox(height: 24),
                  _buildWeekCalendar(weekDays),
                  const SizedBox(height: 24),
                  _buildHeroCalorieCard(user, log, remaining, progress),
                  const SizedBox(height: 24),
                  _buildQuickActions(
                      user, log, weightSpots, settings.unitsSystem),
                  const SizedBox(height: 24),
                  _buildTodayPlan(user, log),
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserProfile user, String? userName, int streak) {
    final displayName = (userName == null || userName.trim().isEmpty)
        ? 'Fitness Member'
        : userName;
    final goalEmoji = user.goal == 'Lose Weight'
        ? '🔥'
        : user.goal == 'Build Muscle'
            ? '💪'
            : '⚖️';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.surfaceHighlight,
              child: Icon(Icons.person, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, $displayName',
                    style: AppTheme.darkTheme.textTheme.bodyMedium),
                Text('$goalEmoji ${user.goal}',
                    style: AppTheme.darkTheme.textTheme.titleLarge),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.accentCoral.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppTheme.accentCoral.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department,
                  color: AppTheme.accentCoral, size: 20),
              const SizedBox(width: 4),
              Text(
                '$streak Day Streak',
                style: AppTheme.darkTheme.textTheme.labelLarge
                    ?.copyWith(color: AppTheme.accentCoral),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildWeekCalendar(List<Map<String, dynamic>> days) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day['isSelected'] as bool;
          final isToday = day['isToday'] as bool;
          final isFuture = day['isFuture'] as bool;
          final date = day['date'] as DateTime;

          return GestureDetector(
            onTap: isFuture
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedDate = date);
                  },
            child: Container(
              width: 55,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : (isToday
                          ? AppTheme.primaryDark.withValues(alpha: 0.5)
                          : AppTheme.border),
                  width: isToday && !isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day['label'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.background
                          : AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.background
                          : (isFuture
                              ? AppTheme.textTertiary
                              : AppTheme.textPrimary),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCalorieCard(
    UserProfile user,
    DailyLog log,
    double remaining,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            width: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 0,
                    centerSpaceRadius: 85,
                    sections: [
                      PieChartSectionData(
                        value: progress <= 0 ? 100 : progress * 100,
                        color: progress <= 0
                            ? AppTheme.surfaceHighlight
                            : (progress >= 1.0
                                ? AppTheme.accentCoral
                                : AppTheme.primary),
                        radius: progress <= 0 ? 8 : 15,
                        showTitle: false,
                      ),
                      if (progress > 0 && progress < 1.0)
                        PieChartSectionData(
                          value: (1 - progress) * 100,
                          color: AppTheme.surfaceHighlight,
                          radius: 12,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      remaining.round().toString(),
                      style:
                          AppTheme.darkTheme.textTheme.displayMedium?.copyWith(
                        height: 1.1,
                        color: remaining < 0
                            ? AppTheme.accentCoral
                            : AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      remaining < 0 ? 'kcal over' : 'kcal remaining',
                      style: AppTheme.darkTheme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem('Eaten', log.caloriesEaten, AppTheme.primaryDark),
              Container(width: 1, height: 40, color: AppTheme.border),
              _statItem('Burned', log.caloriesBurned, AppTheme.accentCoral),
            ],
          ),
          const Divider(height: 40, color: AppTheme.border),
          _macroBar('Protein', log.proteinEaten, user.proteinGoal.toDouble(),
              Colors.purpleAccent),
          const SizedBox(height: 12),
          _macroBar('Carbs', log.carbsEaten, user.carbsGoal.toDouble(),
              Colors.blueAccent),
          const SizedBox(height: 12),
          _macroBar('Fat', log.fatEaten, user.fatGoal.toDouble(),
              Colors.orangeAccent),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _statItem(String label, double value, Color color) {
    return Column(
      children: [
        Text('${value.round()}',
            style: AppTheme.darkTheme.textTheme.titleLarge
                ?.copyWith(color: color)),
        Text(label, style: AppTheme.darkTheme.textTheme.bodySmall),
      ],
    );
  }

  Widget _macroBar(String label, double current, double goal, Color color) {
    final safeGoal = goal <= 0 ? 1.0 : goal;
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label,
              style: AppTheme.darkTheme.textTheme.bodySmall
                  ?.copyWith(color: color)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (current / safeGoal).clamp(0.0, 1.0),
              backgroundColor: AppTheme.surfaceHighlight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text('${current.round()}/${goal.round()}g',
            style: AppTheme.darkTheme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildQuickActions(
    UserProfile user,
    DailyLog log,
    List<FlSpot> weightSpots,
    String unitsSystem,
  ) {
    final canEdit = _isToday;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.water_drop,
                        color: Colors.blueAccent, size: 20),
                    const SizedBox(width: 8),
                    Text('Water',
                        style: AppTheme.darkTheme.textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: !canEdit
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              final newVal = log.waterGlasses > 0
                                  ? log.waterGlasses - 1
                                  : 0;
                              LocalStorageService.instance.updateLog(
                                DateTime.now(),
                                waterGlasses: newVal,
                              );
                            },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: canEdit
                              ? AppTheme.surfaceHighlight
                              : AppTheme.surfaceHighlight
                                  .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 20,
                          color: canEdit
                              ? AppTheme.textPrimary
                              : AppTheme.textTertiary,
                        ),
                      ),
                    ),
                    Text('${log.waterGlasses} / 8',
                        style: AppTheme.darkTheme.textTheme.titleLarge),
                    GestureDetector(
                      onTap: !canEdit
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              final newVal = log.waterGlasses < 8
                                  ? log.waterGlasses + 1
                                  : 8;
                              LocalStorageService.instance.updateLog(
                                DateTime.now(),
                                waterGlasses: newVal,
                              );
                            },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: canEdit
                              ? AppTheme.primary
                              : AppTheme.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 20,
                          color: canEdit
                              ? AppTheme.background
                              : AppTheme.background.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: _showLogWeightDialog,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.monitor_weight_outlined,
                              color: AppTheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Weight',
                              style: AppTheme.darkTheme.textTheme.titleMedium),
                        ],
                      ),
                      const Icon(Icons.add_circle,
                          size: 18, color: AppTheme.primary),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineTouchData: const LineTouchData(enabled: false),
                        minY: weightSpots
                                .map((s) => s.y)
                                .reduce((a, b) => a < b ? a : b) -
                            1,
                        maxY: weightSpots
                                .map((s) => s.y)
                                .reduce((a, b) => a > b ? a : b) +
                            1,
                        lineBarsData: [
                          LineChartBarData(
                            spots: weightSpots,
                            isCurved: true,
                            color: AppTheme.primary,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: weightSpots.length == 1,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                radius: 4,
                                color: AppTheme.primary,
                                strokeWidth: 2,
                                strokeColor: AppTheme.background,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primary.withValues(alpha: 0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weightSpots.isNotEmpty
                        ? _formatWeight(weightSpots.last.y, unitsSystem)
                        : '--',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildTodayPlan(UserProfile user, DailyLog log) {
    final hasMeals = log.loggedMeals.isNotEmpty;
    final hasWorkouts = log.completedWorkouts.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isToday
                  ? "Today's Log"
                  : DateFormat('EEEE, MMM d').format(_selectedDate),
              style: AppTheme.darkTheme.textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (!hasMeals && !hasWorkouts)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.restaurant_menu,
                    color: AppTheme.textTertiary, size: 40),
                const SizedBox(height: 12),
                Text(
                  _isToday
                      ? 'Nothing logged yet. Tap Recipes or the scanner to log a meal.'
                      : 'No data for this day.',
                  style: AppTheme.darkTheme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...log.completedWorkouts.map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _planCard(w, 'Workout completed',
                        Icons.fitness_center, AppTheme.primary),
                  ),
                ),
                ...log.loggedMeals.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _planCard(m, 'Meal logged', Icons.restaurant,
                        AppTheme.accentCoral),
                  ),
                ),
              ],
            ),
          ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _planCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTheme.darkTheme.textTheme.titleLarge
                      ?.copyWith(height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: AppTheme.darkTheme.textTheme.bodySmall),
              ],
            ),
          ),
          Icon(icon, color: color, size: 40),
        ],
      ),
    );
  }
}