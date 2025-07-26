import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/settings_provider.dart';
import 'package:study_app/widgets/custom_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsProvider.notifier).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de Aparência
            _buildSectionHeader('Aparência'),
            _buildAppearanceSection(settingsState),
            
            const SizedBox(height: 24),
            
            // Seção de Notificações
            _buildSectionHeader('Notificações'),
            _buildNotificationsSection(settingsState),
            
            const SizedBox(height: 24),
            
            // Seção de Revisão
            _buildSectionHeader('Configurações de Revisão'),
            _buildReviewSection(settingsState),
            
            const SizedBox(height: 24),
            
            // Seção de Dados
            _buildSectionHeader('Dados e Privacidade'),
            _buildDataSection(),
            
            const SizedBox(height: 24),
            
            // Seção de Sobre
            _buildSectionHeader('Sobre'),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(SettingsState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Tema
          ListTile(
            leading: Icon(
              state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Tema'),
            subtitle: Text(state.isDarkMode ? 'Escuro' : 'Claro'),
            trailing: Switch(
              value: state.isDarkMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setDarkMode(value);
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),
          
          const Divider(height: 1),
          
          // Tamanho da fonte
          ListTile(
            leading: const Icon(
              Icons.text_fields,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Tamanho da fonte'),
            subtitle: Text(_getFontSizeLabel(state.fontSize)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFontSizeDialog(state.fontSize),
          ),
          
          const Divider(height: 1),
          
          // Idioma
          ListTile(
            leading: const Icon(
              Icons.language,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Idioma'),
            subtitle: Text(state.language == 'pt' ? 'Português' : 'English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(state.language),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(SettingsState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Notificações gerais
          SwitchListTile(
            secondary: const Icon(
              Icons.notifications,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Notificações'),
            subtitle: const Text('Receber notificações do app'),
            value: state.notificationsEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setNotificationsEnabled(value);
            },
            activeColor: AppTheme.primaryColor,
          ),
          
          if (state.notificationsEnabled) ...[
            const Divider(height: 1),
            
            // Notificações de revisão
            SwitchListTile(
              secondary: const Icon(
                Icons.quiz,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Lembretes de revisão'),
              subtitle: const Text('Notificar quando há revisões pendentes'),
              value: state.reviewNotificationsEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setReviewNotificationsEnabled(value);
              },
              activeColor: AppTheme.primaryColor,
            ),
            
            const Divider(height: 1),
            
            // Horário das notificações
            ListTile(
              leading: const Icon(
                Icons.schedule,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Horário dos lembretes'),
              subtitle: Text('${state.notificationTime.hour}:${state.notificationTime.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showTimePickerDialog(state.notificationTime),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewSection(SettingsState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Meta diária
          ListTile(
            leading: const Icon(
              Icons.flag_outlined,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Meta diária de revisões'),
            subtitle: Text('${state.dailyGoal} revisões por dia'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDailyGoalDialog(state.dailyGoal),
          ),
          
          const Divider(height: 1),
          
          // Algoritmo de revisão
          ListTile(
            leading: const Icon(
              Icons.psychology,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Algoritmo de revisão'),
            subtitle: Text(state.reviewAlgorithm == 'sm2' ? 'SM-2 (Recomendado)' : 'Personalizado'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAlgorithmDialog(state.reviewAlgorithm),
          ),
          
          const Divider(height: 1),
          
          // Embaralhar revisões
          SwitchListTile(
            secondary: const Icon(
              Icons.shuffle,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Embaralhar revisões'),
            subtitle: const Text('Apresentar revisões em ordem aleatória'),
            value: state.shuffleReviews,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setShuffleReviews(value);
            },
            activeColor: AppTheme.primaryColor,
          ),
          
          const Divider(height: 1),
          
          // Mostrar progresso
          SwitchListTile(
            secondary: const Icon(
              Icons.show_chart,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Mostrar progresso'),
            subtitle: const Text('Exibir barra de progresso durante revisões'),
            value: state.showProgress,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setShowProgress(value);
            },
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Backup
          ListTile(
            leading: const Icon(
              Icons.backup,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Backup dos dados'),
            subtitle: const Text('Fazer backup na nuvem'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showBackupDialog,
          ),
          
          const Divider(height: 1),
          
          // Exportar dados
          ListTile(
            leading: const Icon(
              Icons.download,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Exportar dados'),
            subtitle: const Text('Baixar todos os seus dados'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportData,
          ),
          
          const Divider(height: 1),
          
          // Limpar cache
          ListTile(
            leading: const Icon(
              Icons.cleaning_services,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Limpar cache'),
            subtitle: const Text('Liberar espaço de armazenamento'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _clearCache,
          ),
          
          const Divider(height: 1),
          
          // Resetar dados
          ListTile(
            leading: const Icon(
              Icons.delete_forever,
              color: AppTheme.errorColor,
            ),
            title: const Text(
              'Resetar todos os dados',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            subtitle: const Text('Apagar todos os dados permanentemente'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showResetDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Versão do app
          ListTile(
            leading: const Icon(
              Icons.info,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Versão do app'),
            subtitle: const Text('1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed('/about');
            },
          ),
          
          const Divider(height: 1),
          
          // Política de privacidade
          ListTile(
            leading: const Icon(
              Icons.privacy_tip,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Política de privacidade'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openPrivacyPolicy,
          ),
          
          const Divider(height: 1),
          
          // Termos de uso
          ListTile(
            leading: const Icon(
              Icons.description,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Termos de uso'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openTermsOfService,
          ),
          
          const Divider(height: 1),
          
          // Suporte
          ListTile(
            leading: const Icon(
              Icons.support,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Suporte'),
            subtitle: const Text('Precisa de ajuda?'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openSupport,
          ),
        ],
      ),
    );
  }

  String _getFontSizeLabel(double fontSize) {
    if (fontSize <= 14) return 'Pequeno';
    if (fontSize <= 16) return 'Médio';
    if (fontSize <= 18) return 'Grande';
    return 'Muito Grande';
  }

  void _showFontSizeDialog(double currentSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tamanho da fonte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<double>(
              title: const Text('Pequeno'),
              value: 14.0,
              groupValue: currentSize,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setFontSize(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<double>(
              title: const Text('Médio'),
              value: 16.0,
              groupValue: currentSize,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setFontSize(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<double>(
              title: const Text('Grande'),
              value: 18.0,
              groupValue: currentSize,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setFontSize(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<double>(
              title: const Text('Muito Grande'),
              value: 20.0,
              groupValue: currentSize,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setFontSize(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Português'),
              value: 'pt',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePickerDialog(TimeOfDay currentTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    
    if (time != null) {
      ref.read(settingsProvider.notifier).setNotificationTime(time);
    }
  }

  void _showDailyGoalDialog(int currentGoal) {
    final controller = TextEditingController(text: currentGoal.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meta diária'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Número de revisões por dia',
            suffixText: 'revisões',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final goal = int.tryParse(controller.text);
              if (goal != null && goal > 0) {
                ref.read(settingsProvider.notifier).setDailyGoal(goal);
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showAlgorithmDialog(String currentAlgorithm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Algoritmo de revisão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('SM-2'),
              subtitle: const Text('Algoritmo clássico de repetição espaçada'),
              value: 'sm2',
              groupValue: currentAlgorithm,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setReviewAlgorithm(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Personalizado'),
              subtitle: const Text('Configurações manuais'),
              value: 'custom',
              groupValue: currentAlgorithm,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setReviewAlgorithm(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup dos dados'),
        content: const Text(
          'Seus dados serão salvos na nuvem e sincronizados entre dispositivos. '
          'Deseja ativar o backup automático?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar backup
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup ativado com sucesso!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Ativar'),
          ),
        ],
      ),
    );
  }

  void _exportData() async {
    // TODO: Implementar exportação de dados
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportação iniciada. Você receberá uma notificação quando estiver pronta.'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _clearCache() async {
    // TODO: Implementar limpeza de cache
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache limpo com sucesso!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar dados'),
        content: const Text(
          'Esta ação irá apagar TODOS os seus dados permanentemente. '
          'Esta ação não pode ser desfeita. Tem certeza?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmReset();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Resetar'),
          ),
        ],
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação final'),
        content: const Text(
          'Digite "RESETAR" para confirmar que deseja apagar todos os dados:',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implementar reset
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todos os dados foram resetados.'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy() {
    // TODO: Abrir política de privacidade
  }

  void _openTermsOfService() {
    // TODO: Abrir termos de uso
  }

  void _openSupport() {
    // TODO: Abrir suporte
  }
}

