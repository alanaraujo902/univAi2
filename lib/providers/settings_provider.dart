import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/services/storage_service.dart'; // Supondo que você use um serviço para persistir as configurações

// Estado das configurações
class SettingsState {
  final bool isDarkMode;
  final double fontSize;
  final String language;
  final bool notificationsEnabled;
  final bool reviewNotificationsEnabled;
  final TimeOfDay notificationTime;
  final int dailyGoal;
  final String reviewAlgorithm;
  final bool shuffleReviews;
  final bool showProgress;

  SettingsState({
    this.isDarkMode = false,
    this.fontSize = 16.0,
    this.language = 'pt',
    this.notificationsEnabled = true,
    this.reviewNotificationsEnabled = true,
    this.notificationTime = const TimeOfDay(hour: 20, minute: 0),
    this.dailyGoal = 15,
    this.reviewAlgorithm = 'sm2',
    this.shuffleReviews = false,
    this.showProgress = true,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    double? fontSize,
    String? language,
    bool? notificationsEnabled,
    bool? reviewNotificationsEnabled,
    TimeOfDay? notificationTime,
    int? dailyGoal,
    String? reviewAlgorithm,
    bool? shuffleReviews,
    bool? showProgress,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontSize: fontSize ?? this.fontSize,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reviewNotificationsEnabled: reviewNotificationsEnabled ?? this.reviewNotificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      reviewAlgorithm: reviewAlgorithm ?? this.reviewAlgorithm,
      shuffleReviews: shuffleReviews ?? this.shuffleReviews,
      showProgress: showProgress ?? this.showProgress,
    );
  }
}

// Notifier das configurações
class SettingsNotifier extends StateNotifier<SettingsState> {
  final StorageService _storageService = StorageService();

  SettingsNotifier() : super(SettingsState());

  Future<void> loadSettings() async {
    // Carregar configurações salvas do storage
    final themeMode = await _storageService.getThemeMode();
    // Carregar outras configurações...
    state = state.copyWith(isDarkMode: themeMode == 'dark');
  }

  void setDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
    _storageService.setThemeMode(value ? 'dark' : 'light');
  }

  void setFontSize(double value) {
    state = state.copyWith(fontSize: value);
    // Salvar no storage...
  }

  void setLanguage(String value) {
    state = state.copyWith(language: value);
    // Salvar no storage...
  }

  void setNotificationsEnabled(bool value) {
    state = state.copyWith(notificationsEnabled: value);
    // Salvar no storage...
  }

  void setReviewNotificationsEnabled(bool value) {
    state = state.copyWith(reviewNotificationsEnabled: value);
    // Salvar no storage...
  }

  void setNotificationTime(TimeOfDay value) {
    state = state.copyWith(notificationTime: value);
    // Salvar no storage...
  }

  void setDailyGoal(int value) {
    state = state.copyWith(dailyGoal: value);
    // Salvar no storage...
  }

  void setReviewAlgorithm(String value) {
    state = state.copyWith(reviewAlgorithm: value);
    // Salvar no storage...
  }

  void setShuffleReviews(bool value) {
    state = state.copyWith(shuffleReviews: value);
    // Salvar no storage...
  }

  void setShowProgress(bool value) {
    state = state.copyWith(showProgress: value);
    // Salvar no storage...
  }
}

// Provider das configurações
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});