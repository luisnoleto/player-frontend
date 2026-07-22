import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/session_provider.dart';
import '../../models/jornada_detalhe.dart';
import '../../providers/jornada_provider.dart';

class IniciarJornadaPage extends StatefulWidget {
  const IniciarJornadaPage({super.key});

  @override
  State<IniciarJornadaPage> createState() => _IniciarJornadaPageState();
}

class _IniciarJornadaPageState extends State<IniciarJornadaPage> {
  final List<TextEditingController> _atividadeControllers = [
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          !context.read<SessionProvider>().temColaboradorSelecionado) {
        context.replace('/area-colaborador');
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _atividadeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _adicionarAtividade() {
    setState(() => _atividadeControllers.add(TextEditingController()));
  }

  void _removerAtividade(int index) {
    final controller = _atividadeControllers.removeAt(index);
    controller.dispose();
    setState(() {});
  }

  Future<void> _iniciar() async {
    final colaboradorId = context.read<SessionProvider>().colaboradorIdAtual;
    if (colaboradorId == null) {
      context.replace('/area-colaborador');
      return;
    }

    final provider = context.read<JornadaProvider>();
    final atividades = _atividadeControllers
        .map((controller) => controller.text.trim())
        .where((descricao) => descricao.isNotEmpty)
        .toList();
    await provider.iniciar(
      IniciarJornadaRequest(
        colaboradorId: colaboradorId,
        atividadesPlanejadas: atividades,
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
    builder: (context, provider, _) => Scaffold(
      appBar: AppBar(title: const Text('Iniciar Jornada')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Atividades planejadas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (
                  var index = 0;
                  index < _atividadeControllers.length;
                  index++
                )
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _atividadeControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Atividade ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removerAtividade(index),
                          icon: const Icon(Icons.remove_circle_outline),
                          tooltip: 'Remover atividade',
                        ),
                      ],
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _adicionarAtividade,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar atividade'),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _atividadeControllers.isEmpty ? null : _iniciar,
                  child: const Text('Iniciar Jornada'),
                ),
              ],
            ),
    ),
  );
}
