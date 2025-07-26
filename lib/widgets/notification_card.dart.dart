import 'package:flutter/material.dart';
import 'package:study_app/constants/app_theme.dart';

/// Define os tipos de notificação para estilização.
enum NotificationType { info, success, warning, error }

/// Um widget de card para exibir notificações no aplicativo.
class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final NotificationType type;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;
  final String? timestamp;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    this.type = NotificationType.info,
    this.onDismiss,
    this.onTap,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = _getNotificationTheme();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: themeData['color']!,
                width: 5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      themeData['icon'],
                      color: themeData['color'],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (onDismiss != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: onDismiss,
                        color: AppTheme.textSecondary,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                if (timestamp != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Text(
                      timestamp!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Retorna a cor e o ícone com base no tipo de notificação.
  Map<String, dynamic> _getNotificationTheme() {
    switch (type) {
      case NotificationType.success:
        return {'color': AppTheme.successColor, 'icon': Icons.check_circle};
      case NotificationType.warning:
        return {'color': AppTheme.warningColor, 'icon': Icons.warning};
      case NotificationType.error:
        return {'color': AppTheme.errorColor, 'icon': Icons.error};
      case NotificationType.info:
      default:
        return {'color': AppTheme.primaryColor, 'icon': Icons.info};
    }
  }
}