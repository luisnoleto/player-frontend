import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/atividade.dart';

class AtividadeCard extends StatelessWidget {
  const AtividadeCard({
    super.key,
    required this.atividade,
    this.mostrarColaborador = true,
    this.compacto = false,
    this.mostrarJornada = true,
  });

  final Atividade atividade;
  final bool mostrarColaborador;
  final bool compacto;
  final bool mostrarJornada;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final concluida = atividade.status == StatusAtividade.concluida;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(compacto ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: (concluida ? colors.primary : colors.tertiary)
                        .withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    concluida
                        ? LucideIcons.circleCheckBig
                        : LucideIcons.listTodo,
                    color: concluida ? colors.primary : colors.tertiary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        atividade.descricao,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (mostrarColaborador) ...[
                        const SizedBox(height: 4),
                        Text(
                          atividade.colaboradorNome,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(
                  label: _statusLabel(atividade.status),
                  color: concluida ? colors.primary : colors.tertiary,
                ),
                if (atividade.tipo == TipoAtividade.naoPlanejada)
                  _Tag(label: 'Não planejada', color: colors.secondary),
                if (atividade.tipo == TipoAtividade.planejada)
                  _Tag(label: 'Planejada', color: colors.outline),
              ],
            ),
            if (mostrarJornada) ...[
              const SizedBox(height: 14),
              _InfoLine(
                icon: LucideIcons.calendarDays,
                text:
                    'Jornada de ${DateFormat('dd/MM/yyyy').format(atividade.jornadaEntrada)}',
              ),
              const SizedBox(height: 6),
              _InfoLine(
                icon: LucideIcons.clock3,
                text:
                    '${DateFormat('HH:mm').format(atividade.jornadaEntrada)} → '
                    '${atividade.jornadaSaida == null ? 'Em andamento' : DateFormat('HH:mm').format(atividade.jornadaSaida!)}',
              ),
            ],
            if (atividade.dataConclusao != null) ...[
              const SizedBox(height: 6),
              _InfoLine(
                icon: LucideIcons.check,
                text:
                    'Concluída em ${DateFormat('dd/MM/yyyy • HH:mm').format(atividade.dataConclusao!)}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(StatusAtividade status) => switch (status) {
    StatusAtividade.pendente => 'Pendente',
    StatusAtividade.emAndamento => 'Em andamento',
    StatusAtividade.concluida => 'Concluída',
  };
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withValues(alpha: .25)),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
