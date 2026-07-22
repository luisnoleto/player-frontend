import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../models/colaborador.dart';
import '../../models/horas_trabalhadas_equipe.dart';
import '../../providers/colaborador_provider.dart';
import '../../providers/relatorio_provider.dart';
import '../../widgets/adherence_progress_bar.dart';
import '../../widgets/stat_card.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  late DateTime _inicio;
  late DateTime _fim;
  int? _colaboradorId;

  @override
  void initState() {
    super.initState();
    final hoje = DateUtils.dateOnly(DateTime.now());
    _fim = hoje;
    _inicio = hoje.subtract(const Duration(days: 29));
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarInicial());
  }

  Future<void> _carregarInicial() async {
    await Future.wait([
      context.read<ColaboradorProvider>().listarAtivos(),
      _gerarRelatorio(),
    ]);
  }

  Future<void> _selecionarData({required bool inicio}) async {
    final selecionada = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: inicio ? _inicio : _fim,
    );
    if (selecionada == null) return;
    setState(() {
      if (inicio) {
        _inicio = selecionada;
        if (_inicio.isAfter(_fim)) _fim = selecionada;
      } else {
        _fim = selecionada;
        if (_fim.isBefore(_inicio)) _inicio = selecionada;
      }
    });
  }

  void _aplicarPeriodoRapido(int dias) {
    setState(() {
      _fim = DateUtils.dateOnly(DateTime.now());
      _inicio = _fim.subtract(Duration(days: dias - 1));
    });
  }

  Future<void> _gerarRelatorio() async {
    final provider = context.read<RelatorioProvider>();
    await provider.carregarPaginaRelatorios(
      colaboradorId: _colaboradorId,
      inicio: _inicio,
      fim: _fim,
    );
    if (mounted && provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => Consumer2<RelatorioProvider, ColaboradorProvider>(
    builder: (context, relatorioProvider, colaboradorProvider, _) {
      final carregando =
          relatorioProvider.isLoading || colaboradorProvider.isLoading;
      final relatorio = relatorioProvider.relatorio;
      final horasEquipe = relatorioProvider.horasEquipe;
      final colaboradorSelecionado = _buscarColaborador(
        colaboradorProvider.colaboradores,
      );

      return Scaffold(
        appBar: AppBar(title: const Text('Relatórios')),
        body: RefreshIndicator(
          onRefresh: _carregarInicial,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _FiltrosCard(
                inicio: _inicio,
                fim: _fim,
                colaboradorId: _colaboradorId,
                colaboradores: colaboradorProvider.colaboradores,
                carregando: carregando,
                onSelecionarInicio: () => _selecionarData(inicio: true),
                onSelecionarFim: () => _selecionarData(inicio: false),
                onSelecionarColaborador: (id) =>
                    setState(() => _colaboradorId = id),
                onPeriodoRapido: _aplicarPeriodoRapido,
                onGerar: _gerarRelatorio,
              ),
              if (carregando && relatorio == null) ...[
                const SizedBox(height: 48),
                const Center(child: CircularProgressIndicator()),
              ] else if (relatorio != null) ...[
                const SizedBox(height: 26),
                _TituloSecao(
                  titulo: colaboradorSelecionado == null
                      ? 'Consolidado da equipe'
                      : colaboradorSelecionado.nome,
                  subtitulo:
                      '${_formatarData(_inicio)} a ${_formatarData(_fim)}',
                ),
                const SizedBox(height: 12),
                StatCard(
                  label: 'Horas trabalhadas no período',
                  value:
                      '${relatorio.totalHorasTrabalhadas.toStringAsFixed(1)} h',
                  icon: LucideIcons.clock3,
                  tooltip:
                      'Soma da duração das jornadas finalizadas no período selecionado.',
                ),
                const SizedBox(height: 12),
                _MetricasAtividades(
                  planejadas: relatorio.quantidadeAtividadesPlanejadas,
                  concluidas: relatorio.quantidadeAtividadesConcluidas,
                  naoPlanejadas: relatorio.quantidadeAtividadesNaoPlanejadas,
                ),
                const SizedBox(height: 20),
                AdherenceProgressBar(
                  percentual: relatorio.percentualAderenciaMedio,
                ),
                const SizedBox(height: 30),
                _TituloSecao(
                  titulo: 'Horas por colaborador',
                  subtitulo: 'Janela móvel dos últimos 30 dias',
                  tooltip:
                      'Esta seção sempre considera os últimos 30 dias e somente jornadas finalizadas.',
                ),
                const SizedBox(height: 12),
                if (horasEquipe != null)
                  _ResumoHorasEquipe(
                    equipe: horasEquipe,
                    onVerTodos: () => context.push('/gestao/horas-trabalhadas'),
                  ),
                const SizedBox(height: 30),
                const _TituloSecao(
                  titulo: 'Consultas relacionadas',
                  subtitulo: 'Acesse os registros que compõem os indicadores',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/gestao/atividades/planejadas'),
                      icon: const Icon(LucideIcons.listTodo),
                      label: const Text('Pendências atuais'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/gestao/atividades/concluidas'),
                      icon: const Icon(LucideIcons.circleCheckBig),
                      label: const Text('Atividades concluídas'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/gestao/jornadas'),
                      icon: const Icon(LucideIcons.calendarSearch),
                      label: const Text('Consultar jornadas'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    },
  );

  Colaborador? _buscarColaborador(List<Colaborador> colaboradores) {
    if (_colaboradorId == null) return null;
    for (final colaborador in colaboradores) {
      if (colaborador.id == _colaboradorId) return colaborador;
    }
    return null;
  }

  static String _formatarData(DateTime data) =>
      DateFormat('dd/MM/yyyy').format(data);
}

class _FiltrosCard extends StatelessWidget {
  const _FiltrosCard({
    required this.inicio,
    required this.fim,
    required this.colaboradorId,
    required this.colaboradores,
    required this.carregando,
    required this.onSelecionarInicio,
    required this.onSelecionarFim,
    required this.onSelecionarColaborador,
    required this.onPeriodoRapido,
    required this.onGerar,
  });

  final DateTime inicio;
  final DateTime fim;
  final int? colaboradorId;
  final List<Colaborador> colaboradores;
  final bool carregando;
  final VoidCallback onSelecionarInicio;
  final VoidCallback onSelecionarFim;
  final ValueChanged<int?> onSelecionarColaborador;
  final ValueChanged<int> onPeriodoRapido;
  final VoidCallback onGerar;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filtros do relatório',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int?>(
            key: ValueKey(colaboradorId),
            initialValue: colaboradorId,
            decoration: const InputDecoration(
              labelText: 'Colaborador',
              prefixIcon: Icon(LucideIcons.userRound),
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Todos os colaboradores'),
              ),
              for (final colaborador in colaboradores)
                DropdownMenuItem<int?>(
                  value: colaborador.id,
                  child: Text(
                    colaborador.nome,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: carregando ? null : onSelecionarColaborador,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: carregando ? null : onSelecionarInicio,
                  icon: const Icon(LucideIcons.calendarDays, size: 18),
                  label: Text(DateFormat('dd/MM/yyyy').format(inicio)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: carregando ? null : onSelecionarFim,
                  icon: const Icon(LucideIcons.calendarCheck, size: 18),
                  label: Text(DateFormat('dd/MM/yyyy').format(fim)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final dias in [7, 30, 90])
                ActionChip(
                  label: Text('$dias dias'),
                  onPressed: carregando ? null : () => onPeriodoRapido(dias),
                ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: carregando ? null : onGerar,
            icon: const Icon(LucideIcons.chartNoAxesCombined),
            label: const Text('Atualizar relatório'),
          ),
          if (carregando) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    ),
  );
}

class _MetricasAtividades extends StatelessWidget {
  const _MetricasAtividades({
    required this.planejadas,
    required this.concluidas,
    required this.naoPlanejadas,
  });

  final int planejadas;
  final int concluidas;
  final int naoPlanejadas;

  @override
  Widget build(BuildContext context) {
    final pendentes = math.max(planejadas - concluidas, 0);
    final totalConcluidas = concluidas + naoPlanejadas;
    return LayoutBuilder(
      builder: (context, constraints) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: constraints.maxWidth >= 700 ? 4 : 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: constraints.maxWidth < 400 ? 1.25 : 1.55,
        children: [
          StatCard(
            label: 'Planejadas no período',
            value: '$planejadas',
            icon: LucideIcons.clipboardList,
          ),
          StatCard(
            label: 'Concluídas',
            value: '$totalConcluidas',
            icon: LucideIcons.circleCheckBig,
            tooltip: '$concluidas planejadas e $naoPlanejadas não planejadas.',
          ),
          StatCard(
            label: 'Pendentes do período',
            value: '$pendentes',
            icon: LucideIcons.clockAlert,
            tooltip:
                'Atividades planejadas no período que ainda não foram concluídas.',
          ),
          StatCard(
            label: 'Não planejadas',
            value: '$naoPlanejadas',
            icon: LucideIcons.listPlus,
          ),
        ],
      ),
    );
  }
}

class _ResumoHorasEquipe extends StatelessWidget {
  const _ResumoHorasEquipe({required this.equipe, required this.onVerTodos});

  final HorasTrabalhadasEquipe equipe;
  final VoidCallback onVerTodos;

  @override
  Widget build(BuildContext context) {
    final destaques = equipe.colaboradores.take(5).toList();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Total da equipe',
                value: '${equipe.totalHoras.toStringAsFixed(1)} h',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Média individual',
                value: '${equipe.mediaHoras.toStringAsFixed(1)} h',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (destaques.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Nenhum colaborador ativo encontrado.'),
          )
        else
          for (var index = 0; index < destaques.length; index++)
            _HoraColaboradorTile(
              posicao: index + 1,
              colaborador: destaques[index],
            ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onVerTodos,
            icon: const Icon(LucideIcons.arrowRight, size: 18),
            label: const Text('Ver todos os colaboradores'),
          ),
        ),
      ],
    );
  }
}

class _HoraColaboradorTile extends StatelessWidget {
  const _HoraColaboradorTile({
    required this.posicao,
    required this.colaborador,
  });

  final int posicao;
  final HorasTrabalhadasColaborador colaborador;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: CircleAvatar(radius: 18, child: Text('$posicao')),
      title: Text(colaborador.colaboradorNome),
      trailing: Text(
        '${colaborador.totalHoras.toStringAsFixed(1)} h',
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class _TituloSecao extends StatelessWidget {
  const _TituloSecao({
    required this.titulo,
    required this.subtitulo,
    this.tooltip,
  });

  final String titulo;
  final String subtitulo;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 3),
            Text(
              subtitulo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      if (tooltip != null)
        Tooltip(message: tooltip!, child: const Icon(Icons.info_outline)),
    ],
  );
}
