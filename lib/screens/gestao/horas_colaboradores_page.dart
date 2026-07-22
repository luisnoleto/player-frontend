import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../models/horas_trabalhadas_equipe.dart';
import '../../providers/relatorio_provider.dart';
import '../../widgets/stat_card.dart';

class HorasColaboradoresPage extends StatefulWidget {
  const HorasColaboradoresPage({super.key});

  @override
  State<HorasColaboradoresPage> createState() => _HorasColaboradoresPageState();
}

class _HorasColaboradoresPageState extends State<HorasColaboradoresPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    final provider = context.read<RelatorioProvider>();
    await provider.listarHorasPorColaborador();
    if (mounted && provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<RelatorioProvider>(
    builder: (context, provider, _) {
      final equipe = provider.horasEquipe;
      return Scaffold(
        appBar: AppBar(title: const Text('Horas por colaborador')),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : equipe == null
            ? const Center(child: Text('Não foi possível carregar as horas.'))
            : RefreshIndicator(
                onRefresh: _carregar,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _PeriodoCard(equipe: equipe),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final total = StatCard(
                          label: 'Total da equipe',
                          value: '${equipe.totalHoras.toStringAsFixed(1)} h',
                          icon: LucideIcons.clock3,
                        );
                        final media = StatCard(
                          label: 'Média por colaborador',
                          value: '${equipe.mediaHoras.toStringAsFixed(1)} h',
                          icon: LucideIcons.chartNoAxesColumnIncreasing,
                        );
                        if (constraints.maxWidth < 430) {
                          return Column(
                            children: [
                              total,
                              const SizedBox(height: 10),
                              media,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: total),
                            const SizedBox(width: 12),
                            Expanded(child: media),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Colaboradores',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    if (equipe.colaboradores.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('Nenhum colaborador ativo encontrado.'),
                      )
                    else
                      for (
                        var index = 0;
                        index < equipe.colaboradores.length;
                        index++
                      )
                        _HorasColaboradorCard(
                          posicao: index + 1,
                          colaborador: equipe.colaboradores[index],
                          maiorTotal: equipe.colaboradores.first.totalHoras,
                        ),
                  ],
                ),
              ),
      );
    },
  );
}

class _PeriodoCard extends StatelessWidget {
  const _PeriodoCard({required this.equipe});

  final HorasTrabalhadasEquipe equipe;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.calendarRange, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Últimos 30 dias • ${DateFormat('dd/MM/yyyy').format(equipe.periodoInicio)} a '
              '${DateFormat('dd/MM/yyyy').format(equipe.periodoFim)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const Tooltip(
            message:
                'Considera somente jornadas finalizadas dentro dos últimos 30 dias.',
            child: Icon(Icons.info_outline, size: 19),
          ),
        ],
      ),
    );
  }
}

class _HorasColaboradorCard extends StatelessWidget {
  const _HorasColaboradorCard({
    required this.posicao,
    required this.colaborador,
    required this.maiorTotal,
  });

  final int posicao;
  final HorasTrabalhadasColaborador colaborador;
  final double maiorTotal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progresso = maiorTotal <= 0
        ? 0.0
        : colaborador.totalHoras / maiorTotal;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colors.primaryContainer,
              child: Text(
                '$posicao',
                style: TextStyle(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    colaborador.colaboradorNome,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progresso,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(999),
                    backgroundColor: colors.surfaceContainerHighest,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${colaborador.totalHoras.toStringAsFixed(1)} h',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
