import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/statistics_provider.dart';
import 'package:study_app/widgets/stat_card.dart';

class ReviewResultScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> results;
  final Duration sessionDuration;

  const ReviewResultScreen({
    super.key,
    required this.results,
    required this.sessionDuration,
  });

  @override
  ConsumerState<ReviewResultScreen> createState() => _ReviewResultScreenState();
}

class _ReviewResultScreenState extends ConsumerState<ReviewResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _animationController.forward();
    
    // Atualizar estatísticas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statisticsProvider.notifier).loadStatistics();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionStats = _calculateSessionStats();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 32),
              
              // Cabeçalho com animação
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildHeader(sessionStats),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Estatísticas da sessão
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildSessionStats(sessionStats),
              ),
              
              const SizedBox(height: 24),
              
              // Distribuição de dificuldade
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildDifficultyDistribution(sessionStats),
              ),
              
              const SizedBox(height: 24),
              
              // Lista de revisões
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildReviewsList(),
              ),
              
              const SizedBox(height: 32),
              
              // Botões de ação
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildActionButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> stats) {
    final isExcellent = stats['averageDifficulty'] <= 2.0;
    final isGood = stats['averageDifficulty'] <= 3.0;
    
    Color headerColor;
    IconData headerIcon;
    String headerTitle;
    String headerSubtitle;
    
    if (isExcellent) {
      headerColor = AppTheme.successColor;
      headerIcon = Icons.celebration;
      headerTitle = 'Excelente!';
      headerSubtitle = 'Você domina bem o conteúdo';
    } else if (isGood) {
      headerColor = AppTheme.primaryColor;
      headerIcon = Icons.thumb_up;
      headerTitle = 'Muito bem!';
      headerSubtitle = 'Continue praticando';
    } else {
      headerColor = AppTheme.warningColor;
      headerIcon = Icons.trending_up;
      headerTitle = 'Continue estudando!';
      headerSubtitle = 'A prática leva à perfeição';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            headerColor,
            headerColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: headerColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            headerIcon,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            headerTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            headerSubtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Sessão concluída em ${_formatDuration(widget.sessionDuration)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStats(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estatísticas da Sessão',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Revisões',
                value: widget.results.length.toString(),
                icon: Icons.quiz,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Tempo Médio',
                value: '${stats['averageTime']}s',
                icon: Icons.timer,
                color: AppTheme.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Dificuldade Média',
                value: stats['averageDifficulty'].toStringAsFixed(1),
                icon: Icons.trending_up,
                color: _getDifficultyColor(stats['averageDifficulty']),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Pontuação',
                value: '${stats['score']}%',
                icon: Icons.star,
                color: AppTheme.warningColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyDistribution(Map<String, dynamic> stats) {
    final distribution = stats['difficultyDistribution'] as Map<int, int>;
    final total = widget.results.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribuição de Dificuldade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (index) {
            final level = index + 1;
            final count = distribution[level] ?? 0;
            final percentage = total > 0 ? (count / total) : 0.0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDifficultyBar(level, count, percentage),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDifficultyBar(int level, int count, double percentage) {
    final color = _getDifficultyColor(level.toDouble());
    final labels = ['Muito Fácil', 'Fácil', 'Médio', 'Difícil', 'Muito Difícil'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labels[level - 1],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              '$count (${(percentage * 100).toInt()}%)',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumos Revisados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.results.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final result = widget.results[index];
              return _buildReviewItem(result, index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> result, int number) {
    final review = result['review'];
    final difficulty = result['difficulty'] as int;
    final difficultyColor = _getDifficultyColor(difficulty.toDouble());
    final difficultyLabels = ['Muito Fácil', 'Fácil', 'Médio', 'Difícil', 'Muito Difícil'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.summary.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (review.summary.subject != null)
                  Text(
                    review.summary.subject.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: difficultyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              difficultyLabels[difficulty - 1],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: difficultyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.home),
            label: const Text(
              'Voltar ao Início',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Compartilhar resultados
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.share),
            label: const Text(
              'Compartilhar Resultados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _calculateSessionStats() {
    if (widget.results.isEmpty) {
      return {
        'averageDifficulty': 0.0,
        'averageTime': 0,
        'score': 0,
        'difficultyDistribution': <int, int>{},
      };
    }

    final difficulties = widget.results.map((r) => r['difficulty'] as int).toList();
    final averageDifficulty = difficulties.reduce((a, b) => a + b) / difficulties.length;
    
    // Calcular tempo médio por revisão
    final averageTime = widget.sessionDuration.inSeconds ~/ widget.results.length;
    
    // Calcular pontuação (quanto menor a dificuldade, maior a pontuação)
    final score = ((5 - averageDifficulty) / 4 * 100).round();
    
    // Distribuição de dificuldade
    final distribution = <int, int>{};
    for (final difficulty in difficulties) {
      distribution[difficulty] = (distribution[difficulty] ?? 0) + 1;
    }

    return {
      'averageDifficulty': averageDifficulty,
      'averageTime': averageTime,
      'score': score,
      'difficultyDistribution': distribution,
    };
  }

  Color _getDifficultyColor(double difficulty) {
    if (difficulty <= 2) {
      return AppTheme.successColor;
    } else if (difficulty <= 3) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.errorColor;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

