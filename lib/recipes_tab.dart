import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'local_storage_service.dart';
import 'theme.dart';

// --- RECIPE MODEL ---
class Recipe {
  final String id;
  final String name;
  final String category;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int prepMinutes;
  final Color accentColor;
  final IconData icon;
  final List<String> ingredients;
  final List<String> steps;

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.prepMinutes,
    required this.accentColor,
    required this.icon,
    required this.ingredients,
    required this.steps,
  });

  String get tag {
    if (protein >= 25) return 'High Protein';
    if (carbs <= 15) return 'Low Carb';
    if (calories < 400) return 'Under 400 kcal';
    return category;
  }
}

// --- RECIPE DATA ---
final List<Recipe> kRecipes = [
  // BREAKFAST
  Recipe(
    id: 'avocado_toast', name: 'Avocado Toast with Egg', category: 'Breakfast',
    calories: 320, protein: 14, carbs: 28, fat: 18, prepMinutes: 10,
    accentColor: const Color(0xFFFFA726), icon: Icons.egg_alt,
    ingredients: ['2 slices whole grain bread', '1/2 ripe avocado', '1 boiled egg', 'Pinch of chili flakes', 'Salt and pepper'],
    steps: ['Toast the bread until golden.', 'Mash the avocado with salt and pepper.', 'Spread on toast.', 'Slice the egg on top and add chili flakes.'],
  ),
  Recipe(
    id: 'overnight_oats', name: 'Overnight Oats with Berries', category: 'Breakfast',
    calories: 340, protein: 15, carbs: 48, fat: 8, prepMinutes: 5,
    accentColor: const Color(0xFF8D6E63), icon: Icons.breakfast_dining,
    ingredients: ['1/2 cup rolled oats', '1/2 cup Greek yogurt', '1/2 cup almond milk', '1 tbsp honey', 'Handful of strawberries'],
    steps: ['Mix oats, yogurt, and milk in a jar.', 'Stir in honey.', 'Refrigerate overnight.', 'Top with strawberries before eating.'],
  ),
  Recipe(
    id: 'egg_white_omelet', name: 'Spinach Feta Omelet', category: 'Breakfast',
    calories: 210, protein: 22, carbs: 4, fat: 12, prepMinutes: 10,
    accentColor: const Color(0xFFFFEE58), icon: Icons.egg_alt,
    ingredients: ['4 egg whites', '1 cup spinach', '1/4 cup feta cheese', '1 tsp olive oil', 'Salt and pepper'],
    steps: ['Heat olive oil in a pan.', 'Sauté spinach until wilted.', 'Pour egg whites over spinach.', 'Sprinkle feta on top, fold, and serve.'],
  ),
  Recipe(
    id: 'protein_smoothie', name: 'Berry Protein Smoothie', category: 'Breakfast',
    calories: 250, protein: 28, carbs: 22, fat: 4, prepMinutes: 3,
    accentColor: const Color(0xFFAB47BC), icon: Icons.blender,
    ingredients: ['1 scoop whey protein', '1/2 cup mixed berries', '1 cup almond milk', '1 tsp chia seeds'],
    steps: ['Add all ingredients to a blender.', 'Blend until smooth.', 'Pour into a glass and serve.'],
  ),

  // LUNCH
  Recipe(
    id: 'grilled_chicken_salad', name: 'Grilled Chicken Salad', category: 'Lunch',
    calories: 380, protein: 42, carbs: 12, fat: 18, prepMinutes: 15,
    accentColor: const Color(0xFF66BB6A), icon: Icons.local_florist,
    ingredients: ['150g chicken breast', '2 cups mixed lettuce', '1/2 cup cherry tomatoes', '1 tbsp olive oil', 'Juice of 1/2 lemon'],
    steps: ['Grill chicken for 6 minutes per side.', 'Slice chicken.', 'Toss lettuce and tomatoes with olive oil and lemon.', 'Top with chicken and serve.'],
  ),
  Recipe(
    id: 'tuna_wrap', name: 'Tuna Lettuce Wraps', category: 'Lunch',
    calories: 280, protein: 30, carbs: 8, fat: 14, prepMinutes: 8,
    accentColor: const Color(0xFF42A5F5), icon: Icons.lunch_dining,
    ingredients: ['1 can tuna in water', '2 tbsp Greek yogurt', '1 celery stalk, chopped', '4 large lettuce leaves', 'Salt and pepper'],
    steps: ['Drain tuna and mix with yogurt.', 'Add chopped celery, salt, and pepper.', 'Spoon mixture into lettuce leaves.', 'Roll and serve.'],
  ),
  Recipe(
    id: 'quinoa_bowl', name: 'Quinoa Buddha Bowl', category: 'Lunch',
    calories: 440, protein: 18, carbs: 58, fat: 14, prepMinutes: 20,
    accentColor: const Color(0xFF26C6DA), icon: Icons.rice_bowl,
    ingredients: ['1/2 cup quinoa', '1/2 cup chickpeas', '1 cup spinach', '1/2 sweet potato, roasted', '2 tbsp tahini dressing'],
    steps: ['Cook quinoa per package instructions.', 'Roast sweet potato at 200°C for 15 min.', 'Assemble quinoa, chickpeas, spinach, and sweet potato in a bowl.', 'Drizzle with tahini.'],
  ),
  Recipe(
    id: 'turkey_sandwich', name: 'Turkey Avocado Sandwich', category: 'Lunch',
    calories: 410, protein: 32, carbs: 38, fat: 15, prepMinutes: 6,
    accentColor: const Color(0xFF9CCC65), icon: Icons.lunch_dining,
    ingredients: ['2 slices whole grain bread', '100g sliced turkey breast', '1/4 avocado', 'Lettuce and tomato', '1 tsp mustard'],
    steps: ['Toast bread.', 'Spread mustard and mashed avocado.', 'Layer turkey, lettuce, and tomato.', 'Close sandwich and slice.'],
  ),

  // DINNER
  Recipe(
    id: 'baked_salmon', name: 'Baked Salmon with Asparagus', category: 'Dinner',
    calories: 460, protein: 40, carbs: 8, fat: 28, prepMinutes: 20,
    accentColor: const Color(0xFF42A5F5), icon: Icons.set_meal,
    ingredients: ['150g salmon fillet', '1 bunch asparagus', '2 cloves garlic, minced', '1 tbsp olive oil', 'Lemon slices'],
    steps: ['Preheat oven to 200°C.', 'Place salmon and asparagus on a baking tray.', 'Drizzle with olive oil and garlic.', 'Bake for 15 minutes. Serve with lemon.'],
  ),
  Recipe(
    id: 'chicken_stirfry', name: 'Chicken Broccoli Stir-Fry', category: 'Dinner',
    calories: 390, protein: 38, carbs: 18, fat: 16, prepMinutes: 15,
    accentColor: const Color(0xFFFF7043), icon: Icons.soup_kitchen,
    ingredients: ['150g chicken breast, sliced', '2 cups broccoli florets', '2 tbsp soy sauce', '1 clove garlic', '1 tsp sesame oil'],
    steps: ['Sear chicken in a hot pan for 5 min.', 'Add broccoli and garlic.', 'Stir-fry for 5 min.', 'Add soy sauce and sesame oil, toss and serve.'],
  ),
  Recipe(
    id: 'beef_broccoli', name: 'Lean Beef & Broccoli', category: 'Dinner',
    calories: 420, protein: 36, carbs: 14, fat: 22, prepMinutes: 15,
    accentColor: const Color(0xFFEF5350), icon: Icons.set_meal,
    ingredients: ['120g lean beef strips', '2 cups broccoli', '2 tbsp low-sodium soy sauce', '1 clove garlic', '1 tsp olive oil'],
    steps: ['Heat olive oil in a pan.', 'Sear beef until browned.', 'Add broccoli and garlic.', 'Pour soy sauce and cook for 5 more minutes.'],
  ),
  Recipe(
    id: 'cod_tomato', name: 'Baked Cod with Tomatoes', category: 'Dinner',
    calories: 260, protein: 32, carbs: 6, fat: 10, prepMinutes: 18,
    accentColor: const Color(0xFF4FC3F7), icon: Icons.set_meal,
    ingredients: ['150g cod fillet', '1 cup cherry tomatoes', 'Handful of olives', '1 tsp oregano', '1 tbsp olive oil'],
    steps: ['Preheat oven to 200°C.', 'Place cod in a baking dish.', 'Top with tomatoes, olives, oregano, and oil.', 'Bake for 15 minutes.'],
  ),
  Recipe(
    id: 'shrimp_zoodles', name: 'Shrimp & Zucchini Noodles', category: 'Dinner',
    calories: 290, protein: 28, carbs: 12, fat: 14, prepMinutes: 12,
    accentColor: const Color(0xFFF48FB1), icon: Icons.ramen_dining,
    ingredients: ['150g shrimp', '2 medium zucchinis, spiralized', '2 cloves garlic', '1 tbsp olive oil', 'Pinch of chili flakes'],
    steps: ['Sauté garlic in olive oil.', 'Add shrimp and cook 3 min per side.', 'Add zucchini noodles and chili flakes.', 'Toss for 2 min and serve.'],
  ),

  // SNACKS
  Recipe(
    id: 'greek_parfait', name: 'Greek Yogurt Parfait', category: 'Snacks',
    calories: 240, protein: 20, carbs: 24, fat: 6, prepMinutes: 5,
    accentColor: const Color(0xFF5C6BC0), icon: Icons.icecream,
    ingredients: ['1 cup Greek yogurt', '2 tbsp granola', 'Handful of blueberries', '1 tsp honey'],
    steps: ['Layer yogurt, granola, and berries in a glass.', 'Repeat the layers.', 'Drizzle with honey.'],
  ),
  Recipe(
    id: 'cottage_bowl', name: 'Cottage Cheese & Pineapple', category: 'Snacks',
    calories: 200, protein: 22, carbs: 18, fat: 4, prepMinutes: 3,
    accentColor: const Color(0xFF80DEEA), icon: Icons.icecream,
    ingredients: ['1 cup low-fat cottage cheese', '1/2 cup pineapple chunks', '1 tbsp walnuts'],
    steps: ['Spoon cottage cheese into a bowl.', 'Add pineapple chunks.', 'Top with walnuts.'],
  ),
  Recipe(
    id: 'apple_almond', name: 'Apple & Almond Butter', category: 'Snacks',
    calories: 220, protein: 6, carbs: 28, fat: 10, prepMinutes: 2,
    accentColor: const Color(0xFFC0CA33), icon: Icons.apple,
    ingredients: ['1 medium apple, sliced', '1 tbsp almond butter', 'Pinch of cinnamon'],
    steps: ['Slice apple.', 'Dip slices in almond butter.', 'Sprinkle with cinnamon.'],
  ),
  Recipe(
    id: 'protein_bites', name: 'No-Bake Protein Bites', category: 'Snacks',
    calories: 180, protein: 10, carbs: 18, fat: 8, prepMinutes: 10,
    accentColor: const Color(0xFF8D6E63), icon: Icons.cookie,
    ingredients: ['1/2 cup oats', '2 tbsp peanut butter', '1 scoop protein powder', '1 tbsp honey', '1 tbsp chia seeds'],
    steps: ['Mix all ingredients in a bowl.', 'Roll into small balls.', 'Refrigerate for 30 min.'],
  ),

  // MEAL PREP
  Recipe(
    id: 'chicken_mealprep', name: 'Meal-Prep Chicken & Rice', category: 'Meal Prep',
    calories: 520, protein: 45, carbs: 55, fat: 14, prepMinutes: 30,
    accentColor: const Color(0xFFFFA726), icon: Icons.rice_bowl,
    ingredients: ['200g chicken breast', '1 cup brown rice, cooked', '1 cup green beans', '1 tbsp olive oil', 'Salt and pepper'],
    steps: ['Cook rice per instructions.', 'Season and bake chicken at 200°C for 20 min.', 'Steam green beans.', 'Divide into 2 meal prep containers.'],
  ),
  Recipe(
    id: 'lentil_soup', name: 'Hearty Lentil Soup', category: 'Meal Prep',
    calories: 310, protein: 18, carbs: 42, fat: 6, prepMinutes: 25,
    accentColor: const Color(0xFF8D6E63), icon: Icons.soup_kitchen,
    ingredients: ['1 cup red lentils', '1 carrot, diced', '1 celery stalk, diced', '3 cups vegetable broth', '1 tsp cumin'],
    steps: ['Sauté carrot and celery for 3 min.', 'Add lentils, broth, and cumin.', 'Simmer for 20 min until lentils are soft.', 'Serve or refrigerate in portions.'],
  ),
  Recipe(
    id: 'sweet_potato_chili', name: 'Sweet Potato Black Bean Chili', category: 'Meal Prep',
    calories: 350, protein: 14, carbs: 58, fat: 6, prepMinutes: 30,
    accentColor: const Color(0xFF7E57C2), icon: Icons.soup_kitchen,
    ingredients: ['1 sweet potato, cubed', '1 can black beans, drained', '1 can diced tomatoes', '1 tsp chili powder', '1 tsp cumin'],
    steps: ['Sauté sweet potato for 5 min.', 'Add black beans, tomatoes, and spices.', 'Simmer for 20 min.', 'Serve or store for meal prep.'],
  ),
];

// --- SHARED LOGGING HELPER (calories + macros + meal name) ---
Future<void> logRecipeToDiary(Recipe r, double servings) async {
  final ls = LocalStorageService.instance;
  final log = ls.getTodayLog();
  await ls.updateTodayLog(
    caloriesEaten: log.caloriesEaten + (r.calories * servings).round(),
    proteinEaten: log.proteinEaten + (r.protein * servings).round(),
    carbsEaten: log.carbsEaten + (r.carbs * servings).round(),
    fatEaten: log.fatEaten + (r.fat * servings).round(),
    loggedMeals: [...log.loggedMeals, '${r.name} (${servings.toStringAsFixed(1)}x)'],
  );
}

// --- RECIPES TAB ---
class RecipesTab extends StatefulWidget {
  const RecipesTab({super.key});

  @override
  State<RecipesTab> createState() => _RecipesTabState();
}

class _RecipesTabState extends State<RecipesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<String> _filters = const [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'Meal Prep',
    'High Protein',
    'Low Carb',
    'Under 400 kcal',
    'Quick (<15m)',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> _filterRecipes() {
    final query = _searchQuery.trim().toLowerCase();
    return kRecipes.where((r) {
      if (query.isNotEmpty) {
        final matchesName = r.name.toLowerCase().contains(query);
        final matchesIngredient =
            r.ingredients.any((i) => i.toLowerCase().contains(query));
        if (!matchesName && !matchesIngredient) return false;
      }
      switch (_selectedFilter) {
        case 'All':
          return true;
        case 'High Protein':
          return r.protein >= 25;
        case 'Low Carb':
          return r.carbs <= 15;
        case 'Under 400 kcal':
          return r.calories < 400;
        case 'Quick (<15m)':
          return r.prepMinutes < 15;
        default:
          return r.category == _selectedFilter;
      }
    }).toList();
  }

  Future<void> _quickLog(Recipe r) async {
    HapticFeedback.mediumImpact();
    await logRecipeToDiary(r, 1.0);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged ${r.name} — ${r.calories} kcal'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _filterRecipes();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Healthy Recipes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search recipes or ingredients...',
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.textTertiary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
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
                        color: isSelected ? AppTheme.primary : AppTheme.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: recipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 60, color: AppTheme.textTertiary),
                        const SizedBox(height: 12),
                        Text('No recipes match your filters.',
                            style: AppTheme.darkTheme.textTheme.bodyMedium),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) =>
                        _buildRecipeCard(recipes[index], index),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe r, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: r)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: r.accentColor.withValues(alpha: 0.15),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Stack(
                  children: [
                    Center(child: Icon(r.icon, color: r.accentColor, size: 60)),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: r.accentColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          r.tag,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // One-tap "log 1 serving"
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _quickLog(r),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              size: 18, color: AppTheme.background),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.name,
                        style: AppTheme.darkTheme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule,
                            size: 12, color: AppTheme.textTertiary),
                        const SizedBox(width: 4),
                        Text('${r.prepMinutes} min',
                            style: AppTheme.darkTheme.textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                            child: _miniStat(r.calories.toString(), 'kcal',
                                AppTheme.accentCoral)),
                        Expanded(
                            child: _miniStat('${r.protein}g', 'protein',
                                Colors.purpleAccent)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (50 * index).ms).scale(begin: const Offset(0.95, 0.95)),
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label,
            style: AppTheme.darkTheme.textTheme.bodySmall
                ?.copyWith(fontSize: 10)),
      ],
    );
  }
}

// --- RECIPE DETAIL SCREEN ---
class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  double _servingMultiplier = 1.0;
  final Set<int> _checkedIngredients = {};
  bool _isLogging = false;

  int get _scaledCalories =>
      (widget.recipe.calories * _servingMultiplier).round();
  int get _scaledProtein =>
      (widget.recipe.protein * _servingMultiplier).round();
  int get _scaledCarbs => (widget.recipe.carbs * _servingMultiplier).round();
  int get _scaledFat => (widget.recipe.fat * _servingMultiplier).round();

  Future<void> _logMeal() async {
    setState(() => _isLogging = true);
    HapticFeedback.mediumImpact();

    await logRecipeToDiary(widget.recipe, _servingMultiplier);

    if (!mounted) return;
    setState(() => _isLogging = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Logged ${widget.recipe.name} — $_scaledCalories kcal, ${_scaledProtein}g protein'),
        backgroundColor: AppTheme.primary,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: r.accentColor.withValues(alpha: 0.2),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: r.accentColor.withValues(alpha: 0.15),
                child: Center(
                  child: Icon(r.icon, size: 120, color: r.accentColor),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name, style: AppTheme.darkTheme.textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: r.accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(r.category,
                            style: TextStyle(
                                color: r.accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.schedule,
                          size: 14, color: AppTheme.textTertiary),
                      const SizedBox(width: 4),
                      Text('${r.prepMinutes} min',
                          style: AppTheme.darkTheme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Servings
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.restaurant,
                                color: AppTheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text('Servings',
                                style: AppTheme.darkTheme.textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [0.5, 1.0, 1.5, 2.0].map((mult) {
                            final isSelected = _servingMultiplier == mult;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _servingMultiplier = mult);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.surfaceHighlight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${mult}x',
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.background
                                        : AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Macros
                  Row(
                    children: [
                      Expanded(
                          child: _macroTile(_scaledCalories.toString(), 'kcal',
                              AppTheme.accentCoral)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _macroTile('${_scaledProtein}g', 'Protein',
                              Colors.purpleAccent)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _macroTile(
                              '${_scaledCarbs}g', 'Carbs', Colors.blueAccent)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _macroTile(
                              '${_scaledFat}g', 'Fat', Colors.orangeAccent)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Ingredients
                  Text('Ingredients',
                      style: AppTheme.darkTheme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: List.generate(r.ingredients.length, (index) {
                        final ing = r.ingredients[index];
                        final isChecked = _checkedIngredients.contains(index);
                        return CheckboxListTile(
                          title: Text(
                            ing,
                            style: TextStyle(
                              color: isChecked
                                  ? AppTheme.textTertiary
                                  : AppTheme.textPrimary,
                              decoration:
                                  isChecked ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          value: isChecked,
                          activeColor: AppTheme.primary,
                          checkColor: AppTheme.background,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (val ?? false) {
                                _checkedIngredients.add(index);
                              } else {
                                _checkedIngredients.remove(index);
                              }
                            });
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Instructions
                  Text('Instructions',
                      style: AppTheme.darkTheme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...List.generate(r.steps.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('${index + 1}',
                                  style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(r.steps[index],
                                style: AppTheme.darkTheme.textTheme.bodyLarge),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _isLogging ? null : _logMeal,
                    icon: _isLogging
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.background),
                          )
                        : const Icon(Icons.check),
                    label: Text('Log Meal to Today ($_scaledCalories kcal)'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroTile(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}