import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
            Text('Aderência', style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            Text(
              '${valor.round()}%',
              style: Theme.of(context).textTheme.labelLarge,
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
