import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/models/subject.dart';
import 'package:study_app/services/api_service.dart';

// 1. Classe de Estado (State) - Adicionado um novo campo para a lista original
class SubjectsState {
  final List<Subject> originalSubjects; // Lista original, nunca modificada pela busca/filtro
  final List<Subject> subjects; // Lista exibida, que pode ser filtrada/ordenada
  final bool isLoading;
  final String? error;

  SubjectsState({
    this.originalSubjects = const [],
    this.subjects = const [],
    this.isLoading = false,
    this.error,
  });

  SubjectsState copyWith({
    List<Subject>? originalSubjects,
    List<Subject>? subjects,
    bool? isLoading,
    String? error,
  }) {
    return SubjectsState(
      originalSubjects: originalSubjects ?? this.originalSubjects,
      subjects: subjects ?? this.subjects,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// 2. Classe Notificadora (Notifier)
class SubjectsNotifier extends StateNotifier<SubjectsState> {
  final ApiService _api;

  SubjectsNotifier(this._api) : super(SubjectsState());

  Future<void> loadSubjects() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.get('/subjects');
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final subjectsJsonList = responseData['subjects'] as List;
        final subjects = subjectsJsonList.map((json) => Subject.fromJson(json)).toList();

        // Salva tanto na lista original quanto na de exibição
        state = state.copyWith(
          originalSubjects: subjects,
          subjects: subjects,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: 'Erro ao carregar matérias');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createSubject(Map<String, dynamic> subjectData) async {
    try {
      final response = await _api.post('/subjects', data: subjectData);

      if (response.statusCode == 201) {
        final newSubjectData = response.data['subject'] as Map<String, dynamic>;
        final newSubject = Subject.fromJson(newSubjectData);

        // Adiciona à lista original e à de exibição
        final updatedList = [newSubject, ...state.originalSubjects];
        state = state.copyWith(
          originalSubjects: updatedList,
          subjects: updatedList,
        );
      } else {
        final errorMessage = response.data['error'] ?? 'Erro desconhecido ao criar matéria.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSubject(String subjectId, Map<String, dynamic> subjectData) async {
    // ... (implementação de update)
  }

  Future<void> deleteSubject(String subjectId) async {
    // ... (implementação de delete)
  }

  // --- INÍCIO DA CORREÇÃO ---

  // Lógica de busca implementada
  void searchSubjects(String query) {
    if (query.isEmpty) {
      // Se a busca estiver vazia, restaura a lista original
      state = state.copyWith(subjects: state.originalSubjects);
      return;
    }

    final lowerCaseQuery = query.toLowerCase();
    final filteredList = state.originalSubjects.where((subject) {
      return subject.name.toLowerCase().contains(lowerCaseQuery) ||
          (subject.description.toLowerCase().contains(lowerCaseQuery));
    }).toList();

    state = state.copyWith(subjects: filteredList);
  }

  // Lógica de ordenação implementada
  void sortSubjects(String criteria) {
    final sortedList = List<Subject>.from(state.subjects);

    switch (criteria) {
      case 'name':
        sortedList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'date':
        sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Mais recentes primeiro
        break;
      case 'summaries':
        sortedList.sort((a, b) => b.summariesCount.compareTo(a.summariesCount)); // Mais resumos primeiro
        break;
    }

    state = state.copyWith(subjects: sortedList);
  }

  // --- FIM DA CORREÇÃO ---

  Future<void> refresh() async {
    await loadSubjects();
  }
}

// 3. Provider
final subjectsProvider = StateNotifierProvider<SubjectsNotifier, SubjectsState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final notifier = SubjectsNotifier(apiService);
  // Carrega as matérias quando o provider é inicializado pela primeira vez
  notifier.loadSubjects();
  return notifier;
});