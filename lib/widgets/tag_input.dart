import 'package:flutter/material.dart';
import 'package:study_app/constants/app_theme.dart';

/// Um campo de input para adicionar e remover tags.
class TagInput extends StatefulWidget {
  /// Lista inicial de tags.
  final List<String> initialTags;

  /// Callback chamado quando a lista de tags é alterada.
  final Function(List<String>) onTagsChanged;

  /// Texto de dica para o campo de input.
  final String hintText;

  /// Rótulo opcional exibido acima do campo.
  final String? label;

  const TagInput({
    super.key,
    this.initialTags = const [],
    required this.onTagsChanged,
    this.hintText = 'Adicionar tag...',
    this.label,
  });

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  late final TextEditingController _controller;
  late final List<String> _tags;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _tags = List<String>.from(widget.initialTags);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final newTag = tag.trim();
    if (newTag.isNotEmpty && !_tags.contains(newTag)) {
      setState(() {
        _tags.add(newTag);
        _controller.clear();
      });
      widget.onTagsChanged(_tags);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) => _buildTagChip(tag)).toList(),
              ),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: _addTag,
                onChanged: (value) {
                  if (value.endsWith(',') || value.endsWith(' ')) {
                    _addTag(value.substring(0, value.length - 1));
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag),
      labelStyle: const TextStyle(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      deleteIcon: const Icon(
        Icons.close,
        size: 16,
        color: AppTheme.primaryColor,
      ),
      onDeleted: () => _removeTag(tag),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}