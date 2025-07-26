import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/subjects_provider.dart';
import 'package:study_app/widgets/custom_button.dart';
import 'package:study_app/widgets/custom_text_field.dart';

class CreateSubjectScreen extends ConsumerStatefulWidget {
  final dynamic subject; // Para edição
  final dynamic parentSubject; // Para criar submatéria

  const CreateSubjectScreen({
    super.key,
    this.subject,
    this.parentSubject,
  });

  @override
  ConsumerState<CreateSubjectScreen> createState() => _CreateSubjectScreenState();
}

class _CreateSubjectScreenState extends ConsumerState<CreateSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedColor = '#2563EB';
  String _selectedIcon = 'folder';
  bool _isLoading = false;

  final List<String> _availableColors = [
    '#2563EB', // Azul
    '#10B981', // Verde
    '#F59E0B', // Amarelo
    '#EF4444', // Vermelho
    '#8B5CF6', // Roxo
    '#F97316', // Laranja
    '#06B6D4', // Ciano
    '#84CC16', // Lima
    '#EC4899', // Rosa
    '#6B7280', // Cinza
  ];

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'folder', 'icon': Icons.folder, 'label': 'Pasta'},
    {'name': 'science', 'icon': Icons.science, 'label': 'Ciências'},
    {'name': 'calculate', 'icon': Icons.calculate, 'label': 'Matemática'},
    {'name': 'history', 'icon': Icons.history, 'label': 'História'},
    {'name': 'language', 'icon': Icons.language, 'label': 'Idiomas'},
    {'name': 'psychology', 'icon': Icons.psychology, 'label': 'Psicologia'},
    {'name': 'biotech', 'icon': Icons.biotech, 'label': 'Biologia'},
    {'name': 'computer', 'icon': Icons.computer, 'label': 'Informática'},
    {'name': 'book', 'icon': Icons.book, 'label': 'Literatura'},
    {'name': 'palette', 'icon': Icons.palette, 'label': 'Artes'},
    {'name': 'fitness_center', 'icon': Icons.fitness_center, 'label': 'Educação Física'},
    {'name': 'music_note', 'icon': Icons.music_note, 'label': 'Música'},
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.subject != null) {
      // Modo edição
      _nameController.text = widget.subject.name;
      _descriptionController.text = widget.subject.description ?? '';
      _selectedColor = widget.subject.color;
      _selectedIcon = widget.subject.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveSubject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final subjectData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        'color': _selectedColor,
        'icon': _selectedIcon,
        'parent_id': widget.parentSubject?.id,
      };

      if (widget.subject != null) {
        // Editar matéria existente
        await ref.read(subjectsProvider.notifier).updateSubject(
          widget.subject.id,
          subjectData,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Matéria atualizada com sucesso!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        // Criar nova matéria
        await ref.read(subjectsProvider.notifier).createSubject(subjectData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Matéria criada com sucesso!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar matéria: $e'),
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subject != null;
    final isSubject = widget.parentSubject != null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing 
              ? 'Editar Matéria'
              : isSubject 
                  ? 'Nova Submatéria'
                  : 'Nova Matéria',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview da matéria
              _buildPreviewCard(),
              
              const SizedBox(height: 24),
              
              // Nome da matéria
              CustomTextField(
                controller: _nameController,
                label: 'Nome da matéria',
                hint: 'Ex: Anatomia Humana',
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Digite o nome da matéria';
                  }
                  if (value.trim().length < 2) {
                    return 'O nome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              
              const SizedBox(height: 16),
              
              // Descrição (opcional)
              CustomTextField(
                controller: _descriptionController,
                label: 'Descrição (opcional)',
                hint: 'Descreva brevemente o conteúdo desta matéria',
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) => setState(() {}),
              ),
              
              const SizedBox(height: 24),
              
              // Seleção de cor
              _buildColorSelector(),
              
              const SizedBox(height: 24),
              
              // Seleção de ícone
              _buildIconSelector(),
              
              const SizedBox(height: 24),
              
              // Informação sobre matéria pai
              if (widget.parentSubject != null)
                _buildParentInfo(),
              
              const SizedBox(height: 32),
              
              // Botão de salvar
              CustomButton(
                text: isEditing ? 'Atualizar Matéria' : 'Criar Matéria',
                onPressed: _isLoading ? null : _saveSubject,
                isLoading: _isLoading,
                icon: isEditing ? Icons.save : Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(int.parse(_selectedColor.replaceFirst('#', '0xFF'))),
              Color(int.parse(_selectedColor.replaceFirst('#', '0xFF'))).withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                _getIconData(_selectedIcon),
                size: 30,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _nameController.text.isEmpty ? 'Nome da Matéria' : _nameController.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (_descriptionController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _descriptionController.text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cor da matéria',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableColors.map((color) {
            final isSelected = color == _selectedColor;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: AppTheme.textPrimary, width: 3)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Color(int.parse(color.replaceFirst('#', '0xFF'))).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ícone da matéria',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _availableIcons.length,
          itemBuilder: (context, index) {
            final iconData = _availableIcons[index];
            final isSelected = iconData['name'] == _selectedIcon;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIcon = iconData['name'];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Color(int.parse(_selectedColor.replaceFirst('#', '0xFF'))).withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(
                          color: Color(int.parse(_selectedColor.replaceFirst('#', '0xFF'))),
                          width: 2,
                        )
                      : Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconData['icon'],
                      size: 24,
                      color: isSelected
                          ? Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')))
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      iconData['label'],
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')))
                            : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildParentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submatéria de:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.parentSubject!.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconData = _availableIcons.firstWhere(
      (icon) => icon['name'] == iconName,
      orElse: () => _availableIcons[0],
    );
    return iconData['icon'];
  }
}

