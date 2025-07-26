import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/summaries_provider.dart';
import 'package:study_app/widgets/custom_button.dart';
import 'package:study_app/widgets/custom_text_field.dart';
import 'package:study_app/widgets/markdown_editor.dart';
import 'package:study_app/widgets/subject_selector.dart';
import 'package:study_app/widgets/difficulty_selector.dart';
import 'package:study_app/widgets/tag_input.dart';

class EditSummaryScreen extends ConsumerStatefulWidget {
  final dynamic summary;

  const EditSummaryScreen({
    super.key,
    required this.summary,
  });

  @override
  ConsumerState<EditSummaryScreen> createState() => _EditSummaryScreenState();
}

class _EditSummaryScreenState extends ConsumerState<EditSummaryScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  late TabController _tabController;
  bool _isLoading = false;
  bool _hasChanges = false;
  
  String? _selectedSubjectId;
  int _difficultyLevel = 3;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Inicializar com dados do resumo
    _titleController.text = widget.summary.title;
    _contentController.text = widget.summary.content;
    _selectedSubjectId = widget.summary.subjectId;
    _difficultyLevel = widget.summary.difficultyLevel;
    _tags = List<String>.from(widget.summary.tags ?? []);
    
    // Detectar mudanças
    _titleController.addListener(_onContentChanged);
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedSummary = widget.summary.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        subjectId: _selectedSubjectId,
        difficultyLevel: _difficultyLevel,
        tags: _tags,
        updatedAt: DateTime.now(),
      );

      await ref.read(summariesProvider.notifier).updateSummary(updatedSummary);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resumo atualizado com sucesso!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pop(updatedSummary);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar resumo: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text(
          'Você tem alterações não salvas. Deseja descartar as alterações?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Editar Resumo'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveChanges,
                child: Text(
                  'Salvar',
                  style: TextStyle(
                    color: _isLoading ? Colors.grey : AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Editar'),
              Tab(text: 'Configurações'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEditTab(),
              _buildSettingsTab(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildEditTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título
          CustomTextField(
            controller: _titleController,
            label: 'Título do resumo',
            hint: 'Digite o título do resumo',
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Digite o título do resumo';
              }
              if (value.trim().length < 3) {
                return 'O título deve ter pelo menos 3 caracteres';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Editor de conteúdo
          const Text(
            'Conteúdo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Digite seu texto em Markdown...',
              alignLabelWithHint: true,
              labelText: 'Conteúdo',
            ),
            maxLines: 15,
            minLines: 10,
            style: const TextStyle(
              fontFamily: 'monospace',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Digite o conteúdo do resumo';
              }
              if (value.trim().length < 10) {
                return 'O conteúdo deve ter pelo menos 10 caracteres';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Dicas de Markdown
          _buildMarkdownTips(),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Seleção de matéria
          SubjectSelector(
            selectedSubjectId: _selectedSubjectId,
            onSubjectSelected: (subjectId) { // Parâmetro corrigido
              setState(() {
                _selectedSubjectId = subjectId;
                _onContentChanged();
              });
            },
          ),
          const SizedBox(height: 24),

          // Nível de dificuldade
          DifficultySelector(
            selectedDifficulty: _difficultyLevel, // Parâmetro corrigido
            onDifficultySelected: (level) { // Parâmetro corrigido
              setState(() {
                _difficultyLevel = level;
                _onContentChanged();
              });
            },
          ),
          const SizedBox(height: 24),

          // Tags
          TagInput(
            initialTags: _tags, // Parâmetro corrigido
            onTagsChanged: (tags) {
              setState(() {
                _tags = tags;
                _onContentChanged();
              });
            },
          ),

          const SizedBox(height: 24),

          // Informações do resumo
          _buildSummaryInfo(),
        ],
      ),
    );
  }

  Widget _buildMarkdownTips() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Dicas de Markdown',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '**Negrito** | *Itálico* | # Título | - Lista | > Citação',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações do Resumo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildInfoRow('Criado em', _formatDate(widget.summary.createdAt)),
          _buildInfoRow('Última atualização', _formatDate(widget.summary.updatedAt)),
          _buildInfoRow('Revisões realizadas', '${widget.summary.reviewCount}'),
          _buildInfoRow('Próxima revisão', 
            widget.summary.nextReviewDate != null 
                ? _formatDate(widget.summary.nextReviewDate!)
                : 'Não agendada'
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    if (!_hasChanges) return const SizedBox.shrink();

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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () async {
                final shouldDiscard = await _onWillPop();
                if (shouldDiscard && mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Descartar'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: CustomButton(
              text: 'Salvar Alterações',
              onPressed: _isLoading ? null : _saveChanges,
              isLoading: _isLoading,
              icon: Icons.save,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

