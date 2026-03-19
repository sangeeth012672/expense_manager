import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _keyBudgetLimit = 'budget_limit';
  static const String _keyReminderEnabled = 'daily_reminder_enabled';
  static const String _keyReminderTime = 'daily_reminder_time';
  static const String _keyCloudSyncEnabled = 'cloud_sync_enabled';

  Future<void> setBudgetLimit(double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBudgetLimit, limit);
  }

  Future<double> getBudgetLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyBudgetLimit) ?? 1000.0;
  }

  Future<void> setReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReminderEnabled, enabled);
  }

  Future<bool> getReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyReminderEnabled) ?? false;
  }

  Future<void> setReminderTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyReminderTime, time);
  }

  Future<String> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyReminderTime) ?? '09:00';
  }

  Future<void> setCloudSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCloudSyncEnabled, enabled);
  }

  Future<bool> getCloudSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCloudSyncEnabled) ?? true;
  }

  Future<void> clearAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBudgetLimit);
    await prefs.remove(_keyReminderEnabled);
    await prefs.remove(_keyReminderTime);
    await prefs.remove(_keyCloudSyncEnabled);
  }
}
