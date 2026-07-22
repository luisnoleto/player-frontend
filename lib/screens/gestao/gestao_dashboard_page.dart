import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/session_provider.dart';
import '../../providers/atividade_provider.dart';
import '../../providers/jornada_provider.dart';
import '../../providers/relatorio_provider.dart';
import '../../widgets/adherence_progress_bar.dart';
import '../../widgets/jornada_list_tile.dart';
import '../../widgets/stat_card.dart';

class GestaoDashboardPage extends StatefulWidget {
  const GestaoDashboardPage({super.key});

  @override
  State<GestaoDashboardPage> createState() => _GestaoDashboardPageState();
}

class _GestaoDashboardPageState extends State<GestaoDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarDados());
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;
    final relatorio = context.read<RelatorioProvider>();
    final jornadas = context.read<JornadaProvider>();
    final atividades = context.read<AtividadeProvider>();
    await Future.wait([
      relatorio.carregarVisaoGestaoUltimosTrintaDias(),
      jornadas.listarComFiltros(),
      atividades.listarTodas(),
    ]);

    if (!mounted) return;
    final error = relatorio.error ?? jornadas.error ?? atividades.error;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => Consumer3<RelatorioProvider, JornadaProvider, AtividadeProvider>(
    builder: (context, relatorioProvider, jornadaProvider, atividadeProvider, _) {
      if (relatorioProvider.isLoading ||
          jornadaProvider.isLoading ||
          atividadeProvider.isLoading) {
        return Scaffold(
          appBar: AppBar(title: const Text('Área de Gestão')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      final relatorio = relatorioProvider.relatorioGestao;
      final ultimasJornadas = jornadaProvider.jornadas.take(5).toList();
      return Scaffold(
        appBar: AppBar(
          title: const Text('Área de Gestão'),
          actions: [
            IconButton(
              onPressed: () {
                context.read<SessionProvider>().logout();
                context.go('/');
              },
              tooltip: 'Sair',
              icon: const Icon(LucideIcons.logOut),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _carregarDados,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Visão Geral — Todos os Colaboradores',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              StatCard(
                label: 'Horas Trabalhadas',
                value:
                    '${relatorioProvider.horasEquipe?.totalHoras.toStringAsFixed(1) ?? '0.0'} h',
                icon: LucideIcons.clock3,
                tooltip:
                    'Total da equipe considerando as jornadas finalizadas nos últimos 30 dias.',
                onTap: () => context.push('/gestao/horas-trabalhadas'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Planejadas',
                      value: '${atividadeProvider.planejadas.length}',
                      onTap: () =>
                          context.push('/gestao/atividades/planejadas'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Concluídas',
                      value: '${atividadeProvider.concluidas.length}',
                      onTap: () =>
                          context.push('/gestao/atividades/concluidas'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AdherenceProgressBar(
                percentual: relatorio?.percentualAderenciaMedio ?? 0,
              ),
              const SizedBox(height: 28),
              Text(
                'Últimas Jornadas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (ultimasJornadas.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Nenhuma jornada encontrada.'),
                )
              else
                Column(
                  children: [
                    for (var index = 0; index < ultimasJornadas.length; index++)
                      JornadaListTile(jornada: ultimasJornadas[index]),
                  ],
                ),
              const SizedBox(height: 28),
              Text('Atalhos', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _AtalhoCard(
                    label: 'Colaboradores',
                    icon: Icons.people_outline,
                    onTap: () => context.push('/colaboradores'),
                  ),
                  _AtalhoCard(
                    label: 'Consultar Jornadas',
                    icon: Icons.manage_search_outlined,
                    onTap: () => context.push('/gestao/jornadas'),
                  ),
                  _AtalhoCard(
                    label: 'Relatórios',
                    icon: Icons.bar_chart_outlined,
                    onTap: () => context.push('/gestao/relatorios'),
                  ),
                  _AtalhoCard(
                    label: 'Registros RPA',
                    icon: Icons.pending_actions_outlined,
                    onTap: () => context.push('/gestao/rpa'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _AtalhoCard extends StatelessWidget {
  const _AtalhoCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}
