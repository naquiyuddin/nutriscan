import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';
import 'local_storage_service.dart';
import 'main.dart';
import 'theme.dart';

// --- 1. LANDING SCREEN ---
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    await AuthService.instance.signInWithGoogle();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingQuiz()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.15),
                    AppTheme.background,
                    AppTheme.background,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    'Transform your\nbody & mind.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.1,
                      letterSpacing: -1.5,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  Text(
                    'Track your meals, crush your workouts, and hit your goals with the power of AI.',
                    style: AppTheme.darkTheme.textTheme.bodyLarge,
                  ).animate().fadeIn(delay: 200.ms),
                  const Spacer(flex: 3),

                  // Google Button
                  ElevatedButton.icon(
                    onPressed: () => _handleGoogleSignIn(context),
                    icon: const FaIcon(
                      FontAwesomeIcons.google,
                      color: AppTheme.background,
                      size: 20,
                    ),
                    label: const Text('Continue with Google'),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),

                  // Email Button
                  OutlinedButton.icon(
                    onPressed: () => _showAuthSheet(context),
                    icon: const Icon(Icons.email, color: AppTheme.textPrimary),
                    label: const Text('Continue with Email'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.border),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAuthSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => const AuthBottomSheet(),
    );
  }
}

// --- 2. AUTH BOTTOM SHEET ---
class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key});

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await AuthService.instance.signInWithEmail(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingQuiz()),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isLogin ? 'Welcome Back' : 'Create Account',
              style: AppTheme.darkTheme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (val) => (val == null || val.isEmpty || !val.contains('@'))
                  ? 'Enter a valid email'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (val) => (val == null || val.length < 6)
                  ? 'Password must be 6+ characters'
                  : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator(color: AppTheme.background)
                  : Text(_isLogin ? 'Log In' : 'Sign Up'),
            ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin
                    ? 'Don\'t have an account? Sign Up'
                    : 'Already have an account? Log In',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- 3. ONBOARDING QUIZ ---
class OnboardingQuiz extends StatefulWidget {
  const OnboardingQuiz({super.key});

  @override
  State<OnboardingQuiz> createState() => _OnboardingQuizState();
}

class _OnboardingQuizState extends State<OnboardingQuiz> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  String _goal = 'Lose Weight';
  String _gender = 'Male';
  int _age = 25;
  double _height = 175;
  double _weight = 80;
  double _targetWeight = 75;
  String _activity = 'Moderately Active';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _calculatePlan();
    }
  }

  void _calculatePlan() {
    double bmr;
    if (_gender == 'Male') {
      bmr = (10 * _weight) + (6.25 * _height) - (5 * _age) + 5;
    } else {
      bmr = (10 * _weight) + (6.25 * _height) - (5 * _age) - 161;
    }

    double multiplier = 1.2;
    if (_activity == 'Lightly Active') multiplier = 1.375;
    if (_activity == 'Moderately Active') multiplier = 1.55;
    if (_activity == 'Very Active') multiplier = 1.725;

    double tdee = bmr * multiplier;
    if (_goal == 'Lose Weight') tdee -= 500;
    if (_goal == 'Build Muscle') tdee += 300;

    double protein = _weight * 2.2;
    double fat = _weight * 0.8;
    double carbs = (tdee - (protein * 4) - (fat * 9)) / 4;

    final profile = UserProfile(
      goal: _goal,
      gender: _gender,
      age: _age,
      heightCm: _height,
      weightKg: _weight,
      targetWeightKg: _targetWeight,
      activityLevel: _activity,
      dailyCalorieGoal: tdee.round(),
      proteinGoal: protein.round(),
      carbsGoal: carbs.round(),
      fatGoal: fat.round(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PlanSummaryScreen(
          profile: profile,
          calories: tdee.round(),
          protein: protein.round(),
          carbs: carbs.round(),
          fat: fat.round(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppTheme.textPrimary),
                    onPressed: () {
                      if (_currentStep > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0,
                          end: (_currentStep + 1) / _totalSteps,
                        ),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          backgroundColor: AppTheme.surface,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primary,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (val) => setState(() => _currentStep = val),
                children: [
                  _buildGoalStep(),
                  _buildBodyStatsStep(),
                  _buildTargetWeightStep(),
                  _buildActivityStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _nextStep,
                child: Text(
                  _currentStep == _totalSteps - 1
                      ? 'Calculate My Plan'
                      : 'Continue',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalStep() {
    final goals = [
      {'title': 'Lose Weight', 'icon': Icons.trending_down},
      {'title': 'Build Muscle', 'icon': Icons.trending_up},
      {'title': 'Maintain', 'icon': Icons.horizontal_rule},
    ];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What is your primary goal?',
              style: AppTheme.darkTheme.textTheme.headlineLarge),
          const SizedBox(height: 40),
          ...goals.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => setState(() => _goal = g['title'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _goal == g['title']
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _goal == g['title']
                          ? AppTheme.primary
                          : AppTheme.border,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        g['icon'] as IconData,
                        color: _goal == g['title']
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                        size: 30,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        g['title'] as String,
                        style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                          color: _goal == g['title']
                              ? AppTheme.primary
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyStatsStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about yourself',
              style: AppTheme.darkTheme.textTheme.headlineLarge),
          const SizedBox(height: 30),
          Row(
            children: ['Male', 'Female']
                .map(
                  (g) => Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _gender = g),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _gender == g
                              ? AppTheme.primary
                              : AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            g,
                            style: TextStyle(
                              color: _gender == g
                                  ? AppTheme.background
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 40),
          Text('Age: $_age', style: AppTheme.darkTheme.textTheme.titleLarge),
          Slider(
            value: _age.toDouble(),
            min: 15,
            max: 80,
            divisions: 65,
            activeColor: AppTheme.primary,
            onChanged: (val) => setState(() => _age = val.round()),
          ),
          const SizedBox(height: 20),
          Text('Height: ${_height.round()} cm',
              style: AppTheme.darkTheme.textTheme.titleLarge),
          Slider(
            value: _height,
            min: 140,
            max: 210,
            divisions: 70,
            activeColor: AppTheme.primary,
            onChanged: (val) => setState(() => _height = val),
          ),
          const SizedBox(height: 20),
          Text('Current Weight: ${_weight.round()} kg',
              style: AppTheme.darkTheme.textTheme.titleLarge),
          Slider(
            value: _weight,
            min: 40,
            max: 150,
            divisions: 110,
            activeColor: AppTheme.primary,
            onChanged: (val) => setState(() => _weight = val),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetWeightStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What is your target weight?',
              style: AppTheme.darkTheme.textTheme.headlineLarge),
          const SizedBox(height: 60),
          Center(
            child: Text(
              '${_targetWeight.round()} kg',
              style: AppTheme.darkTheme.textTheme.displayLarge
                  ?.copyWith(color: AppTheme.primary),
            ),
          ),
          const SizedBox(height: 40),
          Slider(
            value: _targetWeight,
            min: 40,
            max: 150,
            divisions: 110,
            activeColor: AppTheme.primary,
            onChanged: (val) => setState(() => _targetWeight = val),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              _targetWeight < _weight
                  ? 'You want to lose ${(_weight - _targetWeight).round()} kg'
                  : 'You want to gain ${(_targetWeight - _weight).round()} kg',
              style: AppTheme.darkTheme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStep() {
    final levels = [
      {'title': 'Sedentary', 'desc': 'Little to no exercise'},
      {'title': 'Lightly Active', 'desc': '1-3 days/week'},
      {'title': 'Moderately Active', 'desc': '3-5 days/week'},
      {'title': 'Very Active', 'desc': '6-7 days/week'},
    ];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How active are you?',
              style: AppTheme.darkTheme.textTheme.headlineLarge),
          const SizedBox(height: 30),
          ...levels.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _activity = l['title'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _activity == l['title']
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _activity == l['title']
                          ? AppTheme.primary
                          : AppTheme.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l['title'] as String,
                            style: AppTheme.darkTheme.textTheme.titleMedium
                                ?.copyWith(color: AppTheme.textPrimary),
                          ),
                          Text(
                            l['desc'] as String,
                            style: AppTheme.darkTheme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      if (_activity == l['title'])
                        const Icon(Icons.check_circle, color: AppTheme.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 4. SUMMARY SCREEN ---
class PlanSummaryScreen extends StatelessWidget {
  final UserProfile profile;
  final int calories, protein, carbs, fat;

  const PlanSummaryScreen({
    super.key,
    required this.profile,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(Icons.check_circle, color: AppTheme.primary, size: 80)
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                'Your Plan is Ready!',
                style: AppTheme.darkTheme.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              Text(
                'Based on your goal to ${profile.goal.toLowerCase()}, here is your daily target.',
                style: AppTheme.darkTheme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    Text('Daily Calories',
                        style: AppTheme.darkTheme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      '$calories',
                      style: AppTheme.darkTheme.textTheme.displayLarge
                          ?.copyWith(color: AppTheme.primary),
                    ),
                    Text('kcal / day',
                        style: AppTheme.darkTheme.textTheme.bodyMedium),
                  ],
                ),
              ).animate().slideY(begin: 0.2, end: 0, delay: 600.ms),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _macroCard('Protein', '${protein}g', AppTheme.accentCoral),
                  _macroCard('Carbs', '${carbs}g', Colors.blue),
                  _macroCard('Fat', '${fat}g', Colors.amber),
                ],
              ).animate().fadeIn(delay: 800.ms),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await LocalStorageService.instance.saveProfile(profile);
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                    );
                  }
                },
                child: const Text('Start My Journey'),
              ).animate().fadeIn(delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _macroCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: AppTheme.darkTheme.textTheme.titleLarge
                  ?.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label,
              style:
                  AppTheme.darkTheme.textTheme.bodySmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}