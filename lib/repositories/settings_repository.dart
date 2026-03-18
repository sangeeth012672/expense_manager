import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _keyBudgetLimit = 'budget_limit';

  Future<void> setBudgetLimit(double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBudgetLimit, limit);
  }

  Future<double> getBudgetLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyBudgetLimit) ?? 1000.0;
  }

  Future<void> clearAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBudgetLimit);
  }
}
