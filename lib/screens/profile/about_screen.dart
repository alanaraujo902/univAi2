// Caminho: lib/screens/profile/about_screen.dart

import 'package:flutter/material.dart';
import 'package:study_app/constants/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Sobre'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),

            // Logo e nome do app
            _buildAppHeader(),

            const SizedBox(height: 32),

            // Informações do app
            _buildAppInfo(),

            const SizedBox(height: 24),

            // Recursos principais
            _buildFeatures(),

            const SizedBox(height: 24),

            // Equipe de desenvolvimento
            _buildTeam(),

            const SizedBox(height: 24),

            // Tecnologias utilizadas
            _buildTechnologies(),

            const SizedBox(height: 24),

            // Links úteis
            _buildUsefulLinks(),

            const SizedBox(height: 24),

            // Agradecimentos
            _buildAcknowledgments(),

            const SizedBox(height: 32),

            // Copyright
            _buildCopyright(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.school,
            size: 50,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'StudyApp',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Versão 1.0.0',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sobre o StudyApp',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'O StudyApp é um aplicativo inovador de estudos que utiliza inteligência artificial para criar resumos personalizados e implementa técnicas de repetição espaçada para otimizar seu aprendizado.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nosso objetivo é tornar o estudo mais eficiente e organizado, ajudando estudantes a alcançarem seus objetivos acadêmicos com menos esforço e melhores resultados.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      {
        'icon': Icons.auto_awesome,
        'title': 'IA Integrada',
        'description': 'Geração automática de resumos com Perplexity AI',
      },
      {
        'icon': Icons.psychology,
        'title': 'Repetição Espaçada',
        'description': 'Algoritmo SM-2 para otimizar a retenção',
      },
      {
        'icon': Icons.camera_alt,
        'title': 'Captura de Imagem',
        'description': 'Tire fotos de textos e transforme em resumos',
      },
      {
        'icon': Icons.edit,
        'title': 'Editor Markdown',
        'description': 'Edição rica com formatação avançada',
      },
      {
        'icon': Icons.folder_special,
        'title': 'Organização',
        'description': 'Matérias hierárquicas e decks personalizados',
      },
      {
        'icon': Icons.analytics,
        'title': 'Estatísticas',
        'description': 'Acompanhe seu progresso em detalhes',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recursos Principais',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => _buildFeatureItem(feature)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(Map<String, dynamic> feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              feature['icon'],
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  feature['description'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeam() {
    final teamMembers = [
      {
        'name': 'Equipe de Desenvolvimento',
        'role': 'Desenvolvimento Full-Stack',
        'description': 'Responsável pela criação e manutenção do aplicativo',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Equipe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...teamMembers.map((member) => _buildTeamMember(member)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(Map<String, dynamic> member) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  member['role'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  member['description'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnologies() {
    final technologies = [
      {'name': 'Flutter', 'description': 'Framework de desenvolvimento mobile'},
      {'name': 'Dart', 'description': 'Linguagem de programação'},
      {'name': 'Flask', 'description': 'Backend API em Python'},
      {'name': 'Supabase', 'description': 'Banco de dados PostgreSQL'},
      {'name': 'Perplexity AI', 'description': 'Inteligência artificial para resumos'},
      {'name': 'Material Design', 'description': 'Sistema de design'},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tecnologias Utilizadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: technologies.map((tech) => _buildTechChip(tech)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechChip(Map<String, dynamic> tech) {
    return Tooltip(
      message: tech['description'],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          tech['name'],
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildUsefulLinks() {
    final links = [
      {
        'title': 'Política de Privacidade',
        'icon': Icons.privacy_tip,
        'onTap': () {
          // TODO: Abrir política de privacidade
        },
      },
      {
        'title': 'Termos de Uso',
        'icon': Icons.description,
        'onTap': () {
          // TODO: Abrir termos de uso
        },
      },
      {
        'title': 'Suporte',
        'icon': Icons.support,
        'onTap': () {
          // TODO: Abrir suporte
        },
      },
      {
        'title': 'Avaliar na Store',
        'icon': Icons.star,
        'onTap': () {
          // TODO: Abrir avaliação
        },
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Links Úteis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          ...links.asMap().entries.map((entry) {
            final index = entry.key;
            final link = entry.value;
            return Column(
              children: [
                if (index > 0) const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    link['icon'] as IconData?, // CORRIGIDO
                    color: AppTheme.primaryColor,
                  ),
                  title: Text(link['title'] as String), // CORRIGIDO
                  trailing: const Icon(Icons.chevron_right),
                  onTap: link['onTap'] as GestureTapCallback?, // CORRIGIDO
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAcknowledgments() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agradecimentos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Agradecemos a todos os usuários que contribuíram com feedback e sugestões para tornar o StudyApp cada vez melhor.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Agradecimento especial às comunidades open source que tornaram este projeto possível.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyright() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Text(
          '© ${DateTime.now().year} StudyApp',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Todos os direitos reservados',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiary,
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Feito com ',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textTertiary,
              ),
            ),
            Icon(
              Icons.favorite,
              size: 12,
              color: AppTheme.errorColor,
            ),
            Text(
              ' para estudantes',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}