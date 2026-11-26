import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- MODELS ---

class WeightEntry {
  final DateTime date;
  final double weightKg;

  WeightEntry({required this.date, required this.weightKg});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weightKg': weightKg,
      };

  factory WeightEntry.fromJson(Map<String, dynamic> j) => WeightEntry(
        date: DateTime.parse(j['date']),
        weightKg: (j['weightKg'] as num).toDouble(),
      );
}

class DailyLog {
  int waterGlasses;
  double caloriesEaten;
  double caloriesBurned;
  double proteinEaten;
  double carbsEaten;
  double fatEaten;
  List<String> loggedMeals;
  List<String> completedWorkouts;

  DailyLog({
    this.waterGlasses = 0,
    this.caloriesEaten = 0,
    this.caloriesBurned = 0,
    this.proteinEaten = 0,
    this.carbsEaten = 0,
    this.fatEaten = 0,
    this.loggedMeals = const [],
    this.completedWorkouts = const [],
  });

  Map<String, dynamic> toJson() => {
        'waterGlasses': waterGlasses,
        'caloriesEaten': caloriesEaten,
        'caloriesBurned': caloriesBurned,
        'proteinEaten': proteinEaten,
        'carbsEaten': carbsEaten,
        'fatEaten': fatEaten,
        'loggedMeals': loggedMeals,
        'completedWorkouts': completedWorkouts,
      };

  factory DailyLog.fromJson(Map<String, dynamic> j) => DailyLog(
        waterGlasses: (j['waterGlasses'] ?? 0) as int,
        caloriesEaten: ((j['caloriesEaten'] ?? 0) as num).toDouble(),
        caloriesBurned: ((j['caloriesBurned'] ?? 0) as num).toDouble(),
        proteinEaten: ((j['proteinEaten'] ?? 0) as num).toDouble(),
        carbsEaten: ((j['carbsEaten'] ?? 0) as num).toDouble(),
        fatEaten: ((j['fatEaten'] ?? 0) as num).toDouble(),
        loggedMeals: List<String>.from(j['loggedMeals'] ?? []),
        completedWorkouts: List<String>.from(j['completedWorkouts'] ?? []),
      );
}

class UserProfile {
  final String goal;
  final String gender;
  final int age;
  final double heightCm;
  final double weightKg;
  final double targetWeightKg;
  final String activityLevel;
  final int dailyCalorieGoal;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;

  UserProfile({
    required this.goal,
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.targetWeightKg,
    required this.activityLevel,
    required this.dailyCalorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
  });

  Map<String, dynamic> toJson() => {
        'goal': goal,
        'gender': gender,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'targetWeightKg': targetWeightKg,
        'activityLevel': activityLevel,
        'dailyCalorieGoal': dailyCalorieGoal,
        'proteinGoal': proteinGoal,
        'carbsGoal': carbsGoal,
        'fatGoal': fatGoal,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        goal: j['goal'] ?? 'Lose Weight',
        gender: j['gender'] ?? 'Male',
        age: (j['age'] ?? 25) as int,
        heightCm: ((j['heightCm'] ?? 175) as num).toDouble(),
        weightKg: ((j['weightKg'] ?? 75) as num).toDouble(),
        targetWeightKg: ((j['targetWeightKg'] ?? 70) as num).toDouble(),
        activityLevel: j['activityLevel'] ?? 'Moderately Active',
        dailyCalorieGoal: (j['dailyCalorieGoal'] ?? 2000) as int,
        proteinGoal: (j['proteinGoal'] ?? 150) as int,
        carbsGoal: (j['carbsGoal'] ?? 200) as int,
        fatGoal: (j['fatGoal'] ?? 60) as int,
      );

  UserProfile copyWith({
    double? weightKg,
    double? targetWeightKg,
    int? age,
    String? activityLevel,
    int? dailyCalorieGoal,
    int? proteinGoal,
    int? carbsGoal,
    int? fatGoal,
  }) =>
      UserProfile(
        goal: goal,
        gender: gender,
        age: age ?? this.age,
        heightCm: heightCm,
        weightKg: weightKg ?? this.weightKg,
        targetWeightKg: targetWeightKg ?? this.targetWeightKg,
        activityLevel: activityLevel ?? this.activityLevel,
        dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
        proteinGoal: proteinGoal ?? this.proteinGoal,
        carbsGoal: carbsGoal ?? this.carbsGoal,
        fatGoal: fatGoal ?? this.fatGoal,
      );
}

class AppSettings {
  String unitsSystem;
  int defaultRestSeconds;
  bool notificationsEnabled;
  int streakCount;
  bool hasCompletedOnboarding;
  String? lastActiveDateKey;

  AppSettings({
    this.unitsSystem = 'metric',
    this.defaultRestSeconds = 30,
    this.notificationsEnabled = true,
    this.streakCount = 0,
    this.hasCompletedOnboarding = false,
    this.lastActiveDateKey,
  });

  Map<String, dynamic> toJson() => {
        'unitsSystem': unitsSystem,
        'defaultRestSeconds': defaultRestSeconds,
        'notificationsEnabled': notificationsEnabled,
        'streakCount': streakCount,
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'lastActiveDateKey': lastActiveDateKey,
      };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        unitsSystem: j['unitsSystem'] ?? 'metric',
        defaultRestSeconds: (j['defaultRestSeconds'] ?? 30) as int,
        notificationsEnabled: j['notificationsEnabled'] ?? true,
        streakCount: (j['streakCount'] ?? 0) as int,
        hasCompletedOnboarding: j['hasCompletedOnboarding'] ?? false,
        lastActiveDateKey: j['lastActiveDateKey'] as String?,
      );

  AppSettings copyWith({
    String? unitsSystem,
    int? defaultRestSeconds,
    bool? notificationsEnabled,
    int? streakCount,
    bool? hasCompletedOnboarding,
    String? lastActiveDateKey,
  }) =>
      AppSettings(
        unitsSystem: unitsSystem ?? this.unitsSystem,
        defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        streakCount: streakCount ?? this.streakCount,
        hasCompletedOnboarding:
            hasCompletedOnboarding ?? this.hasCompletedOnboarding,
        lastActiveDateKey: lastActiveDateKey ?? this.lastActiveDateKey,
      );
}

// --- THE SERVICE (ChangeNotifier singleton) ---

class LocalStorageService extends ChangeNotifier {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  final _prefs = SharedPreferencesAsync();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Auth
  bool _isLoggedIn = false;
  String? _userName;
  String? _userEmail;
  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  // Profile
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  // Settings
  AppSettings _settings = AppSettings();
  AppSettings get settings => _settings;

  // Logs
  Map<String, DailyLog> _dailyLogs = {};
  Map<String, DailyLog> get dailyLogs => Map.unmodifiable(_dailyLogs);

  // Weight history
  List<WeightEntry> _weightHistory = [];
  List<WeightEntry> get weightHistory => List.unmodifiable(_weightHistory);

  // --- INIT ---
  Future<void> init() async {
    _isLoggedIn = await _prefs.getBool('isLoggedIn') ?? false;
    _userName = await _prefs.getString('userName');
    _userEmail = await _prefs.getString('userEmail');

    final profileRaw = await _prefs.getString('userProfile');
    if (profileRaw != null) {
      _userProfile = UserProfile.fromJson(jsonDecode(profileRaw));
    }

    final settingsRaw = await _prefs.getString('appSettings');
    if (settingsRaw != null) {
      _settings = AppSettings.fromJson(jsonDecode(settingsRaw));
    }

    final logsRaw = await _prefs.getString('dailyLogs');
    if (logsRaw != null) {
      final decoded = jsonDecode(logsRaw) as Map<String, dynamic>;
      _dailyLogs =
          decoded.map((k, v) => MapEntry(k, DailyLog.fromJson(v)));
    }

    final weightsRaw = await _prefs.getString('weightHistory');
    if (weightsRaw != null) {
      final decoded = jsonDecode(weightsRaw) as List;
      _weightHistory = decoded.map((e) => WeightEntry.fromJson(e)).toList();
    }

    _isInitialized = true;
    notifyListeners();
  }

  // --- AUTH ---
  Future<void> signUpOrLogin({
    required String name,
    required String email,
    bool guest = false,
  }) async {
    _isLoggedIn = true;
    _userName = guest ? 'Guest' : name;
    _userEmail = guest ? 'guest@local' : email;
    await _prefs.setBool('isLoggedIn', true);
    await _prefs.setString('userName', _userName!);
    await _prefs.setString('userEmail', _userEmail!);
    notifyListeners();
  }

  Future<void> logOut({bool clearData = false}) async {
    _isLoggedIn = false;
    if (clearData) {
      await _prefs.clear();
      _userProfile = null;
      _dailyLogs.clear();
      _weightHistory.clear();
      _settings = AppSettings();
      _userName = null;
      _userEmail = null;
    } else {
      await _prefs.setBool('isLoggedIn', false);
    }
    notifyListeners();
  }

  // --- PROFILE ---
  Future<void> saveProfile(UserProfile profile) async {
    _userProfile = profile;
    _settings = _settings.copyWith(hasCompletedOnboarding: true);
    await _prefs.setString('userProfile', jsonEncode(profile.toJson()));
    await _prefs.setString('appSettings', jsonEncode(_settings.toJson()));
    notifyListeners();
  }

  // --- SETTINGS ---
  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
    await _prefs.setString('appSettings', jsonEncode(settings.toJson()));
    notifyListeners();
  }

  // --- STREAK HELPER ---
  Future<void> _touchStreak() async {
    final today = todayKey();
    if (_settings.lastActiveDateKey == today) return;

    final yesterdayDate = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey = _dateKey(yesterdayDate);

    final nextStreak = _settings.lastActiveDateKey == yesterdayKey
        ? (_settings.streakCount == 0 ? 1 : _settings.streakCount + 1)
        : 1;

    _settings = _settings.copyWith(
      streakCount: nextStreak,
      lastActiveDateKey: today,
    );
    await _prefs.setString('appSettings', jsonEncode(_settings.toJson()));
  }

  // --- DAILY LOGS ---
  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String todayKey() => _dateKey(DateTime.now());

  DailyLog getLog(DateTime date) {
    final key = _dateKey(date);
    return _dailyLogs[key] ?? DailyLog();
  }

  DailyLog getTodayLog() => getLog(DateTime.now());

  Future<void> updateLog(
    DateTime date, {
    int? waterGlasses,
    double? caloriesEaten,
    double? caloriesBurned,
    double? proteinEaten,
    double? carbsEaten,
    double? fatEaten,
    List<String>? loggedMeals,
    List<String>? completedWorkouts,
  }) async {
    final key = _dateKey(date);
    final current = _dailyLogs[key] ?? DailyLog();
    _dailyLogs[key] = DailyLog(
      waterGlasses: waterGlasses ?? current.waterGlasses,
      caloriesEaten: caloriesEaten ?? current.caloriesEaten,
      caloriesBurned: caloriesBurned ?? current.caloriesBurned,
      proteinEaten: proteinEaten ?? current.proteinEaten,
      carbsEaten: carbsEaten ?? current.carbsEaten,
      fatEaten: fatEaten ?? current.fatEaten,
      loggedMeals: loggedMeals ?? current.loggedMeals,
      completedWorkouts: completedWorkouts ?? current.completedWorkouts,
    );
    await _persistLogs();
    await _touchStreak();
    notifyListeners();
  }

  Future<void> updateTodayLog({
    int? waterGlasses,
    double? caloriesEaten,
    double? caloriesBurned,
    double? proteinEaten,
    double? carbsEaten,
    double? fatEaten,
    List<String>? loggedMeals,
    List<String>? completedWorkouts,
  }) =>
      updateLog(
        DateTime.now(),
        waterGlasses: waterGlasses,
        caloriesEaten: caloriesEaten,
        caloriesBurned: caloriesBurned,
        proteinEaten: proteinEaten,
        carbsEaten: carbsEaten,
        fatEaten: fatEaten,
        loggedMeals: loggedMeals,
        completedWorkouts: completedWorkouts,
      );

  Future<void> _persistLogs() async {
    final data = _dailyLogs.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs.setString('dailyLogs', jsonEncode(data));
  }

  // --- WEIGHT HISTORY ---
  Future<void> addWeight(double weightKg) async {
    _weightHistory.add(WeightEntry(date: DateTime.now(), weightKg: weightKg));
    await _prefs.setString(
      'weightHistory',
      jsonEncode(_weightHistory.map((e) => e.toJson()).toList()),
    );
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(weightKg: weightKg);
      await _prefs.setString('userProfile', jsonEncode(_userProfile!.toJson()));
    }
    await _touchStreak();
    notifyListeners();
  }

  // --- RECOMPUTE MACROS AFTER EDIT ---
  UserProfile recalculateProfile(
    UserProfile p, {
    double? weight,
    double? targetWeight,
    int? age,
    String? activity,
  }) {
    final w = weight ?? p.weightKg;
    final a = age ?? p.age;
    final act = activity ?? p.activityLevel;

    double bmr = (10 * w) +
        (6.25 * p.heightCm) -
        (5 * a) +
        (p.gender == 'Male' ? 5 : -161);
    double mult = 1.2;
    if (act == 'Lightly Active') mult = 1.375;
    if (act == 'Moderately Active') mult = 1.55;
    if (act == 'Very Active') mult = 1.725;
    double tdee = bmr * mult;
    if (p.goal == 'Lose Weight') tdee -= 500;
    if (p.goal == 'Build Muscle') tdee += 300;

    final prot = w * 2.2;
    final fat = w * 0.8;
    final carb = (tdee - (prot * 4) - (fat * 9)) / 4;

    return p.copyWith(
      weightKg: w,
      targetWeightKg: targetWeight ?? p.targetWeightKg,
      age: a,
      activityLevel: act,
      dailyCalorieGoal: tdee.round(),
      proteinGoal: prot.round(),
      carbsGoal: carb.round(),
      fatGoal: fat.round(),
    );
  }
}