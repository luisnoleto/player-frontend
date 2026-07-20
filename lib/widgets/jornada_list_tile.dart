import 'package:flutter/material.dart';
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
    final encerrada = jornada.dataHoraSaida != null;
    final horarioSaida = encerrada
        ? _formatarHora(jornada.dataHoraSaida!)
        : 'em andamento';

    return ListTile(
      leading: Icon(
        encerrada ? LucideIcons.checkCircle : LucideIcons.clock,
        color: encerrada ? colors.primary : colors.tertiary,
      ),
      title: mostrarColaborador ? Text(jornada.colaboradorNome) : null,
      subtitle: Row(
        children: [
          const Icon(LucideIcons.clock, size: 16),
          const SizedBox(width: 6),
          Text('${_formatarHora(jornada.dataHoraEntrada)} → $horarioSaida'),
        ],
      ),
      trailing: jornada.percentualAderencia == null
          ? null
          : Chip(
              visualDensity: VisualDensity.compact,
              label: Text('${jornada.percentualAderencia!.round()}%'),
            ),
    );
  }

  static String _formatarHora(DateTime dataHora) {
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }
}
