// Caminho: lib/providers/decks_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/models/summary.dart';
import 'package:study_app/services/api_service.dart';

// Supondo a existência de um modelo Deck. Se não houver, pode usar 'dynamic'.
// import 'package:study_app/models/deck.dart';

// --- Estado para a lista de Decks ---
class DecksState {
  final List<dynamic> decks; // Troque 'dynamic' pelo seu modelo Deck
  final bool isLoading;
  final String? error;

  DecksState({
    this.decks = const [],
    this.isLoading = false,
    this.error,
  });

  DecksState copyWith({List<dynamic>? decks, bool? isLoading, String? error}) {
    return DecksState(
      decks: decks ?? this.decks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// --- Notifier para a lista de Decks ---
class DecksNotifier extends StateNotifier<DecksState> {
  final ApiService _api = ApiService();

  DecksNotifier() : super(DecksState());

  Future<void> loadDecks() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulação de chamada de API
      await Future.delayed(const Duration(seconds: 1));
      // final response = await _api.get('/decks');
      // final decksData = response.data['decks'] as List;
      // final decks = decksData.map((d) => Deck.fromJson(d)).toList();
      state = state.copyWith(decks: [], isLoading: false); // Substitua [] pelos decks da API
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteDeck(String deckId) async {
    try {
      // await _api.delete('/decks/$deckId');
      state = state.copyWith(
          decks: state.decks.where((d) => d.id != deckId).toList()
      );
    } catch (e) {
      // Tratar erro
    }
  }

  Future<void> refresh() async {
    await loadDecks();
  }

  void searchDecks(String query) {
    print('Buscando decks com a query: $query');
    // Implemente a lógica de busca aqui
  }

  void sortDecks(String criteria) {
    print('Ordenando decks por: $criteria');
    final sortedList = List<dynamic>.from(state.decks);
    // if (criteria == 'name') {
    //   sortedList.sort((a, b) => a.name.compareTo(b.name));
    // }
    state = state.copyWith(decks: sortedList);
  }

  Future<void> duplicateDeck(String deckId) async {
    print('Duplicando deck com ID: $deckId');
    // Implemente a lógica para duplicar um deck aqui
    await refresh();
  }
}

// --- Provider para a lista de Decks ---
final decksProvider = StateNotifierProvider<DecksNotifier, DecksState>((ref) {
  return DecksNotifier();
});


// --- Estado para os detalhes de um Deck ---
class DeckDetailState {
  final dynamic deck;
  final List<Summary> summaries;
  final bool isLoading;
  final String? error;

  DeckDetailState({
    this.deck,
    this.summaries = const [],
    this.isLoading = false,
    this.error,
  });

  DeckDetailState copyWith({dynamic deck, List<Summary>? summaries, bool? isLoading, String? error}) {
    return DeckDetailState(
      deck: deck ?? this.deck,
      summaries: summaries ?? this.summaries,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// --- Notifier para os detalhes de um Deck ---
class DeckDetailNotifier extends StateNotifier<DeckDetailState> {
  final ApiService _api = ApiService();

  DeckDetailNotifier() : super(DeckDetailState());

  Future<void> loadDeckDetail(String deckId) async {
    // Lógica para buscar os detalhes de um deck e seus resumos
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Simulação de chamada de API
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(deck: null, summaries: [], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    if (state.deck != null) {
      await loadDeckDetail(state.deck.id);
    }
  }

  void shuffleDeck(String deckId) {
    print('Embaralhando deck: $deckId');
    final shuffledSummaries = List<Summary>.from(state.summaries)..shuffle();
    state = state.copyWith(summaries: shuffledSummaries);
  }
}

// --- Provider de família para os detalhes de um Deck ---
final deckDetailProvider = StateNotifierProvider.family<DeckDetailNotifier, DeckDetailState, String>((ref, deckId) {
  final notifier = DeckDetailNotifier();
  notifier.loadDeckDetail(deckId);
  return notifier;
});