// Caminho: lib/providers/statistics_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_constants.dart';
import 'package:study_app/models/statistics.dart';
import 'package:study_app/services/api_service.dart';

// Estado das estatísticas
class StatisticsState {
  final Statistics? statistics;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  StatisticsState({
    this.statistics,
    required this.isLoading,
    this.error,
    this.lastUpdated,
  });

  StatisticsState copyWith({
    Statistics? statistics,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return StatisticsState(
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Notifier das estatísticas
class StatisticsNotifier extends StateNotifier<StatisticsState> {
  final ApiService _api = ApiService();

  StatisticsNotifier() : super(StatisticsState(isLoading: false));

  // Carregar estatísticas
  Future<void> loadStatistics({String? period}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final queryParams = <String, dynamic>{};
      if (period != null) {
        queryParams['period'] = period;
      }

      final response = await _api.get(
        AppConstants.statisticsEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final statisticsData = response.data as Map<String, dynamic>;
        final statistics = Statistics.fromJson(statisticsData);

        state = state.copyWith(
          statistics: statistics,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erro ao carregar estatísticas',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // --- INÍCIO DA CORREÇÃO ---
  // Método adicionado para atender à chamada da tela de estatísticas
  Future<void> loadDetailedStatistics() async {
    // Por enquanto, este método pode simplesmente chamar o método principal.
    // No futuro, ele poderia buscar dados mais detalhados de outro endpoint.
    await loadStatistics();
  }
  // --- FIM DA CORREÇÃO ---

  // Carregar estatísticas por período
  Future<void> loadPeriodStatistics(String period) async {
    await loadStatistics(period: period);
  }

  // Atualizar estatística específica (para atualizações em tempo real)
  void updateTodayStats({
    int? summariesCreated,
    int? summariesReviewed,
    int? studyTimeMinutes,
  }) {
    if (state.statistics == null) return;

    final currentTodayStats = state.statistics!.todayStats;
    final updatedTodayStats = TodayStats(
      summariesCreated: summariesCreated ?? currentTodayStats.summariesCreated,
      summariesReviewed: summariesReviewed ?? currentTodayStats.summariesReviewed,
      studyTimeMinutes: studyTimeMinutes ?? currentTodayStats.studyTimeMinutes,
    );

    final updatedStatistics = Statistics(
      periodStats: state.statistics!.periodStats,
      todayStats: updatedTodayStats,
      streakDays: state.statistics!.streakDays,
      pendingReviews: state.statistics!.pendingReviews,
      subjectStats: state.statistics!.subjectStats,
      difficultyDistribution: state.statistics!.difficultyDistribution,
    );

    state = state.copyWith(statistics: updatedStatistics);
  }

  // Incrementar resumos criados hoje
  void incrementTodaySummaries() {
    if (state.statistics == null) return;

    updateTodayStats(
      summariesCreated: state.statistics!.todayStats.summariesCreated + 1,
    );
  }

  // Incrementar revisões feitas hoje
  void incrementTodayReviews() {
    if (state.statistics == null) return;

    updateTodayStats(
      summariesReviewed: state.statistics!.todayStats.summariesReviewed + 1,
    );
  }

  // Adicionar tempo de estudo
  void addStudyTime(int minutes) {
    if (state.statistics == null) return;

    updateTodayStats(
      studyTimeMinutes: state.statistics!.todayStats.studyTimeMinutes + minutes,
    );
  }

  // Atualizar revisões pendentes
  void updatePendingReviews(int count) {
    if (state.statistics == null) return;

    final updatedStatistics = Statistics(
      periodStats: state.statistics!.periodStats,
      todayStats: state.statistics!.todayStats,
      streakDays: state.statistics!.streakDays,
      pendingReviews: count,
      subjectStats: state.statistics!.subjectStats,
      difficultyDistribution: state.statistics!.difficultyDistribution,
    );

    state = state.copyWith(statistics: updatedStatistics);
  }

  // Limpar erro
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Verificar se precisa atualizar (cache de 5 minutos)
  bool get needsUpdate {
    if (state.lastUpdated == null) return true;

    final now = DateTime.now();
    final difference = now.difference(state.lastUpdated!);
    return difference.inMinutes >= 5;
  }

  // Refresh forçado
  Future<void> refresh() async {
    await loadStatistics();
  }
}

// Provider das estatísticas
final statisticsProvider = StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  return StatisticsNotifier();
});

// Provider para estatísticas por período
final periodStatisticsProvider = StateNotifierProvider.family<StatisticsNotifier, StatisticsState, String>((ref, period) {
  final notifier = StatisticsNotifier();
  notifier.loadPeriodStatistics(period);
  return notifier;
});

// Provider para verificar se atingiu meta diária
final dailyGoalProvider = Provider<bool>((ref) {
  final statisticsState = ref.watch(statisticsProvider);

  if (statisticsState.statistics == null) return false;

  // Assumindo meta padrão de 15 revisões por dia
  const dailyGoal = 15;
  return statisticsState.statistics!.todayStats.summariesReviewed >= dailyGoal;
});

// Provider para progresso da meta diária
final dailyProgressProvider = Provider<double>((ref) {
  final statisticsState = ref.watch(statisticsProvider);

  if (statisticsState.statistics == null) return 0.0;

  const dailyGoal = 15;
  final reviewed = statisticsState.statistics!.todayStats.summariesReviewed;
  return (reviewed / dailyGoal).clamp(0.0, 1.0);
});