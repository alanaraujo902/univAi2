// Caminho: lib/screens/subjects/subject_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/summaries_provider.dart';
import 'package:study_app/screens/summaries/create_summary_screen.dart';
import 'package:study_app/screens/summaries/summary_detail_screen.dart';
import 'package:study_app/screens/subjects/create_subject_screen.dart';
import 'package:study_app/widgets/loading_widget.dart';
import 'package:study_app/widgets/empty_state_widget.dart';

class SubjectDetailScreen extends ConsumerStatefulWidget {
  final dynamic subject;

  const SubjectDetailScreen({
    super.key,
    required this.subject,
  });

  @override
  ConsumerState<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(summariesBySubjectProvider(widget.subject.id).notifier)
          .loadSummaries(subjectId: widget.subject.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Color(int.parse(widget.subject.color.replaceFirst('#', '0xFF'))),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.subject.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(int.parse(widget.subject.color.replaceFirst('#', '0xFF'))),
                      Color(int.parse(widget.subject.color.replaceFirst('#', '0xFF'))).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _getIconData(widget.subject.icon),
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (widget.subject.description != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            widget.subject.description!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Editar matéria'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'add_child',
                    child: Row(
                      children: [
                        Icon(Icons.create_new_folder, size: 20),
                        SizedBox(width: 8),
                        Text('Adicionar submatéria'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'statistics',
                    child: Row(
                      children: [
                        Icon(Icons.analytics, size: 20),
                        SizedBox(width: 8),
                        Text('Estatísticas'),
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
          SliverToBoxAdapter(
            child: _buildStatisticsSection(),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primaryColor,
                tabs: const [
                  Tab(text: 'Resumos'),
                  Tab(text: 'Submatérias'),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummariesTab(),
                _buildSubjectsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateSummaryScreen(
                preSelectedSubjectId: widget.subject.id, // Esta linha agora é válida
              ),
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

  Widget _buildStatisticsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Resumos',
              widget.subject.summariesCount.toString(),
              Icons.description,
              AppTheme.primaryColor,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(
              'Submatérias',
              (widget.subject.children?.length ?? 0).toString(),
              Icons.folder,
              AppTheme.successColor,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(
              'Revisões',

              //widget.subject.pendingReviews.toString(),
              "0",
              Icons.quiz,
              AppTheme.warningColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummariesTab() {
    final summariesState = ref.watch(summariesBySubjectProvider(widget.subject.id));

    if (summariesState.isLoading) {
      return const LoadingWidget();
    }

    if (summariesState.summaries.isEmpty) {
      return CustomEmptyStateWidget(
        icon: Icons.description_outlined,
        title: 'Nenhum resumo encontrado',
        subtitle: 'Crie seu primeiro resumo para esta matéria',
        actionText: 'Criar Resumo',
        onActionPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateSummaryScreen(
                preSelectedSubjectId: widget.subject.id, // Esta linha agora é válida
              ),
            ),
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(summariesBySubjectProvider(widget.subject.id).notifier)
            .refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: summariesState.summaries.length,
        itemBuilder: (context, index) {
          final summary = summariesState.summaries[index];
          return _buildSummaryCard(summary);
        },
      ),
    );
  }

  Widget _buildSubjectsTab() {
    return const CustomEmptyStateWidget(
      icon: Icons.folder_outlined,
      title: 'Nenhuma submatéria encontrada',
      subtitle: 'Adicione submatérias para organizar melhor seus estudos',
      actionText: 'Adicionar Submatéria',
    );
  }

  Widget _buildSummaryCard(summary) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SummaryDetailScreen(summary: summary),
            ),
          );
        },
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
                      summary.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (summary.isFavorite)
                    const Icon(
                      Icons.favorite,
                      size: 16,
                      color: AppTheme.errorColor,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                summary.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(summary.difficultyLevel).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      summary.difficultyText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getDifficultyColor(summary.difficultyLevel),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(summary.createdAt),
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

  IconData _getIconData(String? iconName) {
    // Adicionado tratamento para iconName nulo
    switch (iconName) {
      case 'science':
        return Icons.science;
      case 'calculate':
        return Icons.calculate;
      case 'history':
        return Icons.history;
      case 'language':
        return Icons.language;
      case 'psychology':
        return Icons.psychology;
      case 'biotech':
        return Icons.biotech;
      case 'computer':
        return Icons.computer;
      case 'book':
        return Icons.book;
      default:
        return Icons.folder;
    }
  }

  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1:
      case 2:
        return AppTheme.successColor;
      case 3:
        return AppTheme.warningColor;
      case 4:
      case 5:
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateSubjectScreen(subject: widget.subject),
          ),
        );
        break;
      case 'add_child':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateSubjectScreen(parentSubject: widget.subject),
          ),
        );
        break;
      case 'statistics':
        break;
      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir matéria'),
        content: Text(
          'Tem certeza que deseja excluir "${widget.subject.name}"? '
              'Todos os resumos e submatérias associados também serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}