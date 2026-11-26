import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'local_storage_service.dart';
import 'onboarding_flow.dart';
import 'theme.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  String _formatWeight(double weightKg, String unitsSystem) {
    if (unitsSystem == 'imperial') {
      return '${(weightKg * 2.20462).toStringAsFixed(1)} lbs';
    }
    return '${weightKg.toStringAsFixed(1)} kg';
  }

  Future<void> _recalculateAndSave(
    UserProfile user, {
    double? weight,
    double? targetWeight,
    int? age,
    String? activity,
  }) async {
    final updated = LocalStorageService.instance.recalculateProfile(
      user,
      weight: weight,
      targetWeight: targetWeight,
      age: age,
      activity: activity,
    );
    await LocalStorageService.instance.saveProfile(updated);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocalStorageService.instance,
      builder: (context, _) {
        final ls = LocalStorageService.instance;
        final user = ls.userProfile;
        final settings = ls.settings;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final displayName = (ls.userName == null || ls.userName!.trim().isEmpty)
            ? 'Fitness Member'
            : ls.userName!;

        double weightProgress = 0;
        final totalToLose = user.weightKg - user.targetWeightKg;
        if (totalToLose > 0) {
          weightProgress = (5 / (totalToLose + 5)).clamp(0.0, 1.0);
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(title: const Text('Profile')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.surfaceHighlight,
                      child:
                          Icon(Icons.person, size: 40, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 12),
                    Text(displayName,
                        style: AppTheme.darkTheme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.goal,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),

              const SizedBox(height: 30),

              // Weight Progress
              Container(
                padding: const EdgeInsets.all(20),
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
                        Text('Weight Progress',
                            style: AppTheme.darkTheme.textTheme.titleMedium),
                        Text(
                          _formatWeight(user.weightKg, settings.unitsSystem),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: weightProgress,
                        backgroundColor: AppTheme.surfaceHighlight,
                        valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current',
                            style: AppTheme.darkTheme.textTheme.bodySmall),
                        Text(
                          'Target: ${_formatWeight(user.targetWeightKg, settings.unitsSystem)}',
                          style: AppTheme.darkTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Current Targets
              Text('Daily Targets',
                  style: AppTheme.darkTheme.textTheme.titleLarge),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _targetChip(
                      'Calories', '${user.dailyCalorieGoal}', AppTheme.primary),
                  _targetChip(
                      'Protein', '${user.proteinGoal}g', Colors.purpleAccent),
                  _targetChip(
                      'Carbs', '${user.carbsGoal}g', Colors.blueAccent),
                  _targetChip('Fat', '${user.fatGoal}g', Colors.orangeAccent),
                ],
              ),

              const SizedBox(height: 30),

              // Settings
              Text('Settings', style: AppTheme.darkTheme.textTheme.titleLarge),
              const SizedBox(height: 10),

              // Units Toggle
              SwitchListTile(
                title: const Text('Use Imperial Units (lbs/ft)'),
                subtitle: const Text('Off = Metric (kg/cm)'),
                value: settings.unitsSystem == 'imperial',
                activeThumbColor: AppTheme.primary,
                onChanged: (val) {
                  LocalStorageService.instance.updateSettings(
                    settings.copyWith(
                      unitsSystem: val ? 'imperial' : 'metric',
                    ),
                  );
                },
              ),

              // Notifications Toggle
              SwitchListTile(
                title: const Text('Push Notifications'),
                value: settings.notificationsEnabled,
                activeThumbColor: AppTheme.primary,
                onChanged: (val) {
                  LocalStorageService.instance.updateSettings(
                    settings.copyWith(notificationsEnabled: val),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Action Buttons
              OutlinedButton.icon(
                onPressed: () => _showEditDialog(context, user, settings.unitsSystem),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Body Stats'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.border),
                  foregroundColor: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showResetDialog(context),
                icon: const Icon(Icons.warning, color: AppTheme.accentCoral),
                label: const Text('Reset Progress',
                    style: TextStyle(color: AppTheme.accentCoral)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.accentCoral),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await LocalStorageService.instance.logOut(clearData: false);
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LandingScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.border),
                  foregroundColor: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 110),
            ],
          ),
        );
      },
    );
  }

  Widget _targetChip(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.darkTheme.textTheme.bodySmall),
      ],
    );
  }

  void _showEditDialog(
    BuildContext context,
    UserProfile user,
    String unitsSystem,
  ) {
    double newWeight = user.weightKg;
    double newTarget = user.targetWeightKg;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Edit Stats'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Weight: ${_formatWeight(newWeight, unitsSystem)}',
                ),
                Slider(
                  value: newWeight.clamp(40.0, 150.0),
                  min: 40,
                  max: 150,
                  activeColor: AppTheme.primary,
                  onChanged: (val) => setState(() => newWeight = val),
                ),
                Text(
                  'Target Weight: ${_formatWeight(newTarget, unitsSystem)}',
                ),
                Slider(
                  value: newTarget.clamp(40.0, 150.0),
                  min: 40,
                  max: 150,
                  activeColor: AppTheme.primary,
                  onChanged: (val) => setState(() => newTarget = val),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _recalculateAndSave(
                user,
                weight: newWeight,
                targetWeight: newTarget,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will clear all logged meals, workouts, and weight history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await LocalStorageService.instance.logOut(clearData: true);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LandingScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: AppTheme.accentCoral),
            ),
          ),
        ],
      ),
    );
  }
}