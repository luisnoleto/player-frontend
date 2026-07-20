import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/session_provider.dart';
import '../../models/jornada_detalhe.dart';
import '../../providers/jornada_provider.dart';

class EncerrarJornadaPage extends StatefulWidget {
  const EncerrarJornadaPage({super.key, required this.jornadaId});

  final int jornadaId;

  @override
  State<EncerrarJornadaPage> createState() => _EncerrarJornadaPageState();
}

class _EncerrarJornadaPageState extends State<EncerrarJornadaPage> {
  final Set<int> _atividadesConcluidasIds = {};
  final List<TextEditingController> _naoPlanejadasControllers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarJornada());
  }

  Future<void> _carregarJornada() async {
    if (!context.read<SessionProvider>().temColaboradorSelecionado) {
      context.replace('/area-colaborador');
      return;
    }

    final provider = context.read<JornadaProvider>();
    await provider.buscarDetalhe(widget.jornadaId);
    if (!mounted) return;

    if (provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
      return;
    }

    setState(() {
      _atividadesConcluidasIds
        ..clear()
        ..addAll(
          provider.jornadaDetalhe!.atividadesPlanejadas
              .where((atividade) => atividade.concluida)
              .map((atividade) => atividade.id),
        );
    });
  }

  @override
  void dispose() {
    for (final controller in _naoPlanejadasControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _adicionarAtividadeNaoPlanejada() {
    setState(() => _naoPlanejadasControllers.add(TextEditingController()));
  }

  void _removerAtividadeNaoPlanejada(int index) {
    final controller = _naoPlanejadasControllers.removeAt(index);
    controller.dispose();
    setState(() {});
  }

  Future<void> _encerrar() async {
    final provider = context.read<JornadaProvider>();
    final atividadesNaoPlanejadas = _naoPlanejadasControllers
        .map((controller) => controller.text.trim())
        .where((descricao) => descricao.isNotEmpty)
        .toList();

    await provider.encerrar(
      widget.jornadaId,
      EncerrarJornadaRequest(
        atividadesConcluidasIds: _atividadesConcluidasIds.toList(),
        atividadesNaoPlanejadas: atividadesNaoPlanejadas,
      ),
    );

    if (!mounted) return;
    if (provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) => Consumer<JornadaProvider>(
    builder: (context, provider, _) {
      if (provider.isLoading) {
        return Scaffold(
          appBar: AppBar(title: const Text('Encerrar Jornada')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      final jornada = provider.jornadaDetalhe;
      if (jornada == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Encerrar Jornada')),
          body: const Center(child: Text('Jornada não encontrada.')),
        );
      }

      return Scaffold(
        appBar: AppBar(title: const Text('Encerrar Jornada')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Atividades planejadas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final atividade in jornada.atividadesPlanejadas)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _atividadesConcluidasIds.contains(atividade.id),
                onChanged: (marcada) {
                  setState(() {
                    if (marcada ?? false) {
                      _atividadesConcluidasIds.add(atividade.id);
                    } else {
                      _atividadesConcluidasIds.remove(atividade.id);
                    }
                  });
                },
                title: Text(atividade.descricao),
              ),
            const SizedBox(height: 16),
            Text(
              'Atividades não planejadas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (
              var index = 0;
              index < _naoPlanejadasControllers.length;
              index++
            )
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _naoPlanejadasControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Atividade ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removerAtividadeNaoPlanejada(index),
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: 'Remover atividade',
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _adicionarAtividadeNaoPlanejada,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar atividade'),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _encerrar,
              child: const Text('Encerrar Jornada'),
            ),
          ],
        ),
      );
    },
  );
}
