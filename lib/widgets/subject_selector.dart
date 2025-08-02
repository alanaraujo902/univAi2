import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/models/subject.dart';
import 'package:study_app/providers/subjects_provider.dart';
import 'package:study_app/widgets/loading_widget.dart';

class SubjectSelector extends ConsumerStatefulWidget {
  final String? selectedSubjectId;
  final Function(String?) onSubjectSelected;
  final String? label;
  final String? hint;
  final bool allowNull;

  const SubjectSelector({
    super.key,
    this.selectedSubjectId,
    required this.onSubjectSelected,
    this.label,
    this.hint,
    this.allowNull = true,
  });

  @override
  ConsumerState<SubjectSelector> createState() => _SubjectSelectorState();
}

class _SubjectSelectorState extends ConsumerState<SubjectSelector> {
  @override
  void initState() {
    super.initState();
    // Garante que a lista de matérias seja carregada quando o widget for construído
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subjectsProvider.notifier).loadSubjects();
    });
  }

  /// Mostra um modal com a lista hierárquica de matérias para seleção.
  void _showSubjectPicker(BuildContext context, List<Subject> subjects) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          // Filtra apenas as matérias raiz (que não têm pai) para iniciar a árvore
          final rootSubjects = subjects.where((s) => s.parentId == null).toList();

          return Column(
            children: [
              // "Handle" para o usuário arrastar o modal
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Cabeçalho do modal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Selecionar Matéria',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(height: 1),
              // Lista hierárquica e rolável
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Adiciona a opção de "Nenhuma matéria" se permitido
                    if (widget.allowNull)
                      ListTile(
                        leading: const Icon(Icons.clear, color: AppTheme.textSecondary),
                        title: const Text('Nenhuma matéria'),
                        onTap: () {
                          widget.onSubjectSelected(null);
                          Navigator.pop(context);
                        },
                      ),
                    // Constrói a árvore de matérias a partir das raízes
                    ...rootSubjects.map((subject) => _buildSubjectTreeItem(subject, subjects, 0)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Método recursivo que constrói um item da árvore de seleção.
  /// Renderiza um `ListTile` para matérias sem filhos e um `ExpansionTile` para as que têm.
  Widget _buildSubjectTreeItem(Subject subject, List<Subject> allSubjects, int depth) {
    final children = allSubjects.where((s) => s.parentId == subject.id).toList();
    final isSelected = subject.id == widget.selectedSubjectId;

    // Se não tem filhos, é um item simples e clicável.
    if (children.isEmpty) {
      return ListTile(
        contentPadding: EdgeInsets.only(left: 16.0 + (depth * 20.0), right: 16.0),
        leading: Icon(_getIconData(subject.icon), color: Color(int.parse(subject.color.replaceFirst('#', '0xFF')))),
        title: Text(subject.name),
        trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
        onTap: () {
          widget.onSubjectSelected(subject.id);
          Navigator.pop(context);
        },
      );
    }

    // Se tem filhos, é um item expansível.
    return ExpansionTile(
      key: PageStorageKey<String>(subject.id), // Mantém o estado (aberto/fechado)
      tilePadding: EdgeInsets.only(left: 16.0 + (depth * 20.0), right: 16.0),
      leading: Icon(_getIconData(subject.icon), color: Color(int.parse(subject.color.replaceFirst('#', '0xFF')))),
      title: Text(subject.name),
      children: [
        // Adiciona uma opção para selecionar a própria matéria pai
        ListTile(
          contentPadding: EdgeInsets.only(left: 16.0 + ((depth + 1) * 20.0), right: 16.0),
          leading: const Icon(Icons.subdirectory_arrow_right, size: 18, color: AppTheme.textSecondary),
          title: Text(
            'Selecionar "${subject.name}"',
            style: const TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
          ),
          trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
          onTap: () {
            widget.onSubjectSelected(subject.id);
            Navigator.pop(context);
          },
        ),
        // Constrói recursivamente os filhos, aumentando a indentação
        ...children.map((child) => _buildSubjectTreeItem(child, allSubjects, depth + 1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjectsState = ref.watch(subjectsProvider);

    // Exibe um widget de carregamento enquanto as matérias não são carregadas
    if (subjectsState.isLoading && subjectsState.subjects.isEmpty) {
      return const LoadingWidget(message: 'Carregando matérias...');
    }

    final subjects = subjectsState.subjects;

    // Encontra o objeto Subject completo com base no ID selecionado
    Subject? selectedSubject;
    if (widget.selectedSubjectId != null) {
      final foundSubjects = subjects.where((s) => s.id == widget.selectedSubjectId);
      if (foundSubjects.isNotEmpty) {
        selectedSubject = foundSubjects.first;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: subjects.isEmpty ? null : () => _showSubjectPicker(context, subjects),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                if (selectedSubject != null) ...[
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color(int.parse(selectedSubject.color.replaceFirst('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(_getIconData(selectedSubject.icon), size: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getSubjectDisplayName(selectedSubject, subjects),
                      style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Text(
                      widget.hint ?? 'Selecione uma matéria',
                      style: const TextStyle(fontSize: 16, color: AppTheme.textTertiary),
                    ),
                  ),
                ],
                const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Converte o nome do ícone (String) em um IconData.
  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'science': return Icons.science;
      case 'calculate': return Icons.calculate;
      case 'history': return Icons.history;
      case 'language': return Icons.language;
      case 'psychology': return Icons.psychology;
      case 'biotech': return Icons.biotech;
      case 'computer': return Icons.computer;
      case 'book': return Icons.book;
      case 'palette': return Icons.palette;
      case 'fitness_center': return Icons.fitness_center;
      case 'music_note': return Icons.music_note;
      default: return Icons.folder;
    }
  }

  /// Retorna o nome de exibição completo, incluindo o caminho dos pais.
  String _getSubjectDisplayName(Subject? subject, List<Subject> allSubjects) {
    if (subject == null) return widget.hint ?? 'Selecione uma matéria';
    final path = _getSubjectPath(subject, allSubjects);
    return path.isNotEmpty ? '$path / ${subject.name}' : subject.name;
  }

  /// Método recursivo para construir a string de caminho de uma matéria.
  String _getSubjectPath(Subject subject, List<Subject> allSubjects) {
    if (subject.parentId == null) return '';

    Subject? parent;
    final foundParents = allSubjects.where((s) => s.id == subject.parentId);
    if (foundParents.isNotEmpty) {
      parent = foundParents.first;
    }

    if (parent == null) return '';

    final parentPath = _getSubjectPath(parent, allSubjects);
    return parentPath.isNotEmpty ? '$parentPath / ${parent.name}' : parent.name;
  }
}