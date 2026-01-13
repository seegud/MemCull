import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isVibrationDisabled = false; // 关闭震动功能，默认关闭（即默认会震动）
  bool _isSwipeReversed = false; // 上下操作反向，默认关闭
  bool _isTopBarCollapsible = false; // 顶栏折叠，默认关闭
  Locale? _locale; // 语言设置，null 表示跟随系统
  String _amapKey = ''; // 用户配置的高德 Web 服务 Key

  bool get isVibrationDisabled => _isVibrationDisabled;
  bool get isSwipeReversed => _isSwipeReversed;
  bool get isTopBarCollapsible => _isTopBarCollapsible;
  Locale? get locale => _locale;
  String get amapKey => _amapKey;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isVibrationDisabled = prefs.getBool('is_vibration_disabled') ?? false;
    _isSwipeReversed = prefs.getBool('is_swipe_reversed') ?? false;
    _isTopBarCollapsible = prefs.getBool('is_top_bar_collapsible') ?? false;
    _amapKey = prefs.getString('amap_key') ?? '';

    final localeCode = prefs.getString('locale_code');
    if (localeCode != null && localeCode != 'auto') {
      final parts = localeCode.split('_');
      if (parts.length > 1) {
        _locale = Locale(parts[0], parts[1]);
      } else {
        _locale = Locale(parts[0]);
      }
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.setString('locale_code', 'auto');
    } else {
      await prefs.setString('locale_code', locale.toString());
    }
    notifyListeners();
  }

  Future<void> setAmapKey(String key) async {
    _amapKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('amap_key', key);
    notifyListeners();
  }

  Future<void> setVibrationDisabled(bool value) async {
    _isVibrationDisabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_vibration_disabled', value);
    notifyListeners();
  }

  Future<void> setSwipeReversed(bool value) async {
    _isSwipeReversed = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_swipe_reversed', value);
    notifyListeners();
  }

  Future<void> setTopBarCollapsible(bool value) async {
    _isTopBarCollapsible = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_top_bar_collapsible', value);
    notifyListeners();
  }
}
