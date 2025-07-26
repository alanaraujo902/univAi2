import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/models/review.dart'; // Certifique-se que o caminho do modelo está correto
import 'package:study_app/services/api_service.dart';

// 1. Classe de Estado
class ReviewsState {
  final List<dynamic> pendingReviews; // Troque 'dynamic' pelo seu modelo de revisão se tiver um específico
  final bool isLoading;
  final String? error;

  ReviewsState({
    this.pendingReviews = const [],
    this.isLoading = false,
    this.error,
  });

  ReviewsState copyWith({
    List<dynamic>? pendingReviews,
    bool? isLoading,
    String? error,
  }) {
    return ReviewsState(
      pendingReviews: pendingReviews ?? this.pendingReviews,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// 2. Classe Notificadora (Notifier)
class ReviewsNotifier extends StateNotifier<ReviewsState> {
  final ApiService _api = ApiService();

  ReviewsNotifier() : super(ReviewsState());

  Future<void> loadPendingReviews() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Substitua pelo seu endpoint real
      final response = await _api.get('/reviews/pending');
      if (response.statusCode == 200) {
        final data = response.data['pending_reviews'] as List;
        // Se você tiver um modelo Review.fromJson, use-o aqui
        state = state.copyWith(pendingReviews: data, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Erro ao carregar revisões');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitReview(String reviewId, int difficulty) async {
    // Lógica para enviar o resultado de uma revisão para a API
  }
}

// 3. Provider
final reviewsProvider = StateNotifierProvider<ReviewsNotifier, ReviewsState>((ref) {
  return ReviewsNotifier();
});
