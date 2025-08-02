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
  final ApiService _api; // A inicialização foi removida

  // O ApiService é solicitado no construtor
  SummariesNotifier(this._api) : super(SummariesState(
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
  // ATUALIZAR RESUMO
  Future<void> updateSummary(Summary updatedSummary) async {
    try {
      // Faz a chamada para a API para atualizar o resumo no backend
      final response = await _api.put(
        '${AppConstants.summariesEndpoint}/${updatedSummary.id}',
        data: updatedSummary.toJson(),
      );

      if (response.statusCode == 200) {
        // Se a API responder com sucesso, atualiza a lista local de resumos
        final updatedSummaries = state.summaries.map((s) {
          return s.id == updatedSummary.id ? updatedSummary : s;
        }).toList();

        state = state.copyWith(
          summaries: updatedSummaries,
          error: null,
        );
      } else {
        // Lança uma exceção se a API retornar um erro
        throw Exception('Erro ao atualizar resumo');
      }
    } catch (e) {
      // Repassa a exceção para que a UI possa exibi-la
      rethrow;
    }
  }


  Future<Summary> createSummary({
    required String query,
    String? subjectId,
    String? imageUrl,
  }) async {
    try {
      // ETAPA 1: Gerar o conteúdo com a IA.
      // Esta chamada já está correta graças à sua última correção.
      final generateResponse = await _api.post(
        '${AppConstants.summariesEndpoint}/generate',
        data: {
          'query': query,
          'subject_id': subjectId,
          'image_url': imageUrl,
        },
      );

      if (generateResponse.statusCode != 200) {
        throw Exception('Erro ao gerar o conteúdo com a IA');
      }

      final generatedData = generateResponse.data as Map<String, dynamic>;
      final String content = generatedData['content'];
      final List<String> citations = List<String>.from(generatedData['citations'] ?? []);

      // Tenta criar um título a partir da primeira linha do conteúdo.
      String title = content.split('\n').first.replaceAll('#', '').trim();
      if (title.isEmpty || title.length > 150) { // Título de fallback
        title = "Resumo sobre: ${query.substring(0, query.length > 50 ? 50 : query.length)}...";
      }

      // Condição de parada: se não houver matéria selecionada, não podemos salvar.
      if (subjectId == null) {
        throw Exception('Por favor, selecione uma matéria antes de salvar o resumo.');
      }

      // ETAPA 2: Criar o resumo no banco de dados com o conteúdo gerado.
      final createData = {
        'title': title,
        'content': content,
        'original_query': query,
        'subject_id': subjectId,
        'perplexity_citations': citations,
        'tags': [], // Você pode adicionar lógica de tags automáticas aqui
        'difficulty_level': 3, // Padrão
      };

      // Chama o endpoint de criação real.
      final createResponse = await _api.post(
        AppConstants.summariesEndpoint,
        data: createData,
      );

      if (createResponse.statusCode == 201) {
        final summaryData = createResponse.data['summary'] as Map<String, dynamic>;
        final newSummary = Summary.fromJson(summaryData);

        state = state.copyWith(
          summaries: [newSummary, ...state.summaries],
        );

        return newSummary;
      } else {
        throw Exception('Erro ao salvar o resumo no banco de dados');
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

// ADICIONE este novo método
  Future<void> loadSummariesByHierarchy(String subjectId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Chama o novo endpoint da API
      final response = await _api.get(
        '${AppConstants.subjectsEndpoint}/$subjectId/summaries',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final summariesData = data['summaries'] as List;
        final newSummaries = summariesData
            .map((json) => Summary.fromJson(json))
            .toList();

        state = state.copyWith(
          summaries: newSummaries,
          isLoading: false,
          hasMore: false, // Geralmente carregamos tudo de uma vez para esta visão
          currentPage: 1,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erro ao carregar resumos da matéria',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }



}

// Provider dos resumos
final summariesProvider = StateNotifierProvider<SummariesNotifier, SummariesState>((ref) {
  // Usa o provider para obter a instância do ApiService
  final apiService = ref.watch(apiServiceProvider);
  // Injeta a instância no Notifier
  return SummariesNotifier(apiService);
});

// Provider para resumos por matéria
final summariesBySubjectProvider = StateNotifierProvider.family<SummariesNotifier, SummariesState, String?>((ref, subjectId) {
  // Faz o mesmo para o provider de família
  final apiService = ref.watch(apiServiceProvider);
  final notifier = SummariesNotifier(apiService);
  notifier.loadSummaries(subjectId: subjectId);
  return notifier;
});

// Provider para resumos favoritos
final favoriteSummariesProvider = Provider<List<Summary>>((ref) {
  final summariesState = ref.watch(summariesProvider);
  return summariesState.summaries.where((s) => s.isFavorite).toList();
});

// Provider para carregar os resumos da hierarquia

final summariesBySubjectHierarchyProvider = StateNotifierProvider.family<SummariesNotifier, SummariesState, String>((ref, subjectId) {
  final apiService = ref.watch(apiServiceProvider);
  final notifier = SummariesNotifier(apiService);
  // Chama um novo método para carregar os dados da hierarquia
  notifier.loadSummariesByHierarchy(subjectId);
  return notifier;

});