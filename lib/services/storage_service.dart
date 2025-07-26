import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_app/constants/app_constants.dart';
import 'package:study_app/models/user.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;
  late Box _settingsBox;
  late Box _cacheBox;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _settingsBox = await Hive.openBox('settings');
    _cacheBox = await Hive.openBox('cache');
  }

  // Token de autenticação
  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(AppConstants.tokenKey);
  }

  // Dados do usuário
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs.setString(AppConstants.userKey, userJson);
  }

  Future<User?> getUser() async {
    final userJson = _prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    }
    return null;
  }

  Future<void> clearUser() async {
    await _prefs.remove(AppConstants.userKey);
  }

  // Configurações do app
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    for (final entry in settings.entries) {
      await _settingsBox.put(entry.key, entry.value);
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    final settings = <String, dynamic>{};
    for (final key in _settingsBox.keys) {
      settings[key] = _settingsBox.get(key);
    }
    
    // Aplicar configurações padrão se não existirem
    for (final entry in AppConstants.defaultSettings.entries) {
      if (!settings.containsKey(entry.key)) {
        settings[entry.key] = entry.value;
      }
    }
    
    return settings;
  }

  Future<T?> getSetting<T>(String key) async {
    return _settingsBox.get(key) as T?;
  }

  Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  Future<void> clearSettings() async {
    await _settingsBox.clear();
  }

  // Cache de dados
  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    final cacheEntry = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _cacheBox.put(key, cacheEntry);
  }

  Future<Map<String, dynamic>?> getCachedData(
    String key, {
    Duration? maxAge,
  }) async {
    final cacheEntry = _cacheBox.get(key) as Map<String, dynamic>?;
    
    if (cacheEntry == null) return null;
    
    if (maxAge != null) {
      final timestamp = cacheEntry['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      if (now.difference(cacheTime) > maxAge) {
        await _cacheBox.delete(key);
        return null;
      }
    }
    
    return cacheEntry['data'] as Map<String, dynamic>;
  }

  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  Future<void> clearCacheKey(String key) async {
    await _cacheBox.delete(key);
  }

  // Configurações específicas
  Future<bool> getNotificationsEnabled() async {
    return await getSetting<bool>('notifications_enabled') ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await setSetting('notifications_enabled', enabled);
  }

  Future<bool> getReviewRemindersEnabled() async {
    return await getSetting<bool>('review_reminders') ?? true;
  }

  Future<void> setReviewRemindersEnabled(bool enabled) async {
    await setSetting('review_reminders', enabled);
  }

  Future<int> getDailyGoal() async {
    return await getSetting<int>('daily_goal') ?? 15;
  }

  Future<void> setDailyGoal(int goal) async {
    await setSetting('daily_goal', goal);
  }

  Future<String> getThemeMode() async {
    return await getSetting<String>('theme_mode') ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await setSetting('theme_mode', mode);
  }

  Future<String> getLanguage() async {
    return await getSetting<String>('language') ?? 'pt_BR';
  }

  Future<void> setLanguage(String language) async {
    await setSetting('language', language);
  }

  // Estatísticas locais
  Future<void> saveLastReviewDate(DateTime date) async {
    await setSetting('last_review_date', date.toIso8601String());
  }

  Future<DateTime?> getLastReviewDate() async {
    final dateString = await getSetting<String>('last_review_date');
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  Future<void> incrementDailyReviews() async {
    final today = DateTime.now();
    final todayKey = 'reviews_${today.year}_${today.month}_${today.day}';
    final currentCount = await getSetting<int>(todayKey) ?? 0;
    await setSetting(todayKey, currentCount + 1);
  }

  Future<int> getDailyReviewsCount([DateTime? date]) async {
    final targetDate = date ?? DateTime.now();
    final dateKey = 'reviews_${targetDate.year}_${targetDate.month}_${targetDate.day}';
    return await getSetting<int>(dateKey) ?? 0;
  }

  // Limpeza geral
  Future<void> clearAllData() async {
    await clearToken();
    await clearUser();
    await clearSettings();
    await clearCache();
  }
}

