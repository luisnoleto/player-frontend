import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AdherenceProgressBar extends StatelessWidget {
  const AdherenceProgressBar({super.key, required this.percentual});

  final double percentual;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final valor = percentual.clamp(0, 100).toDouble();
    final cor = switch (valor) {
      < 50 => colors.error,
      < 80 => colors.tertiary,
      _ => colors.primary,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Tooltip(
              message:
                  'Média simples do percentual de conclusão das atividades planejadas para as jornadas dos colaboradores.',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Aderência',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.info,
                    size: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(8),
        LinearProgressIndicator(
          value: valor / 100,
          color: cor,
          backgroundColor: colors.surfaceContainerHighest,
          minHeight: 8,
          borderRadius: BorderRadius.circular(99),
        ),
      ],
    );
  }
}
