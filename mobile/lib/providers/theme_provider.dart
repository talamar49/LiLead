import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'providers.dart';

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ThemeModeNotifier(storageService);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final dynamic _storageService;

  // Default to light theme (UI option temporarily disabled)
  ThemeModeNotifier(this._storageService) : super(ThemeMode.light) {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    // Temporarily force light theme - UI option disabled
    state = ThemeMode.light;
    
    // Original code kept for later re-enabling:
    // final savedMode = _storageService.getThemeMode();
    // if (savedMode != null) {
    //   state = ThemeMode.values.firstWhere(
    //     (mode) => mode.name == savedMode,
    //     orElse: () => ThemeMode.light,
    //   );
    // }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _storageService.saveThemeMode(mode.name);
  }
}

// Locale provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return LocaleNotifier(storageService);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final dynamic _storageService;

  LocaleNotifier(this._storageService) : super(const Locale('he')) {
    _loadLocale();
  }

  void _loadLocale() {
    final savedLocale = _storageService.getLocale();
    if (savedLocale != null) {
      state = Locale(savedLocale);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _storageService.saveLocale(locale.languageCode);
  }
}
