// Caminho: lib/screens/reviews/review_session_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/reviews_provider.dart';
import 'package:study_app/screens/reviews/review_result_screen.dart';
import 'package:study_app/widgets/difficulty_selector.dart';
import 'package:study_app/widgets/progress_indicator.dart';

class ReviewSessionScreen extends ConsumerStatefulWidget {
  final dynamic specificReview; // Para revisar um resumo específico

  const ReviewSessionScreen({
    super.key,
    this.specificReview,
  });

  @override
  ConsumerState<ReviewSessionScreen> createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends ConsumerState<ReviewSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _cardAnimation;
  late Animation<double> _progressAnimation;

  List _reviewQueue = [];
  int _currentIndex = 0;
  bool _showContent = false;
  bool _isAnswering = false;
  List<Map<String, dynamic>> _sessionResults = [];
  DateTime? _sessionStartTime;

  @override
  void initState() {
    super.initState();

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOut,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOut,
    );

    _sessionStartTime = DateTime.now();
    _initializeSession();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _initializeSession() {
    if (widget.specificReview != null) {
      _reviewQueue = [widget.specificReview];
    } else {
      final reviewsState = ref.read(reviewsProvider);
      _reviewQueue = List.from(reviewsState.pendingReviews);
    }

    if (_reviewQueue.isNotEmpty) {
      _cardAnimationController.forward();
      _progressAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_reviewQueue.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Revisão'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'Nenhuma revisão disponível',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }

    final currentReview = _reviewQueue[_currentIndex];
    final progress = (_currentIndex + 1) / _reviewQueue.length;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text('Revisão ${_currentIndex + 1} de ${_reviewQueue.length}'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: _skipReview,
            ),
          ],
        ),
        body: Column(
          children: [
            // Barra de progresso
            AnimatedBuilder(
              animation: _progressAnimation,
              child: CustomLinearProgressIndicator( // <<< CORREÇÃO AQUI
                progress: progress,
                color: AppTheme.primaryColor,
              ),
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: child,
                );
              },
            ),

            const SizedBox(height: 16),

            // Card do resumo
            Expanded(
              child: AnimatedBuilder(
                animation: _cardAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _cardAnimation.value,
                    child: Opacity(
                      opacity: _cardAnimation.value,
                      child: _buildReviewCard(currentReview),
                    ),
                  );
                },
              ),
            ),

            // Botões de ação
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(review) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Cabeçalho do card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: review.summary.subject != null
                    ? Color(int.parse(
                  review.summary.subject.color.replaceFirst('#', '0xFF'),
                ))
                    : AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (review.summary.subject != null)
                    Text(
                      review.summary.subject.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    review.summary.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo do resumo
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_showContent) ...[
                      // Modo pergunta
                      const Icon(
                        Icons.quiz,
                        size: 48,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Você se lembra do conteúdo deste resumo?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tente relembrar o conteúdo antes de revelar a resposta.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      // Modo resposta
                      Expanded(
                        child: SingleChildScrollView(
                          child: MarkdownBody(
                            data: review.summary.content,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: AppTheme.textPrimary,
                              ),
                              h1: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              h2: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              strong: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_showContent) ...[
            // Botão para revelar conteúdo
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _revealContent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Revelar Resposta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else if (!_isAnswering) ...[
            // Botão para avaliar dificuldade
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _startAnswering,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Avaliar Dificuldade',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Seletor de dificuldade
            const Text(
              'Como foi a dificuldade desta revisão?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            DifficultySelector(
              selectedDifficulty: 3,
              showLabels: true,
              onDifficultySelected: _submitReview,
            ),
          ],
        ],
      ),
    );
  }

  void _revealContent() {
    setState(() {
      _showContent = true;
    });
  }

  void _startAnswering() {
    setState(() {
      _isAnswering = true;
    });
  }

  void _submitReview(int difficultyLevel) async {
    final currentReview = _reviewQueue[_currentIndex];

    _sessionResults.add({
      'review': currentReview,
      'difficulty': difficultyLevel,
      'timestamp': DateTime.now(),
    });

    await ref.read(reviewsProvider.notifier).submitReview(
      currentReview.id,
      difficultyLevel,
    );

    if (_currentIndex < _reviewQueue.length - 1) {
      _nextReview();
    } else {
      _finishSession();
    }
  }

  void _nextReview() {
    setState(() {
      _currentIndex++;
      _showContent = false;
      _isAnswering = false;
    });

    _cardAnimationController.reset();
    _cardAnimationController.forward();

    _progressAnimationController.reset();
    _progressAnimationController.forward();
  }

  void _skipReview() {
    if (_currentIndex < _reviewQueue.length - 1) {
      _nextReview();
    } else {
      _finishSession();
    }
  }

  void _finishSession() {
    final sessionDuration = DateTime.now().difference(_sessionStartTime!);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ReviewResultScreen(
          results: _sessionResults,
          sessionDuration: sessionDuration,
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return await _showExitDialog();
  }

  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da revisão?'),
        content: const Text(
          'Seu progresso nesta sessão será perdido. Deseja realmente sair?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}