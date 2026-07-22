import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/jornada_detalhe.dart';
import '../models/jornada_resumo.dart';
import '../providers/jornada_provider.dart';
import 'atividade_card.dart';

class JornadaExpansionCard extends StatefulWidget {
  const JornadaExpansionCard({super.key, required this.jornada});

  final JornadaResumo jornada;

  @override
  State<JornadaExpansionCard> createState() => _JornadaExpansionCardState();
}

class _JornadaExpansionCardState extends State<JornadaExpansionCard>
    with SingleTickerProviderStateMixin {
  bool _expandida = false;

  Future<void> _alternar() async {
    setState(() => _expandida = !_expandida);
    if (_expandida) {
      await context.read<JornadaProvider>().carregarDetalhe(widget.jornada.id);
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<JornadaProvider>(
    builder: (context, provider, _) {
      final detalhe = provider.detalhesPorJornada[widget.jornada.id];
      final carregando = provider.detalhesCarregando.contains(
        widget.jornada.id,
      );
      final colors = Theme.of(context).colorScheme;
      final finalizada = widget.jornada.status == StatusJornada.finalizada;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.outlineVariant),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: _alternar,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (finalizada ? colors.primary : colors.tertiary)
                            .withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        finalizada
                            ? LucideIcons.checkCircle2
                            : LucideIcons.clock3,
                        color: finalizada ? colors.primary : colors.tertiary,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'dd/MM/yyyy',
                            ).format(widget.jornada.dataHoraEntrada),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${DateFormat('HH:mm').format(widget.jornada.dataHoraEntrada)} → '
                            '${widget.jornada.dataHoraSaida == null ? 'Em andamento' : DateFormat('HH:mm').format(widget.jornada.dataHoraSaida!)}'
                            '  •  ${_duracao(widget.jornada.duracaoMinutos)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expandida ? .5 : 0,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        LucideIcons.chevronDown,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: !_expandida
                  ? const SizedBox(width: double.infinity)
                  : _DetalhesJornada(detalhe: detalhe, carregando: carregando),
            ),
          ],
        ),
      );
    },
  );

  String _duracao(int? minutos) {
    if (minutos == null) return 'Em andamento';
    final horas = minutos ~/ 60;
    final restante = minutos % 60;
    if (horas == 0) return '$restante min';
    return restante == 0 ? '${horas}h' : '${horas}h ${restante}min';
  }
}

class _DetalhesJornada extends StatelessWidget {
  const _DetalhesJornada({required this.detalhe, required this.carregando});

  final JornadaDetalhe? detalhe;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (carregando) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(18, 0, 18, 22),
        child: LinearProgressIndicator(),
      );
    }
    if (detalhe == null) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(18, 0, 18, 22),
        child: Text('Não foi possível carregar os detalhes desta jornada.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: colors.outlineVariant),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Metrica(
                  label: 'Duração',
                  value: _formatarDuracao(detalhe!.duracaoMinutos),
                ),
              ),
              Expanded(
                child: _Metrica(
                  label: 'Aderência',
                  value: '${detalhe!.percentualAderencia ?? 0}%',
                ),
              ),
              Expanded(
                child: _Metrica(
                  label: 'Atividades',
                  value: '${detalhe!.atividades.length}',
                ),
              ),
            ],
          ),
          if (detalhe!.resumoAtividades?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            Text(
              detalhe!.resumoAtividades!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            'Atividades da jornada',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (detalhe!.atividades.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('Nenhuma atividade registrada.'),
            )
          else
            for (final atividade in detalhe!.atividades)
              AtividadeCard(
                atividade: atividade,
                mostrarColaborador: false,
                mostrarJornada: false,
                compacto: true,
              ),
        ],
      ),
    );
  }

  String _formatarDuracao(int? minutos) {
    if (minutos == null) return '—';
    final horas = minutos ~/ 60;
    final restante = minutos % 60;
    return horas == 0 ? '$restante min' : '${horas}h ${restante}min';
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    ],
  );
}
