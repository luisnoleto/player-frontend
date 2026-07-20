import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/session_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Sistema de Registro de Ponto'),
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
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth >= 440;
            final cards = [
              _AreaCard(
                label: 'Área do Colaborador',
                icon: LucideIcons.userRound,
                onTap: () => context.push('/area-colaborador'),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
              _AreaCard(
                    label: 'Área de Gestão',
                    icon: LucideIcons.layoutDashboard,
                    onTap: () => context.push('/gestao'),
                  )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 300.ms)
                  .slideY(begin: 0.05),
            ];

            return Padding(
              padding: const EdgeInsets.all(24),
              child: horizontal
                  ? Row(
                      children: [
                        Expanded(
                          child: AspectRatio(aspectRatio: 1, child: cards[0]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AspectRatio(aspectRatio: 1, child: cards[1]),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: cards[0],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: cards[1],
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    ),
  );
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: colors.primary),
              const SizedBox(height: 20),
              Text(label, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Acessar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
