import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/subjects_provider.dart';
import 'package:study_app/screens/subjects/subject_detail_screen.dart';
import 'package:study_app/screens/subjects/create_subject_screen.dart';
import 'package:study_app/widgets/search_bar.dart';
import 'package:study_app/widgets/empty_state_widget.dart';
import 'package:study_app/widgets/loading_widget.dart';

class SubjectsScreen extends ConsumerStatefulWidget {
  const SubjectsScreen({super.key});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> {
  final _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subjectsProvider.notifier).loadSubjects();
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
        ref.read(subjectsProvider.notifier).searchSubjects(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjectsState = ref.watch(subjectsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Matérias'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
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
                value: 'sort_summaries',
                child: Row(
                  children: [
                    Icon(Icons.description, size: 20),
                    SizedBox(width: 8),
                    Text('Ordenar por resumos'),
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
              hintText: 'Buscar matérias...',
              onChanged: _onSearchChanged,
            ),
          ),

          // Lista/Grid de matérias
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(subjectsProvider.notifier).refresh();
              },
              child: _buildSubjectsList(subjectsState),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateSubjectScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSubjectsList(SubjectsState state) {
    if (state.isLoading && state.subjects.isEmpty) {
      return const LoadingWidget();
    }

    if (state.subjects.isEmpty) {
      return CustomEmptyStateWidget(
        icon: Icons.folder_outlined,
        title: 'Nenhuma matéria encontrada',
        subtitle: 'Crie sua primeira matéria para organizar seus estudos',
        actionText: 'Criar Matéria',
        onActionPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateSubjectScreen(),
            ),
          );
        },
      );
    }

    if (_isGridView) {
      return _buildGridView(state.subjects);
    } else {
      return _buildListView(state.subjects);
    }
  }

  Widget _buildListView(List subjects) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _buildSubjectListItem(subject);
      },
    );
  }

  Widget _buildGridView(List subjects) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _buildSubjectGridItem(subject);
      },
    );
  }

  Widget _buildSubjectListItem(subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToSubjectDetail(subject),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone da matéria
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(int.parse(subject.color.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(subject.icon),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Informações da matéria
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (subject.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subject.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // Estatísticas
                    Row(
                      children: [
                        Icon(
                          Icons.description,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${subject.summariesCount} resumos',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (subject.subjectsCount > 0) ...[
                          Icon(
                            Icons.folder,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${subject.subjectsCount} submatérias',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Menu de ações
              PopupMenuButton<String>(
                onSelected: (value) => _handleSubjectAction(value, subject),
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
        ),
      ),
    );
  }

  Widget _buildSubjectGridItem(subject) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToSubjectDetail(subject),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com ícone e menu
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(subject.color.replaceFirst('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getIconData(subject.icon),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleSubjectAction(value, subject),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Editar'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Excluir'),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Nome da matéria
              Text(
                subject.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Estatísticas
              Row(
                children: [
                  Text(
                    '${subject.summariesCount}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'resumos',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
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

  IconData _getIconData(String iconName) {
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

  void _navigateToSubjectDetail(subject) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubjectDetailScreen(subject: subject),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'sort_name':
        ref.read(subjectsProvider.notifier).sortSubjects('name');
        break;
      case 'sort_date':
        ref.read(subjectsProvider.notifier).sortSubjects('date');
        break;
      case 'sort_summaries':
        ref.read(subjectsProvider.notifier).sortSubjects('summaries');
        break;
    }
  }

  void _handleSubjectAction(String action, subject) {
    switch (action) {
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateSubjectScreen(subject: subject),
          ),
        );
        break;
      case 'add_child':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateSubjectScreen(parentSubject: subject),
          ),
        );
        break;
      case 'delete':
        _showDeleteDialog(subject);
        break;
    }
  }

  void _showDeleteDialog(subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir matéria'),
        content: Text(
          'Tem certeza que deseja excluir "${subject.name}"? '
          'Todos os resumos associados também serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(subjectsProvider.notifier).deleteSubject(subject.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

