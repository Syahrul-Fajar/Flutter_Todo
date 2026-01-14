import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  String _userName = 'Farsy';
  bool _isDarkMode = false;
  String? _alarmSoundPath;

  String get userName => _userName;
  bool get isDarkMode => _isDarkMode;
  String? get alarmSoundPath => _alarmSoundPath;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? 'Farsy';
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _alarmSoundPath = prefs.getString('alarmSoundPath');
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  Future<void> setAlarmSound(String path) async {
    _alarmSoundPath = path;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alarmSoundPath', path);
  }
}
