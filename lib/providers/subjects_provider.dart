import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/models/subject.dart';
import 'package:study_app/services/api_service.dart';

// 1. Classe de Estado (State)
class SubjectsState {
  final List<Subject> subjects;
  final bool isLoading;
  final String? error;

  SubjectsState({
    this.subjects = const [],
    this.isLoading = false,
    this.error,
  });

  SubjectsState copyWith({
    List<Subject>? subjects,
    bool? isLoading,
    String? error,
  }) {
    return SubjectsState(
      subjects: subjects ?? this.subjects,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// 2. Classe Notificadora (Notifier)
class SubjectsNotifier extends StateNotifier<SubjectsState> {
  final ApiService _api = ApiService();

  SubjectsNotifier() : super(SubjectsState());

  Future<void> loadSubjects() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Substitua '/subjects' pelo seu endpoint real
      final response = await _api.get('/subjects');
      if (response.statusCode == 200) {
        final data = response.data['subjects'] as List;
        final subjects = data.map((json) => Subject.fromJson(json)).toList();
        state = state.copyWith(subjects: subjects, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Erro ao carregar matérias');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createSubject(Map<String, dynamic> subjectData) async {
    // Lógica para criar uma nova matéria
  }

  Future<void> updateSubject(String subjectId, Map<String, dynamic> subjectData) async {
    // Lógica para atualizar uma matéria
  }

  Future<void> deleteSubject(String subjectId) async {
    // Lógica para deletar uma matéria
    state = state.copyWith(
        subjects: state.subjects.where((s) => s.id != subjectId).toList()
    );
  }

  void searchSubjects(String query) {
    // Lógica de busca (pode ser no cliente ou no servidor)
  }

  void sortSubjects(String criteria) {
    // Lógica de ordenação
  }

  Future<void> refresh() async {
    await loadSubjects();
  }
}

// 3. Provider
final subjectsProvider = StateNotifierProvider<SubjectsNotifier, SubjectsState>((ref) {
  return SubjectsNotifier();
});