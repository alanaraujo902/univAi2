import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/decks_provider.dart';
import 'package:study_app/screens/decks/deck_detail_screen.dart';
import 'package:study_app/screens/decks/create_deck_screen.dart';
import 'package:study_app/widgets/search_bar.dart';
import 'package:study_app/widgets/empty_state_widget.dart';
import 'package:study_app/widgets/loading_widget.dart';

class DecksScreen extends ConsumerStatefulWidget {
  const DecksScreen({super.key});

  @override
  ConsumerState<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends ConsumerState<DecksScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(decksProvider.notifier).loadDecks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == query) {
        ref.read(decksProvider.notifier).searchDecks(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final decksState = ref.watch(decksProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Decks de Estudo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort_name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 20),
                    SizedBox(width: 8),
                    Text('Ordenar por nome'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sort_date',
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 20),
                    SizedBox(width: 8),
                    Text('Ordenar por data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sort_size',
                child: Row(
                  children: [
                    Icon(Icons.numbers, size: 20),
                    SizedBox(width: 8),
                    Text('Ordenar por tamanho'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Buscar decks...',
              onChanged: _onSearchChanged,
            ),
          ),

          // Lista de decks
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(decksProvider.notifier).refresh();
              },
              child: _buildDecksList(decksState),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateDeckScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo Deck'),
      ),
    );
  }

  Widget _buildDecksList(DecksState state) {
    if (state.isLoading && state.decks.isEmpty) {
      return const LoadingWidget();
    }

    if (state.decks.isEmpty) {
      return CustomEmptyStateWidget(
        icon: Icons.style_outlined,
        title: 'Nenhum deck encontrado',
        subtitle: 'Crie seu primeiro deck para organizar seus resumos em grupos de estudo',
        actionText: 'Criar Deck',
        onActionPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateDeckScreen(),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.decks.length,
      itemBuilder: (context, index) {
        final deck = state.decks[index];
        return _buildDeckCard(deck);
      },
    );
  }

  Widget _buildDeckCard(deck) {
    final progressPercentage = deck.summariesCount > 0 
        ? (deck.completedSummaries / deck.summariesCount * 100).round()
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToDeckDetail(deck),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do deck
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.style,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deck.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (deck.description != null && deck.description!.isNotEmpty)
                          Text(
                            deck.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleDeckAction(value, deck),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 20),
                            SizedBox(width: 8),
                            Text('Duplicar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                            SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: AppTheme.errorColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progresso do deck
              if (deck.summariesCount > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progresso',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '$progressPercentage%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressPercentage == 100 
                        ? AppTheme.successColor 
                        : AppTheme.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 16),
              ],

              // Estatísticas do deck
              Row(
                children: [
                  _buildStatChip(
                    Icons.description,
                    '${deck.summariesCount} resumos',
                    AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    Icons.schedule,
                    '${deck.pendingReviews} pendentes',
                    deck.pendingReviews > 0 ? AppTheme.warningColor : AppTheme.successColor,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Data de criação e última atividade
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Criado em ${_formatDate(deck.createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  if (deck.lastStudiedAt != null)
                    Text(
                      'Estudado ${_formatRelativeDate(deck.lastStudiedAt!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDeckDetail(deck) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeckDetailScreen(deck: deck),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'sort_name':
        ref.read(decksProvider.notifier).sortDecks('name');
        break;
      case 'sort_date':
        ref.read(decksProvider.notifier).sortDecks('date');
        break;
      case 'sort_size':
        ref.read(decksProvider.notifier).sortDecks('size');
        break;
    }
  }

  void _handleDeckAction(String action, deck) {
    switch (action) {
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateDeckScreen(deck: deck),
          ),
        );
        break;
      case 'duplicate':
        _duplicateDeck(deck);
        break;
      case 'delete':
        _showDeleteDialog(deck);
        break;
    }
  }

  void _duplicateDeck(deck) async {
    try {
      await ref.read(decksProvider.notifier).duplicateDeck(deck.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deck duplicado com sucesso!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao duplicar deck: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir deck'),
        content: Text(
          'Tem certeza que deseja excluir o deck "${deck.name}"? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(decksProvider.notifier).deleteDeck(deck.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'hoje';
    } else if (difference.inDays == 1) {
      return 'ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return 'em ${_formatDate(date)}';
    }
  }
}

