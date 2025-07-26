import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/reviews_provider.dart';
import 'package:study_app/providers/statistics_provider.dart';
import 'package:study_app/screens/reviews/review_session_screen.dart';
import 'package:study_app/widgets/stat_card.dart';
import 'package:study_app/widgets/loading_widget.dart';
import 'package:study_app/widgets/empty_state_widget.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewsProvider.notifier).loadPendingReviews();
      ref.read(statisticsProvider.notifier).loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(reviewsProvider);
    final statisticsState = ref.watch(statisticsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Revisões'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Navegar para histórico de revisões
            },
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Configurações de revisão'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'statistics',
                child: Row(
                  children: [
                    Icon(Icons.analytics, size: 20),
                    SizedBox(width: 8),
                    Text('Estatísticas detalhadas'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // A criação do provider no passo 1 deve resolver a inferência de tipo.
          // Se o erro persistir, você pode ser explícito:
          final List<Future<void>> refreshFutures = [
            ref.read(reviewsProvider.notifier).loadPendingReviews(),
            ref.read(statisticsProvider.notifier).loadStatistics(),
          ];
          await Future.wait(refreshFutures);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estatísticas de revisão
              _buildStatisticsSection(statisticsState),
              
              const SizedBox(height: 24),
              
              // Progresso diário
              _buildDailyProgress(statisticsState),
              
              const SizedBox(height: 24),
              
              // Botão de iniciar revisão
              _buildStartReviewButton(reviewsState),
              
              const SizedBox(height: 24),
              
              // Lista de revisões pendentes
              _buildPendingReviewsList(reviewsState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(StatisticsState statisticsState) {
    if (statisticsState.isLoading) {
      return const SizedBox(
        height: 120,
        child: LoadingWidget(),
      );
    }

    final stats = statisticsState.statistics;
    if (stats == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estatísticas de Hoje',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Revisões Feitas',
                value: stats.todayStats.summariesReviewed.toString(),
                icon: Icons.quiz,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Pendentes',
                value: stats.pendingReviews.toString(),
                icon: Icons.pending,
                color: AppTheme.warningColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Sequência',
                value: stats.streakDays.toString(),
                subtitle: 'dias consecutivos',
                icon: Icons.local_fire_department,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Tempo de Estudo',
                value: '${stats.todayStats.studyTimeMinutes}min',
                icon: Icons.access_time,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyProgress(StatisticsState statisticsState) {
    final stats = statisticsState.statistics;
    if (stats == null) return const SizedBox.shrink();

    const dailyGoal = 15; // Meta diária de revisões
    final progress = (stats.todayStats.summariesReviewed / dailyGoal).clamp(0.0, 1.0);
    final isGoalReached = stats.todayStats.summariesReviewed >= dailyGoal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGoalReached
              ? [AppTheme.successColor, AppTheme.successColor.withOpacity(0.8)]
              : [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGoalReached ? Icons.celebration : Icons.flag_outlined,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isGoalReached 
                      ? 'Meta diária atingida! 🎉'
                      : 'Progresso da Meta Diária',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Barra de progresso
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            '${stats.todayStats.summariesReviewed} de $dailyGoal revisões',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartReviewButton(ReviewsState reviewsState) {
    final hasPendingReviews = reviewsState.pendingReviews.isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: hasPendingReviews ? _startReviewSession : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        icon: Icon(
          hasPendingReviews ? Icons.play_arrow : Icons.check_circle,
          size: 24,
        ),
        label: Text(
          hasPendingReviews 
              ? 'Iniciar Sessão de Revisão (${reviewsState.pendingReviews.length})'
              : 'Todas as revisões em dia!',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPendingReviewsList(ReviewsState reviewsState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Revisões Pendentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            if (reviewsState.pendingReviews.isNotEmpty)
              TextButton(
                onPressed: () {
                  // TODO: Mostrar todas as revisões pendentes
                },
                child: const Text('Ver todas'),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        if (reviewsState.isLoading)
          const LoadingWidget()
        else if (reviewsState.pendingReviews.isEmpty)
          const CustomEmptyStateWidget(
            icon: Icons.check_circle_outline,
            title: 'Nenhuma revisão pendente',
            subtitle: 'Parabéns! Você está em dia com seus estudos.',
          )
        else
          _buildReviewsList(reviewsState.pendingReviews),
      ],
    );
  }

  Widget _buildReviewsList(List pendingReviews) {
    final displayReviews = pendingReviews.take(5).toList();
    
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayReviews.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final review = displayReviews[index];
            return _buildReviewCard(review);
          },
        ),
        
        if (pendingReviews.length > 5) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // TODO: Mostrar todas as revisões
            },
            child: Text('Ver mais ${pendingReviews.length - 5} revisões'),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewCard(review) {
    final isOverdue = review.scheduledDate.isBefore(DateTime.now());
    final urgencyColor = isOverdue ? AppTheme.errorColor : AppTheme.warningColor;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _startSingleReview(review),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      review.summary.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: urgencyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOverdue ? 'Atrasada' : 'Pendente',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: urgencyColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              if (review.summary.subject != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(int.parse(
                      review.summary.subject.color.replaceFirst('#', '0xFF'),
                    )).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    review.summary.subject.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(int.parse(
                        review.summary.subject.color.replaceFirst('#', '0xFF'),
                      )),
                    ),
                  ),
                ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Agendada para ${_formatDate(review.scheduledDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Revisão ${review.reviewNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
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

  void _startReviewSession() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReviewSessionScreen(),
      ),
    );
  }

  void _startSingleReview(review) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewSessionScreen(
          specificReview: review,
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings':
        // TODO: Navegar para configurações de revisão
        break;
      case 'statistics':
        // TODO: Navegar para estatísticas detalhadas
        break;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'hoje às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == -1) {
      return 'amanhã';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} dias atrás';
    } else {
      return 'em ${-difference.inDays} dias';
    }
  }
}

