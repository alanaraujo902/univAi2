import 'package:flutter/material.dart';
import 'package:study_app/constants/app_theme.dart';
import 'dart:math' as math;

/// Um indicador de progresso linear customizável.
class CustomLinearProgressIndicator extends StatelessWidget {
  /// O valor do progresso, entre 0.0 e 1.0.
  final double progress;

  /// A cor da barra de progresso.
  final Color color;

  /// A cor de fundo da barra.
  final Color backgroundColor;

  /// A altura da barra.
  final double height;

  const CustomLinearProgressIndicator({
    super.key,
    required this.progress,
    this.color = AppTheme.primaryColor,
    this.backgroundColor = Colors.black12,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: height,
      ),
    );
  }
}

/// Um indicador de progresso circular com texto no centro.
class CustomCircularProgressIndicator extends StatelessWidget {
  /// O valor do progresso, entre 0.0 e 1.0.
  final double progress;

  /// O tamanho do widget (diâmetro).
  final double size;

  /// A espessura da linha do indicador.
  final double strokeWidth;

  /// A cor do indicador de progresso.
  final Color color;

  /// A cor de fundo do indicador.
  final Color backgroundColor;

  /// O texto a ser exibido no centro.
  final String? centerText;

  const CustomCircularProgressIndicator({
    super.key,
    required this.progress,
    this.size = 100.0,
    this.strokeWidth = 8.0,
    this.color = AppTheme.primaryColor,
    this.backgroundColor = Colors.black12,
    this.centerText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(backgroundColor),
          ),
          CircularProgressIndicator(
            value: progress,
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
          if (centerText != null)
            Center(
              child: Text(
                centerText!,
                style: TextStyle(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Um indicador de progresso em formato de anel para metas.
class GoalProgressIndicator extends StatelessWidget {
  final int current;
  final int goal;
  final double size;
  final String label;

  const GoalProgressIndicator({
    super.key,
    required this.current,
    required this.goal,
    required this.label,
    this.size = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final isCompleted = current >= goal;

    return CustomCircularProgressIndicator(
      progress: progress,
      size: size,
      strokeWidth: 10,
      color: isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
      backgroundColor: (isCompleted ? AppTheme.successColor : AppTheme.primaryColor).withOpacity(0.2),
      centerText: '$current/$goal\n$label',
    );
  }
}