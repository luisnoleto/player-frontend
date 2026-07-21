import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/jornada_resumo.dart';

class JornadaListTile extends StatelessWidget {
  const JornadaListTile({
    super.key,
    required this.jornada,
    this.mostrarColaborador = true,
  });

  final JornadaResumo jornada;
  final bool mostrarColaborador;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final encerrada = jornada.dataHoraSaida != null;
    final aderencia = jornada.percentualAderencia ?? 0;
    final corAderencia = _corAderencia(aderencia, colors);

    return Card(
      margin: const EdgeInsets.only(top: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              encerrada ? LucideIcons.checkCircle2 : LucideIcons.clock3,
              color: encerrada ? colors.primary : colors.tertiary,
              size: 26,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mostrarColaborador) ...[
                    Text(
                      jornada.colaboradorNome,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatarData(jornada.dataHoraEntrada),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ] else
                    Text(
                      _formatarData(jornada.dataHoraEntrada),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(LucideIcons.clock3, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "${_hora(jornada.dataHoraEntrada)} → ${encerrada ? _hora(jornada.dataHoraSaida!) : "Em andamento"}",
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(LucideIcons.timer, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _duracao(jornada.duracaoMinutos ?? 0),
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message:
                      'Percentual de conclusão das atividades planejadas para a jornada.',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Aderência',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        LucideIcons.info,
                        size: 14,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: corAderencia.withOpacity(.12),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          value: aderencia / 100,
                          strokeWidth: 5,
                          color: corAderencia,
                          backgroundColor: corAderencia.withOpacity(.15),
                        ),
                      ),
                      Text(
                        "$aderencia%",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _corAderencia(double valor, ColorScheme colors) {
    if (valor >= 90) return Colors.green;
    if (valor >= 70) return Colors.blue;
    if (valor >= 50) return Colors.orange;
    return colors.error;
  }

  String _hora(DateTime data) => DateFormat('HH:mm').format(data);

  String _formatarData(DateTime data) {
    final hoje = DateTime.now();

    if (data.year == hoje.year &&
        data.month == hoje.month &&
        data.day == hoje.day) {
      return "Hoje";
    }

    final ontem = hoje.subtract(const Duration(days: 1));

    if (data.year == ontem.year &&
        data.month == ontem.month &&
        data.day == ontem.day) {
      return "Ontem";
    }

    return DateFormat('dd/MM/yyyy').format(data);
  }

  String _duracao(int minutos) {
    if (minutos <= 0) return "< 1 min";

    final horas = minutos ~/ 60;
    final mins = minutos % 60;

    if (horas == 0) return "$mins min";
    if (mins == 0) return "${horas}h";
    return "${horas}h ${mins}min";
  }
}
