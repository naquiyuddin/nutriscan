# NutriScan

A commercial-grade, AI-powered calorie tracker and fitness companion built with Flutter.

## ✨ Features

- **AI Food Scanner** — Snap a photo, get calories and macros parsed instantly via Google Gemini Vision
- **Personalized Plan** — Onboarding calculates BMR, TDEE, and macro targets using the Mifflin-St Jeor equation
- **Workout Library** — 20+ bodyweight exercises with combo splits, MET-based calorie burn scaled to your body, and step-by-step form guides
- **Healthy Recipes** — 20 recipes with macro filters, serving adjusters, and one-tap diary logging
- **Daily Dashboard** — Live calorie ring, water tracker, weight sparkline, and date-navigable logs
- **Local-First** — All data persists offline via `SharedPreferencesAsync`; no account required

## 🏗️ Architecture

- **State**: `LocalStorageService extends ChangeNotifier` (single source of truth)
- **Auth**: `AuthService extends ChangeNotifier` (local-first, swappable for Firebase)
- **Persistence**: JSON-encoded models in `SharedPreferencesAsync`
- **Theming**: Centralized `AppTheme.darkTheme` with Material 3
- **Charts**: `fl_chart` for radial calorie ring + weight sparkline

## 🚀 Setup

1. Clone this repo
2. Run `flutter pub get`
3. Create a `.env` file in the project root: