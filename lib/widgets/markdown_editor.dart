import 'package:flutter/material.dart';
import 'package:study_app/constants/app_theme.dart';

class MarkdownEditor extends StatefulWidget {
  final String initialText;
  final Function(String) onChanged;
  final String? hintText;
  final bool showToolbar;
  final int? maxLines;

  const MarkdownEditor({
    super.key,
    required this.initialText,
    required this.onChanged,
    this.hintText,
    this.showToolbar = true,
    this.maxLines,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late TabController _tabController;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _tabController = TabController(length: 2, vsync: this);
    
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showToolbar) _buildToolbar(),
        Expanded(
          child: Column(
            children: [
              // Tabs para alternar entre editor e preview
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primaryColor,
                tabs: const [
                  Tab(text: 'Editor'),
                  Tab(text: 'Preview'),
                ],
                onTap: (index) {
                  setState(() {
                    _isPreviewMode = index == 1;
                  });
                },
              ),
              
              // Conteúdo das tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEditor(),
                    _buildPreview(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildToolbarButton(
              icon: Icons.format_bold,
              tooltip: 'Negrito',
              onPressed: () => _insertMarkdown('**', '**'),
            ),
            _buildToolbarButton(
              icon: Icons.format_italic,
              tooltip: 'Itálico',
              onPressed: () => _insertMarkdown('*', '*'),
            ),
            _buildToolbarButton(
              icon: Icons.format_underlined,
              tooltip: 'Sublinhado',
              onPressed: () => _insertMarkdown('<u>', '</u>'),
            ),
            _buildToolbarButton(
              icon: Icons.format_strikethrough,
              tooltip: 'Riscado',
              onPressed: () => _insertMarkdown('~~', '~~'),
            ),
            const VerticalDivider(),
            _buildToolbarButton(
              icon: Icons.title,
              tooltip: 'Título',
              onPressed: () => _insertMarkdown('# ', ''),
            ),
            _buildToolbarButton(
              icon: Icons.format_list_bulleted,
              tooltip: 'Lista',
              onPressed: () => _insertMarkdown('- ', ''),
            ),
            _buildToolbarButton(
              icon: Icons.format_list_numbered,
              tooltip: 'Lista numerada',
              onPressed: () => _insertMarkdown('1. ', ''),
            ),
            const VerticalDivider(),
            _buildToolbarButton(
              icon: Icons.link,
              tooltip: 'Link',
              onPressed: () => _insertMarkdown('[texto](', ')'),
            ),
            _buildToolbarButton(
              icon: Icons.image,
              tooltip: 'Imagem',
              onPressed: () => _insertMarkdown('![alt](', ')'),
            ),
            _buildToolbarButton(
              icon: Icons.code,
              tooltip: 'Código',
              onPressed: () => _insertMarkdown('`', '`'),
            ),
            _buildToolbarButton(
              icon: Icons.format_quote,
              tooltip: 'Citação',
              onPressed: () => _insertMarkdown('> ', ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        color: AppTheme.textSecondary,
        iconSize: 20,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Digite seu texto em Markdown...',
          border: InputBorder.none,
          hintStyle: const TextStyle(
            color: AppTheme.textTertiary,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: _buildMarkdownPreview(_controller.text),
      ),
    );
  }

  Widget _buildMarkdownPreview(String markdown) {
    // Implementação básica de preview de Markdown
    // Em um app real, você usaria um package como flutter_markdown
    
    final lines = markdown.split('\n');
    final widgets = <Widget>[];
    
    for (final line in lines) {
      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              line.substring(2),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              line.substring(3),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              line.substring(4),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        );
      } else if (line.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('> ')) {
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: const Border( // Adicionado 'const' para otimização
                left: BorderSide( // Parâmetro corrigido para 'left'
                  color: AppTheme.primaryColor,
                  width: 4,
                ),
              ),
            ),
            child: Text(
              line.substring(2),
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        );
      } else if (line.trim().isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              _processInlineMarkdown(line),
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 8));
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  String _processInlineMarkdown(String text) {
    // Processamento básico de markdown inline
    // Em um app real, você usaria regex mais sofisticados
    return text
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // Negrito
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // Itálico
        .replaceAll(RegExp(r'`(.*?)`'), r'$1'); // Código
  }

  void _insertMarkdown(String before, String after) {
    final selection = _controller.selection;
    final text = _controller.text;
    
    if (selection.isValid) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$before$selectedText$after',
      );
      
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + before.length + selectedText.length + after.length,
        ),
      );
    } else {
      final cursorPos = selection.baseOffset;
      final newText = text.replaceRange(
        cursorPos,
        cursorPos,
        '$before$after',
      );
      
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: cursorPos + before.length,
        ),
      );
    }
  }
}

class MarkdownToolbar extends StatelessWidget {
  final TextEditingController controller;

  const MarkdownToolbar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          _buildQuickButton('**B**', () => _insertMarkdown('**', '**')),
          _buildQuickButton('*I*', () => _insertMarkdown('*', '*')),
          _buildQuickButton('# H', () => _insertMarkdown('# ', '')),
          _buildQuickButton('• L', () => _insertMarkdown('- ', '')),
          _buildQuickButton('`C`', () => _insertMarkdown('`', '`')),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(32, 32),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _insertMarkdown(String before, String after) {
    final selection = controller.selection;
    final text = controller.text;
    
    if (selection.isValid) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$before$selectedText$after',
      );
      
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + before.length + selectedText.length + after.length,
        ),
      );
    }
  }
}

