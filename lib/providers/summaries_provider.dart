import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_constants.dart';
import 'package:study_app/models/summary.dart';
import 'package:study_app/services/api_service.dart';

// Estado dos resumos
class SummariesState {
  final List<Summary> summaries;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  SummariesState({
    required this.summaries,
    required this.isLoading,
    this.error,
    required this.hasMore,
    required this.currentPage,
  });

  SummariesState copyWith({
    List<Summary>? summaries,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return SummariesState(
      summaries: summaries ?? this.summaries,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Notifier dos resumos
class SummariesNotifier extends StateNotifier<SummariesState> {
  final ApiService _api = ApiService();

  SummariesNotifier() : super(SummariesState(
    summaries: [],
    isLoading: false,
    hasMore: true,
    currentPage: 1,
  ));

  // Carregar resumos
  Future<void> loadSummaries({
    int? page,
    int? limit,
    String? subjectId,
    bool refresh = false,
  }) async {
    if (state.isLoading) return;

    final targetPage = page ?? (refresh ? 1 : state.currentPage);
    
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final queryParams = <String, dynamic>{
        'page': targetPage,
        'limit': limit ?? AppConstants.defaultPageSize,
      };
      
      if (subjectId != null) {
        queryParams['subject_id'] = subjectId;
      }

      final response = await _api.get(
        AppConstants.summariesEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final summariesData = data['summaries'] as List;
        final newSummaries = summariesData
            .map((json) => Summary.fromJson(json))
            .toList();

        List<Summary> allSummaries;
        if (refresh || targetPage == 1) {
          allSummaries = newSummaries;
        } else {
          allSummaries = [...state.summaries, ...newSummaries];
        }

        state = state.copyWith(
          summaries: allSummaries,
          isLoading: false,
          hasMore: newSummaries.length >= (limit ?? AppConstants.defaultPageSize),
          currentPage: targetPage,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erro ao carregar resumos',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Criar resumo
  Future<Summary> createSummary({
    required String query,
    String? subjectId,
    String? imageUrl,
  }) async {
    try {
      final data = <String, dynamic>{
        'query': query,
      };
      
      if (subjectId != null) {
        data['subject_id'] = subjectId;
      }
      
      if (imageUrl != null) {
        data['image_url'] = imageUrl;
      }

      // CORREÇÃO: Adicionamos '/generate' para chamar a rota correta da IA
      final response = await _api.post(
        '${AppConstants.summariesEndpoint}/generate',
        data: data,
      );

      if (response.statusCode == 201) {
        final summaryData = response.data['summary'] as Map<String, dynamic>;
        final newSummary = Summary.fromJson(summaryData);
        
        // Adicionar o novo resumo no início da lista
        state = state.copyWith(
          summaries: [newSummary, ...state.summaries],
        );
        
        return newSummary;
      } else {
        throw Exception('Erro ao criar resumo');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar resumo
  Future<void> updateSummary(Summary summary) async {
    try {
      final response = await _api.put(
        '${AppConstants.summariesEndpoint}/${summary.id}',
        data: summary.toJson(),
      );

      if (response.statusCode == 200) {
        final updatedSummaryData = response.data['summary'] as Map<String, dynamic>;
        final updatedSummary = Summary.fromJson(updatedSummaryData);
        
        final updatedSummaries = state.summaries.map((s) {
          return s.id == summary.id ? updatedSummary : s;
        }).toList();
        
        state = state.copyWith(summaries: updatedSummaries);
      } else {
        throw Exception('Erro ao atualizar resumo');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Deletar resumo
  Future<void> deleteSummary(String summaryId) async {
    try {
      final response = await _api.delete(
        '${AppConstants.summariesEndpoint}/$summaryId',
      );

      if (response.statusCode == 200) {
        final updatedSummaries = state.summaries
            .where((s) => s.id != summaryId)
            .toList();
        
        state = state.copyWith(summaries: updatedSummaries);
      } else {
        throw Exception('Erro ao deletar resumo');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Favoritar/desfavoritar resumo
  Future<void> toggleFavorite(String summaryId) async {
    try {
      final response = await _api.post(
        '${AppConstants.summariesEndpoint}/$summaryId/favorite',
      );

      if (response.statusCode == 200) {
        final updatedSummaries = state.summaries.map((s) {
          if (s.id == summaryId) {
            return s.copyWith(isFavorite: !s.isFavorite);
          }
          return s;
        }).toList();
        
        state = state.copyWith(summaries: updatedSummaries);
      } else {
        throw Exception('Erro ao favoritar resumo');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Buscar resumos
  Future<void> searchSummaries(String query) async {
    if (query.isEmpty) {
      await loadSummaries(refresh: true);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.get(
        '${AppConstants.summariesEndpoint}/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final summariesData = response.data['summaries'] as List;
        final summaries = summariesData
            .map((json) => Summary.fromJson(json))
            .toList();

        state = state.copyWith(
          summaries: summaries,
          isLoading: false,
          hasMore: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erro ao buscar resumos',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Carregar mais resumos (paginação)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    
    await loadSummaries(page: state.currentPage + 1);
  }

  // Limpar erro
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh
  Future<void> refresh() async {
    await loadSummaries(refresh: true);
  }
}

// Provider dos resumos
final summariesProvider = StateNotifierProvider<SummariesNotifier, SummariesState>((ref) {
  return SummariesNotifier();
});

// Provider para resumos por matéria
final summariesBySubjectProvider = StateNotifierProvider.family<SummariesNotifier, SummariesState, String?>((ref, subjectId) {
  final notifier = SummariesNotifier();
  notifier.loadSummaries(subjectId: subjectId);
  return notifier;
});

// Provider para resumos favoritos
final favoriteSummariesProvider = Provider<List<Summary>>((ref) {
  final summariesState = ref.watch(summariesProvider);
  return summariesState.summaries.where((s) => s.isFavorite).toList();
});

