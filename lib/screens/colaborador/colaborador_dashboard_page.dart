import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/session_provider.dart';
import '../../providers/jornada_provider.dart';
import '../../providers/relatorio_provider.dart';
import '../../widgets/adherence_progress_bar.dart';
import '../../widgets/stat_card.dart';

class ColaboradorDashboardPage extends StatefulWidget {
  const ColaboradorDashboardPage({super.key});

  @override
  State<ColaboradorDashboardPage> createState() =>
      _ColaboradorDashboardPageState();
}

class _ColaboradorDashboardPageState extends State<ColaboradorDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarDados());
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;
    final colaborador = context.read<SessionProvider>().colaboradorAtual;
    if (colaborador == null) {
      context.replace('/area-colaborador');
      return;
    }

    final relatorio = context.read<RelatorioProvider>();
    final jornadas = context.read<JornadaProvider>();
    await Future.wait([
      relatorio.gerarConsolidado(colaboradorId: colaborador.id),
      jornadas.listarComFiltros(
        colaboradorId: colaborador.id,
        status: 'EM_ANDAMENTO',
      ),
    ]);

    if (!mounted) return;
    final error = relatorio.error ?? jornadas.error;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => Consumer2<SessionProvider, RelatorioProvider>(
    builder: (context, session, relatorioProvider, _) {
      final colaborador = session.colaboradorAtual;
      if (colaborador == null) {
        return const Scaffold(
          appBar: _DashboardAppBar(),
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Consumer<JornadaProvider>(
        builder: (context, jornadaProvider, _) {
          if (relatorioProvider.isLoading || jornadaProvider.isLoading) {
            return const Scaffold(
              appBar: _DashboardAppBar(),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final relatorio = relatorioProvider.relatorio;
          final jornadaAtiva = jornadaProvider.jornadas.isEmpty
              ? null
              : jornadaProvider.jornadas.first;
          final stats = [
            StatCard(
              label: 'Horas Trabalhadas',
              value:
                  '${relatorio?.totalHorasTrabalhadas.toStringAsFixed(1) ?? '0.0'} h',
            ),
            StatCard(
              label: 'Planejadas',
              value: '${relatorio?.quantidadeAtividadesPlanejadas ?? 0}',
            ),
            StatCard(
              label: 'Concluídas',
              value: '${relatorio?.quantidadeAtividadesConcluidas ?? 0}',
            ),
          ];

          return Scaffold(
            appBar: const _DashboardAppBar(),
            body: LayoutBuilder(
              builder: (context, viewport) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewport.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        colaborador.nome,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        context
                                            .read<SessionProvider>()
                                            .limpar();
                                        context.go('/area-colaborador');
                                      },
                                      icon: const Icon(
                                        LucideIcons.refreshCw,
                                        size: 18,
                                      ),
                                      label: const Text('Trocar'),
                                    ),
                                  ],
                                )
                                .animate()
                                .fadeIn(duration: 250.ms)
                                .slideY(begin: 0.04),
                            const Gap(20),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              childAspectRatio: 1.35,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              children: List.generate(
                                stats.length,
                                (index) => stats[index]
                                    .animate(delay: (100 * index).ms)
                                    .fadeIn(duration: 250.ms)
                                    .scale(begin: const Offset(0.9, 0.9)),
                              ),
                            ),
                            const Gap(20),
                            AdherenceProgressBar(
                              percentual:
                                  relatorio?.percentualAderenciaMedio ?? 0,
                            ).animate(delay: 300.ms).fadeIn(duration: 250.ms),
                            const Gap(28),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton.icon(
                                  onPressed: () => jornadaAtiva == null
                                      ? context.push(
                                          '/area-colaborador/iniciar',
                                        )
                                      : context.push(
                                          '/area-colaborador/encerrar/${jornadaAtiva.id}',
                                        ),
                                  icon: Icon(
                                    jornadaAtiva == null
                                        ? LucideIcons.play
                                        : LucideIcons.square,
                                  ),
                                  label: Text(
                                    jornadaAtiva == null
                                        ? 'Iniciar Jornada'
                                        : 'Encerrar Jornada',
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => context.push(
                                    '/area-colaborador/historico',
                                  ),
                                  icon: const Icon(LucideIcons.history),
                                  label: const Text('Ver Histórico'),
                                ),
                              ],
                            ).animate(delay: 400.ms).fadeIn(duration: 250.ms),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DashboardAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) =>
      AppBar(title: const Text('Painel do Colaborador'));
}
