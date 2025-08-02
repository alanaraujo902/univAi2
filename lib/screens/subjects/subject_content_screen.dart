import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/models/subject.dart';
import 'package:study_app/providers/summaries_provider.dart';
import 'package:study_app/widgets/empty_state_widget.dart';
import 'package:study_app/widgets/loading_widget.dart';
// <<< 1. IMPORTE O NOVO WIDGET AQUI >>>
import 'package:study_app/widgets/summary_card.dart';

class SubjectContentScreen extends ConsumerWidget {
  final Subject subject;

  const SubjectContentScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesState = ref.watch(summariesBySubjectHierarchyProvider(subject.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Conteúdo de: ${subject.name}'),
        backgroundColor: Color(int.parse(subject.color.replaceFirst('#', '0xFF'))),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(summariesBySubjectHierarchyProvider(subject.id));
        },
        child: _buildContent(context, summariesState),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SummariesState state) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Carregando resumos...');
    }

    if (state.error != null) {
      return Center(child: Text('Erro: ${state.error}'));
    }

    if (state.summaries.isEmpty) {
      return const CustomEmptyStateWidget(
        icon: Icons.description_outlined,
        title: 'Nenhum resumo encontrado',
        subtitle: 'Não há resumos nesta matéria ou em suas submatérias.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.summaries.length,
      itemBuilder: (context, index) {
        final summary = state.summaries[index];
        // <<< 2. SUBSTITUA AS LINHAS COM ERRO POR ESTA >>>
        return SummaryCard(summary: summary);
      },
    );
  }
}