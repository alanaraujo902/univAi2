import 'package:flutter/material.dart';
import 'package:study_app/constants/app_theme.dart';

class DifficultySelector extends StatefulWidget {
  final int? selectedDifficulty;
  final Function(int) onDifficultySelected;
  final String? label;
  final bool showLabels;
  final bool showDescription;

  const DifficultySelector({
    super.key,
    this.selectedDifficulty,
    required this.onDifficultySelected,
    this.label,
    this.showLabels = true,
    this.showDescription = true,
  });

  @override
  State<DifficultySelector> createState() => _DifficultySelectorState();
}

class _DifficultySelectorState extends State<DifficultySelector> {
  final List<DifficultyLevel> _difficultyLevels = [
    DifficultyLevel(
      value: 1,
      label: 'Muito Fácil',
      description: 'Lembrei facilmente',
      color: AppTheme.successColor,
      icon: Icons.sentiment_very_satisfied,
    ),
    DifficultyLevel(
      value: 2,
      label: 'Fácil',
      description: 'Lembrei com pouco esforço',
      color: Colors.lightGreen,
      icon: Icons.sentiment_satisfied,
    ),
    DifficultyLevel(
      value: 3,
      label: 'Médio',
      description: 'Lembrei com algum esforço',
      color: AppTheme.warningColor,
      icon: Icons.sentiment_neutral,
    ),
    DifficultyLevel(
      value: 4,
      label: 'Difícil',
      description: 'Lembrei com muito esforço',
      color: Colors.orange,
      icon: Icons.sentiment_dissatisfied,
    ),
    DifficultyLevel(
      value: 5,
      label: 'Muito Difícil',
      description: 'Não consegui lembrar',
      color: AppTheme.errorColor,
      icon: Icons.sentiment_very_dissatisfied,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Botões de dificuldade
        Row(
          children: _difficultyLevels.map((level) {
            final isSelected = widget.selectedDifficulty == level.value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildDifficultyButton(level, isSelected),
              ),
            );
          }).toList(),
        ),
        
        if (widget.showDescription && widget.selectedDifficulty != null) ...[
          const SizedBox(height: 16),
          _buildSelectedDescription(),
        ],
      ],
    );
  }

  Widget _buildDifficultyButton(DifficultyLevel level, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onDifficultySelected(level.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? level.color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: level.color,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: level.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              level.icon,
              color: isSelected ? Colors.white : level.color,
              size: 24,
            ),
            if (widget.showLabels) ...[
              const SizedBox(height: 4),
              Text(
                level.value.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : level.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDescription() {
    final selectedLevel = _difficultyLevels.firstWhere(
      (level) => level.value == widget.selectedDifficulty,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selectedLevel.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedLevel.color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                selectedLevel.icon,
                color: selectedLevel.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                selectedLevel.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: selectedLevel.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            selectedLevel.description,
            style: TextStyle(
              fontSize: 14,
              color: selectedLevel.color,
            ),
          ),
        ],
      ),
    );
  }
}

class DifficultyLevel {
  final int value;
  final String label;
  final String description;
  final Color color;
  final IconData icon;

  DifficultyLevel({
    required this.value,
    required this.label,
    required this.description,
    required this.color,
    required this.icon,
  });
}

class CompactDifficultySelector extends StatelessWidget {
  final int? selectedDifficulty;
  final Function(int) onDifficultySelected;

  const CompactDifficultySelector({
    super.key,
    this.selectedDifficulty,
    required this.onDifficultySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final difficulty = index + 1;
        final isSelected = selectedDifficulty == difficulty;
        final color = _getDifficultyColor(difficulty);

        return GestureDetector(
          onTap: () => onDifficultySelected(difficulty),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                difficulty.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return AppTheme.successColor;
      case 2:
        return Colors.lightGreen;
      case 3:
        return AppTheme.warningColor;
      case 4:
        return Colors.orange;
      case 5:
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }
}

class DifficultySlider extends StatefulWidget {
  final double initialValue;
  final Function(double) onChanged;
  final String? label;

  const DifficultySlider({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.label,
  });

  @override
  State<DifficultySlider> createState() => _DifficultySliderState();
}

class _DifficultySliderState extends State<DifficultySlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        Row(
          children: [
            const Text(
              'Fácil',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Expanded(
              child: Slider(
                value: _currentValue,
                min: 1.0,
                max: 5.0,
                divisions: 4,
                activeColor: _getDifficultyColor(_currentValue.round()),
                inactiveColor: Colors.grey[300],
                onChanged: (value) {
                  setState(() {
                    _currentValue = value;
                  });
                  widget.onChanged(value);
                },
              ),
            ),
            const Text(
              'Difícil',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getDifficultyColor(_currentValue.round()).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getDifficultyLabel(_currentValue.round()),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getDifficultyColor(_currentValue.round()),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return AppTheme.successColor;
      case 2:
        return Colors.lightGreen;
      case 3:
        return AppTheme.warningColor;
      case 4:
        return Colors.orange;
      case 5:
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Muito Fácil';
      case 2:
        return 'Fácil';
      case 3:
        return 'Médio';
      case 4:
        return 'Difícil';
      case 5:
        return 'Muito Difícil';
      default:
        return 'Médio';
    }
  }
}

class DifficultyIndicator extends StatelessWidget {
  final int difficulty;
  final bool showLabel;
  final double size;

  const DifficultyIndicator({
    super.key,
    required this.difficulty,
    this.showLabel = true,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getDifficultyColor(difficulty);
    final icon = _getDifficultyIcon(difficulty);
    final label = _getDifficultyLabel(difficulty);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: size,
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: size * 0.6,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ],
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return AppTheme.successColor;
      case 2:
        return Colors.lightGreen;
      case 3:
        return AppTheme.warningColor;
      case 4:
        return Colors.orange;
      case 5:
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getDifficultyIcon(int difficulty) {
    switch (difficulty) {
      case 1:
        return Icons.sentiment_very_satisfied;
      case 2:
        return Icons.sentiment_satisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_dissatisfied;
      case 5:
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String _getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Muito Fácil';
      case 2:
        return 'Fácil';
      case 3:
        return 'Médio';
      case 4:
        return 'Difícil';
      case 5:
        return 'Muito Difícil';
      default:
        return 'Médio';
    }
  }
}

