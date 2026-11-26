import 'package:flutter/material.dart';
import 'local_storage_service.dart';

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  bool get isLoggedIn => LocalStorageService.instance.isLoggedIn;
  UserProfile? get currentUser => LocalStorageService.instance.userProfile;
  String? get userName => LocalStorageService.instance.userName;

  Future<bool> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty ||
        !trimmedEmail.contains('@') ||
        password.length < 6) {
      return false;
    }
    await LocalStorageService.instance.signUpOrLogin(
      name: trimmedEmail.split('@').first,
      email: trimmedEmail,
    );
    notifyListeners();
    return true;
  }

  Future<bool> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 400));
    await LocalStorageService.instance.signUpOrLogin(
      name: 'Google User',
      email: 'google@local',
    );
    notifyListeners();
    return true;
  }

  Future<void> continueAsGuest() async {
    await LocalStorageService.instance.signUpOrLogin(
      name: 'Fitness Member',
      email: 'guest@local',
      guest: true,
    );
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await LocalStorageService.instance.saveProfile(profile);
    notifyListeners();
  }

  Future<void> logOut({bool clearData = false}) async {
    await LocalStorageService.instance.logOut(clearData: clearData);
    notifyListeners();
  }
}