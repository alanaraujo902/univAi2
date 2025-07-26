import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/subjects_provider.dart';
import 'package:study_app/widgets/loading_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/subjects_provider.dart';
import 'package:study_app/models/subject.dart'; // Importe o modelo Subject
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subjectsProvider.notifier).loadSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjectsState = ref.watch(subjectsProvider);

    if (subjectsState.isLoading) {
      return const LoadingWidget();
    }

    // --- CORREÇÃO 1/3: 'subjects' é definido aqui e só existe neste escopo ---
    final List<Subject> subjects = subjectsState.subjects;

    final foundSubjects = subjects.where((s) => s.id == widget.selectedSubjectId);
    final selectedSubject = foundSubjects.isNotEmpty ? foundSubjects.first : null;

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
          // --- CORREÇÃO 2/3: Passando 'subjects' como parâmetro ---
          onTap: () => _showSubjectPicker(context, subjects),
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
                      color: Color(int.parse(
                        selectedSubject.color.replaceFirst('#', '0xFF'),
                      )),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: selectedSubject.icon != null
                        ? Icon(
                      _getIconData(selectedSubject.icon!),
                      size: 12,
                      color: Colors.white,
                    )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      // --- CORREÇÃO 3/3: Passando 'subjects' como parâmetro ---
                      _getSubjectDisplayName(selectedSubject, subjects),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Text(
                      widget.hint ?? 'Selecione uma matéria',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ),
                ],
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    // Implemente a lógica para converter o nome do ícone em IconData
    return Icons.folder;
  }

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
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Selecionar Matéria',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  if (widget.allowNull)
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.clear,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      title: const Text('Nenhuma matéria'),
                      subtitle: const Text('Não associar a uma matéria'),
                      onTap: () {
                        widget.onSubjectSelected(null);
                        Navigator.pop(context);
                      },
                    ),
                  ...subjects.map((subject) => _buildSubjectItem(subject, subjects)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectItem(Subject subject, List<Subject> allSubjects) {
    final isSelected = subject.id == widget.selectedSubjectId;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color(int.parse(
            subject.color.replaceFirst('#', '0xFF'),
          )),
          borderRadius: BorderRadius.circular(8),
        ),
        child: subject.icon != null
            ? Icon(
          _getIconData(subject.icon!),
          color: Colors.white,
          size: 20,
        )
            : const Icon(
          Icons.folder,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        subject.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(_getSubjectPath(subject, allSubjects)),
      trailing: isSelected
          ? const Icon(
        Icons.check,
        color: AppTheme.primaryColor,
      )
          : null,
      onTap: () {
        widget.onSubjectSelected(subject.id);
        Navigator.pop(context);
      },
    );
  }

  String _getSubjectDisplayName(Subject? subject, List<Subject> allSubjects) {
    if (subject == null) return '';
    final path = _getSubjectPath(subject, allSubjects);
    return path.isNotEmpty ? '$path > ${subject.name}' : subject.name;
  }

  String _getSubjectPath(Subject subject, List<Subject> allSubjects) {
    if (subject.parentId == null) return '';

    final foundParents = allSubjects.where((s) => s.id == subject.parentId);
    final parent = foundParents.isNotEmpty ? foundParents.first : null;

    if (parent == null) return '';

    final parentPath = _getSubjectPath(parent, allSubjects);
    return parentPath.isNotEmpty ? '$parentPath > ${parent.name}' : parent.name;
  }
}

class SubjectChip extends StatelessWidget {
  final dynamic subject;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDelete;

  const SubjectChip({
    super.key,
    required this.subject,
    this.onTap,
    this.onDelete,
    this.showDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(int.parse(
            subject.color.replaceFirst('#', '0xFF'),
          )).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color(int.parse(
              subject.color.replaceFirst('#', '0xFF'),
            )).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subject.icon != null) ...[
              Icon(
                IconData(
                  int.parse(subject.icon!),
                  fontFamily: 'MaterialIcons',
                ),
                size: 14,
                color: Color(int.parse(
                  subject.color.replaceFirst('#', '0xFF'),
                )),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              subject.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(int.parse(
                  subject.color.replaceFirst('#', '0xFF'),
                )),
              ),
            ),
            if (showDelete && onDelete != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: Color(int.parse(
                    subject.color.replaceFirst('#', '0xFF'),
                  )),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SubjectHierarchySelector extends ConsumerStatefulWidget {
  final String? selectedSubjectId;
  final Function(String?) onSubjectSelected;
  final String? label;

  const SubjectHierarchySelector({
    super.key,
    this.selectedSubjectId,
    required this.onSubjectSelected,
    this.label,
  });

  @override
  ConsumerState<SubjectHierarchySelector> createState() => _SubjectHierarchySelectorState();
}

class _SubjectHierarchySelectorState extends ConsumerState<SubjectHierarchySelector> {
  @override
  Widget build(BuildContext context) {
    final subjectsState = ref.watch(subjectsProvider);

    if (subjectsState.isLoading) {
      return const LoadingWidget();
    }

    final subjects = subjectsState.subjects;
    final rootSubjects = subjects.where((s) => s.parentId == null).toList();

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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecione uma matéria:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ...rootSubjects.map((subject) => _buildSubjectTree(subject, subjects, 0)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectTree(dynamic subject, List<dynamic> allSubjects, int level) {
    final isSelected = subject.id == widget.selectedSubjectId;
    final children = allSubjects.where((s) => s.parentId == subject.id).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: level * 20.0),
          child: GestureDetector(
            onTap: () => widget.onSubjectSelected(subject.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: isSelected
                    ? Border.all(color: AppTheme.primaryColor)
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Color(int.parse(
                        subject.color.replaceFirst('#', '0xFF'),
                      )),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: subject.icon != null
                        ? Icon(
                            IconData(
                              int.parse(subject.icon!),
                              fontFamily: 'MaterialIcons',
                            ),
                            size: 10,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subject.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                ],
              ),
            ),
          ),
        ),
        ...children.map((child) => _buildSubjectTree(child, allSubjects, level + 1)),
      ],
    );
  }
}

