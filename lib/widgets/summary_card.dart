import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/models/summary.dart';
import 'package:study_app/providers/summaries_provider.dart';
import 'package:study_app/screens/summaries/edit_summary_screen.dart';
import 'package:study_app/screens/summaries/summary_detail_screen.dart';

/// Um widget reutilizável que exibe as informações de um resumo em um Card.
/// Ele é um ConsumerWidget para poder interagir com os providers do Riverpod.
class SummaryCard extends ConsumerWidget {
  final Summary summary;

  const SummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              // Cabeçalho com título e ações
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(context, ref, value, summary),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'favorite',
                        child: Row(
                          children: [
                            Icon(
                              summary.isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: summary.isFavorite ? AppTheme.errorColor : null,
                            ),
                            const SizedBox(width: 8),
                            Text(summary.isFavorite ? 'Desfavoritar' : 'Favoritar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text('Editar'),
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
              const SizedBox(height: 8),
              // Conteúdo do resumo
              Text(
                summary.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Tags e informações
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (summary.subject != null)
                    _buildTag(
                      summary.subject!.name, // Usando ! pois já verificamos
                      Color(int.parse(summary.subject!.color.replaceFirst('#', '0xFF'))),
                    ),
                  _buildTag(
                    summary.difficultyText,
                    _getDifficultyColor(summary.difficultyLevel),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Rodapé com data e status de revisão
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(summary.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  if (summary.needsReview)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Revisar',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.warningColor,
                        ),
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

  // Métodos de ajuda movidos para cá
  void _handleMenuAction(BuildContext context, WidgetRef ref, String action, Summary summary) {
    switch (action) {
      case 'favorite':
        ref.read(summariesProvider.notifier).toggleFavorite(summary.id);
        break;
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditSummaryScreen(summary: summary),
          ),
        );
        break;
      case 'delete':
        _showDeleteDialog(context, ref, summary);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Summary summary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir resumo'),
        content: const Text('Tem certeza que deseja excluir este resumo? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(summariesProvider.notifier).deleteSummary(summary.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
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
}