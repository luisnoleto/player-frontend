import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../models/conteudo_portal.dart';
import '../../providers/conteudo_portal_provider.dart';

class RpaConteudosPage extends StatefulWidget {
  const RpaConteudosPage({super.key});

  @override
  State<RpaConteudosPage> createState() => _RpaConteudosPageState();
}

class _RpaConteudosPageState extends State<RpaConteudosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    if (!mounted) return;
    final provider = context.read<ConteudoPortalProvider>();
    await provider.listar();
    if (mounted && provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<ConteudoPortalProvider>(
    builder: (context, provider, _) => Scaffold(
      appBar: AppBar(title: const Text('Conteúdo do Portal Ponto Ágil')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ConteudosPortalList(
              conteudos: provider.conteudos,
              onRefresh: _carregar,
            ),
    ),
  );
}

class _ConteudosPortalList extends StatelessWidget {
  const _ConteudosPortalList({
    required this.conteudos,
    required this.onRefresh,
  });

  final List<ConteudoPortal> conteudos;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (conteudos.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Icon(LucideIcons.bot, size: 48),
            SizedBox(height: 12),
            Center(
              child: Text('Execute o RPA para importar os dados do portal.'),
            ),
          ],
        ),
      );
    }

    final ultimaColeta = conteudos
        .map((item) => item.coletadoEm)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    const categorias = ['PLANO', 'RECURSO', 'BENEFICIO', 'CONTATO'];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(LucideIcons.circleCheckBig),
              title: Text('${conteudos.length} itens importados'),
              subtitle: Text(
                'Última coleta: ${_formatarDataHora(ultimaColeta)}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final categoria in categorias) ...[
            _TituloCategoria(
              categoria: categoria,
              quantidade: conteudos
                  .where((item) => item.categoria == categoria)
                  .length,
            ),
            const SizedBox(height: 8),
            for (final item in conteudos.where(
              (item) => item.categoria == categoria,
            ))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ConteudoCard(item: item),
              ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _TituloCategoria extends StatelessWidget {
  const _TituloCategoria({required this.categoria, required this.quantidade});

  final String categoria;
  final int quantidade;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(_iconeCategoria(categoria), size: 20),
      const SizedBox(width: 8),
      Text(
        _rotuloCategoria(categoria),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(width: 8),
      Chip(label: Text('$quantidade')),
    ],
  );
}

class _ConteudoCard extends StatelessWidget {
  const _ConteudoCard({required this.item});

  final ConteudoPortal item;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconeCategoria(item.categoria)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.titulo,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (item.valor != null)
                Chip(
                  avatar: const Icon(LucideIcons.badgeDollarSign, size: 16),
                  label: Text(item.valor!),
                ),
            ],
          ),
          if (item.descricao != null) ...[
            const SizedBox(height: 10),
            Text(item.descricao!),
          ],
          if (item.link != null) ...[
            const SizedBox(height: 10),
            Text(
              item.link!,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ],
      ),
    ),
  );
}

IconData _iconeCategoria(String categoria) => switch (categoria) {
  'PLANO' => LucideIcons.badgeDollarSign,
  'RECURSO' => LucideIcons.sparkles,
  'BENEFICIO' => LucideIcons.circleCheckBig,
  _ => LucideIcons.contact,
};

String _rotuloCategoria(String categoria) => switch (categoria) {
  'PLANO' => 'Planos',
  'RECURSO' => 'Recursos',
  'BENEFICIO' => 'Benefícios',
  _ => 'Contatos',
};

String _formatarDataHora(DateTime dataHora) {
  final dia = dataHora.day.toString().padLeft(2, '0');
  final mes = dataHora.month.toString().padLeft(2, '0');
  final hora = dataHora.hour.toString().padLeft(2, '0');
  final minuto = dataHora.minute.toString().padLeft(2, '0');
  return '$dia/$mes/${dataHora.year} $hora:$minuto';
}
