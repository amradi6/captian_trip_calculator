import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String _language = 'ar';
  String _currency = 'SAR';
  String _distanceUnit = 'km';
  bool _pushNotifications = true;
  bool _tripAlerts = true;

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  bool get isAr => _language == 'ar';
  String get currency => _currency;
  String get distanceUnit => _distanceUnit;
  bool get pushNotifications => _pushNotifications;
  bool get tripAlerts => _tripAlerts;
  bool get isDark => _themeMode == ThemeMode.dark;

  Locale get locale => Locale(_language);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString('language') ?? 'ar';
    _themeMode = prefs.getBool('darkMode') == true ? ThemeMode.dark : ThemeMode.light;
    _currency = prefs.getString('currency') ?? 'SAR';
    _distanceUnit = prefs.getString('distanceUnit') ?? 'km';
    _pushNotifications = prefs.getBool('pushNotifications') ?? true;
    _tripAlerts = prefs.getBool('tripAlerts') ?? true;
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  Future<void> setDarkMode(bool dark) async {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', dark);
    notifyListeners();
  }

  Future<void> setCurrency(String c) async {
    _currency = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', c);
    notifyListeners();
  }

  Future<void> setPushNotifications(bool v) async {
    _pushNotifications = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushNotifications', v);
    notifyListeners();
  }

  Future<void> setTripAlerts(bool v) async {
    _tripAlerts = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tripAlerts', v);
    notifyListeners();
  }
}
