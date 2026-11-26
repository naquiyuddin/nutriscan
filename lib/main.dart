import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// Import our custom files
import 'home_tab.dart';
import 'local_storage_service.dart';
import 'onboarding_flow.dart';
import 'profile_tab.dart';
import 'recipes_tab.dart';
import 'theme.dart';
import 'workout_tab.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await LocalStorageService.instance.init();
  runApp(const CalorieApp());
}

class CalorieApp extends StatelessWidget {
  const CalorieApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LocalStorageService.instance;
    final Widget startScreen =
        (s.isLoggedIn && s.settings.hasCompletedOnboarding)
            ? const MainScreen()
            : const LandingScreen();

    return MaterialApp(
      title: 'NutriScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: startScreen,
    );
  }
}

// --- MAIN NAVIGATION SHELL ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeTab(),
    WorkoutTab(),
    RecipesTab(),
    ProfileTab(),
  ];

  Future<void> _openCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      if (!mounted) return;

      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );

      if (!mounted || result == null) return;

      // === Parse AI response for calories and macros ===
      final calMatch = RegExp(r'(\d{2,4})\s*kcal').firstMatch(result);
      final baseCalories =
          calMatch != null ? int.tryParse(calMatch.group(1)!) ?? 400 : 400;

      final proteinMatch =
          RegExp(r'[Pp]rotein[:\s~*]*(\d{1,3})').firstMatch(result);
      final carbsMatch =
          RegExp(r'[Cc]arbs?[:\s~*]*(\d{1,3})').firstMatch(result);
      final fatMatch = RegExp(r'[Ff]at[:\s~*]*(\d{1,3})').firstMatch(result);

      final baseProtein =
          proteinMatch != null ? int.tryParse(proteinMatch.group(1)!) ?? 0 : 0;
      final baseCarbs =
          carbsMatch != null ? int.tryParse(carbsMatch.group(1)!) ?? 0 : 0;
      final baseFat =
          fatMatch != null ? int.tryParse(fatMatch.group(1)!) ?? 0 : 0;

      String foodName = 'Scanned Meal';
      for (final line in result.split('\n')) {
        final cleaned = line.replaceAll(RegExp(r'[*#\-~_]'), '').trim();
        if (cleaned.isEmpty) continue;
        final lower = cleaned.toLowerCase();
        if (lower.startsWith('food') ||
            lower.startsWith('calorie') ||
            lower.startsWith('protein') ||
            lower.startsWith('carbs') ||
            lower.startsWith('fat') ||
            lower.startsWith('based')) {
          continue;
        }
        foodName =
            cleaned.length > 50 ? '${cleaned.substring(0, 50)}...' : cleaned;
        break;
      }

      if (!mounted) return;

      // Keep serving state outside StatefulBuilder's builder closure
      double serving = 1.0;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return StatefulBuilder(
                builder: (context, setSheetState) {
                  final scaledCals = (baseCalories * serving).round();
                  final scaledProtein = (baseProtein * serving).round();
                  final scaledCarbs = (baseCarbs * serving).round();
                  final scaledFat = (baseFat * serving).round();

                  return Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppTheme.border,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Scan Result',
                                  style: AppTheme
                                      .darkTheme.textTheme.headlineMedium),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      foodName,
                                      style: AppTheme
                                          .darkTheme.textTheme.titleLarge,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _macroChip('$scaledCals kcal',
                                            AppTheme.accentCoral),
                                        if (baseProtein > 0)
                                          _macroChip('${scaledProtein}g P',
                                              Colors.purpleAccent),
                                        if (baseCarbs > 0)
                                          _macroChip('${scaledCarbs}g C',
                                              Colors.blueAccent),
                                        if (baseFat > 0)
                                          _macroChip('${scaledFat}g F',
                                              Colors.orangeAccent),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceHighlight,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Serving Size',
                                        style: AppTheme
                                            .darkTheme.textTheme.titleMedium),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _servingBtn('−', () {
                                          HapticFeedback.selectionClick();
                                          setSheetState(() {
                                            serving = (serving - 0.5)
                                                .clamp(0.5, 5.0);
                                          });
                                        }),
                                        Text(
                                          '${serving.toStringAsFixed(1)}x',
                                          style: AppTheme.darkTheme.textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                  color: AppTheme.primary),
                                        ),
                                        _servingBtn('+', () {
                                          HapticFeedback.selectionClick();
                                          setSheetState(() {
                                            serving = (serving + 0.5)
                                                .clamp(0.5, 5.0);
                                          });
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Divider(color: AppTheme.border),
                              const SizedBox(height: 16),
                              Text('AI Analysis',
                                  style: AppTheme
                                      .darkTheme.textTheme.titleMedium),
                              const SizedBox(height: 8),
                              MarkdownBody(
                                data: result,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                    height: 1.6,
                                  ),
                                  strong: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  listBullet:
                                      const TextStyle(color: AppTheme.primary),
                                ),
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  HapticFeedback.mediumImpact();
                                  final ls = LocalStorageService.instance;
                                  final current = ls.getTodayLog();
                                  await ls.updateLog(
                                    DateTime.now(),
                                    caloriesEaten:
                                        current.caloriesEaten + scaledCals,
                                    proteinEaten:
                                        current.proteinEaten + scaledProtein,
                                    carbsEaten:
                                        current.carbsEaten + scaledCarbs,
                                    fatEaten: current.fatEaten + scaledFat,
                                    loggedMeals: [
                                      ...current.loggedMeals,
                                      '$foodName (${serving.toStringAsFixed(1)}x)',
                                    ],
                                  );
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Logged: $scaledCals kcal added'),
                                      backgroundColor: AppTheme.primary,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check),
                                label: Text('Log to Diary ($scaledCals kcal)'),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Camera error: $e')));
    }
  }

  Widget _macroChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _servingBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        height: 75,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem(Icons.home_outlined, Icons.home, 'Home', 0),
                  _navItem(Icons.fitness_center_outlined, Icons.fitness_center,
                      'Workouts', 1),
                  const SizedBox(width: 60),
                  _navItem(Icons.restaurant_menu_outlined,
                      Icons.restaurant_menu, 'Recipes', 2),
                  _navItem(Icons.person_outline, Icons.person, 'Profile', 3),
                ],
              ),
            ),
            Positioned(
              top: -20,
              left: MediaQuery.of(context).size.width / 2 - 70,
              child: GestureDetector(
                onTap: _openCamera,
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.background, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.document_scanner,
                    color: AppTheme.background,
                    size: 32,
                  ),
                ),
              ).animate().scale(
                  delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
      IconData outlineIcon, IconData filledIcon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected ? AppTheme.primary : AppTheme.textTertiary,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primary : AppTheme.textTertiary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PREMIUM SCANNER UI ---
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isProcessing = false;
  String _scanMode = 'AI Meal';
  late AnimationController _laserController;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras.first, ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _laserController.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndScan() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() => _isProcessing = true);

    try {
      final XFile picture = await _controller!.takePicture();
      final bytes = await picture.readAsBytes();

      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      final model = GenerativeModel(model: 'gemini-3.5-flash', apiKey: apiKey);

      final prompt = Content.multi([
        TextPart(
          "Identify the food. Estimate calories and macros. Format using bullet points (Food, Calories, Protein, Carbs, Fat). Keep it brief and professional.",
        ),
        DataPart('image/jpeg', bytes),
      ]);

      final response = await model.generateContent([prompt]);
      if (mounted) {
        Navigator.pop(context, response.text ?? "Could not identify food.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            Positioned.fill(child: CameraPreview(_controller!))
          else
            const Center(
                child: CircularProgressIndicator(color: AppTheme.primary)),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      _modeButton('AI Meal', Icons.camera_alt),
                      _modeButton('Barcode', Icons.qr_code_scanner),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                children: [
                  ..._buildCorners(),
                  if (!_isProcessing)
                    AnimatedBuilder(
                      animation: _laserController,
                      builder: (context, child) {
                        return Positioned(
                          top: _laserController.value * 280,
                          left: 10,
                          right: 10,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Align food inside the frame',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _isProcessing ? null : _takePictureAndScan,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.5),
                            blurRadius: 20),
                      ],
                    ),
                    child: _isProcessing
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                                color: AppTheme.background),
                          )
                        : const Icon(
                            Icons.center_focus_strong,
                            color: AppTheme.background,
                            size: 40,
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 24),
                    Text(
                      'Analyzing Nutrients...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _modeButton(String mode, IconData icon) {
    final isActive = _scanMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _scanMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16, color: isActive ? AppTheme.background : Colors.white),
            const SizedBox(width: 6),
            Text(
              mode,
              style: TextStyle(
                color: isActive ? AppTheme.background : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCorners() {
    const double len = 40;
    const double thick = 4;
    return [
      Positioned(
          top: 0,
          left: 0,
          child: _corner(top: true, left: true, len: len, thick: thick)),
      Positioned(
          top: 0,
          right: 0,
          child: _corner(top: true, left: false, len: len, thick: thick)),
      Positioned(
          bottom: 0,
          left: 0,
          child: _corner(top: false, left: true, len: len, thick: thick)),
      Positioned(
          bottom: 0,
          right: 0,
          child: _corner(top: false, left: false, len: len, thick: thick)),
    ];
  }

  Widget _corner({
    required bool top,
    required bool left,
    required double len,
    required double thick,
  }) {
    return Container(
      width: len,
      height: len,
      decoration: BoxDecoration(
        border: Border(
          top: top
              ? BorderSide(color: AppTheme.primary, width: thick)
              : BorderSide.none,
          bottom: !top
              ? BorderSide(color: AppTheme.primary, width: thick)
              : BorderSide.none,
          left: left
              ? BorderSide(color: AppTheme.primary, width: thick)
              : BorderSide.none,
          right: !left
              ? BorderSide(color: AppTheme.primary, width: thick)
              : BorderSide.none,
        ),
      ),
    );
  }
}