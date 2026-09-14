import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final String currency;
  final bool notificationsEnabled;
  final double monthlyLimit; // 0 = sem limite geral definido

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.currency = 'MZN',
    this.notificationsEnabled = true,
    this.monthlyLimit = 0,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? currency,
    bool? notificationsEnabled,
    double? monthlyLimit,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    final currency = prefs.getString('currency') ?? 'MZN';
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    final monthlyLimit = prefs.getDouble('monthlyLimit') ?? 0;

    state = AppSettings(
      themeMode: ThemeMode.values[themeModeIndex],
      currency: currency,
      notificationsEnabled: notificationsEnabled,
      monthlyLimit: monthlyLimit,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    state = state.copyWith(currency: currency);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> setMonthlyLimit(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthlyLimit', value);
    state = state.copyWith(monthlyLimit: value);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});