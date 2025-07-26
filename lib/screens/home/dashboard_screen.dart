import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/auth_provider.dart';
import 'package:study_app/providers/statistics_provider.dart';
import 'package:study_app/screens/summaries/create_summary_screen.dart';
import 'package:study_app/widgets/stat_card.dart';
import 'package:study_app/widgets/quick_action_card.dart';
import 'package:study_app/widgets/recent_summaries_list.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar estatísticas ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statisticsProvider.notifier).loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final statisticsState = ref.watch(statisticsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(statisticsProvider.notifier).loadStatistics();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com saudação
                _buildHeader(user?.fullName ?? 'Estudante'),
                
                const SizedBox(height: 24),
                
                // Cards de estatísticas
                if (statisticsState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (statisticsState.statistics != null)
                  _buildStatsGrid(statisticsState.statistics!)
                else
                  _buildEmptyStats(),
                
                const SizedBox(height: 24),
                
                // Ações rápidas
                _buildQuickActions(),
                
                const SizedBox(height: 24),
                
                // Resumos recentes
                const RecentSummariesList(),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateSummaryScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo Resumo'),
      ),
    );
  }

  Widget _buildHeader(String userName) {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Bom dia';
    } else if (hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $userName! 👋',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Vamos continuar seus estudos hoje?',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(statistics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        StatCard(
          title: 'Resumos Hoje',
          value: statistics.todayStats.summariesCreated.toString(),
          icon: Icons.description,
          color: AppTheme.primaryColor,
        ),
        StatCard(
          title: 'Revisões',
          value: statistics.pendingReviews.toString(),
          subtitle: 'pendentes',
          icon: Icons.quiz,
          color: AppTheme.warningColor,
        ),
        StatCard(
          title: 'Matérias',
          value: statistics.periodStats.subjectsCount.toString(),
          subtitle: 'organizadas',
          icon: Icons.folder,
          color: AppTheme.successColor,
        ),
        StatCard(
          title: 'Sequência',
          value: statistics.streakDays.toString(),
          subtitle: 'dias consecutivos',
          icon: Icons.local_fire_department,
          color: AppTheme.accentColor,
        ),
      ],
    );
  }

  Widget _buildEmptyStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        StatCard(
          title: 'Resumos Hoje',
          value: '0',
          icon: Icons.description,
          color: AppTheme.primaryColor,
        ),
        StatCard(
          title: 'Revisões',
          value: '0',
          subtitle: 'pendentes',
          icon: Icons.quiz,
          color: AppTheme.warningColor,
        ),
        StatCard(
          title: 'Matérias',
          value: '0',
          subtitle: 'organizadas',
          icon: Icons.folder,
          color: AppTheme.successColor,
        ),
        StatCard(
          title: 'Sequência',
          value: '0',
          subtitle: 'dias consecutivos',
          icon: Icons.local_fire_department,
          color: AppTheme.accentColor,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Rápidas',
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
              child: QuickActionCard(
                title: 'Criar Resumo',
                subtitle: 'Com IA',
                icon: Icons.auto_awesome,
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateSummaryScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: QuickActionCard(
                title: 'Revisar',
                subtitle: 'Agora',
                icon: Icons.quiz,
                color: AppTheme.warningColor,
                onTap: () {
                  // Navegar para revisão
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

