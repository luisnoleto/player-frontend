import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/session_provider.dart';
import '../../models/atividade.dart';
import '../../models/jornada_detalhe.dart';
import '../../providers/atividade_provider.dart';
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
    final colaborador = context.read<SessionProvider>().colaboradorAtual;
    if (colaborador == null) {
      context.replace('/area-colaborador');
      return;
    }

    final provider = context.read<JornadaProvider>();
    final atividadeProvider = context.read<AtividadeProvider>();
    await Future.wait([
      provider.buscarDetalhe(widget.jornadaId),
      atividadeProvider.listarPorColaborador(colaborador.id),
    ]);
    if (!mounted) return;

    final error = provider.error ?? atividadeProvider.error;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() {
      _atividadesConcluidasIds.clear();
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
  Widget build(
    BuildContext context,
  ) => Consumer2<JornadaProvider, AtividadeProvider>(
    builder: (context, provider, atividadeProvider, _) {
      if (provider.isLoading || atividadeProvider.isLoading) {
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

      final atividadesAtuais = atividadeProvider.planejadas
          .where((atividade) => atividade.jornadaId == widget.jornadaId)
          .toList();
      final atividadesAnteriores = atividadeProvider.planejadas
          .where((atividade) => atividade.jornadaId != widget.jornadaId)
          .toList();

      return Scaffold(
        appBar: AppBar(title: const Text('Encerrar Jornada')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Atividades pendentes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Selecione o que foi concluído hoje, inclusive atividades planejadas em jornadas anteriores.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (atividadesAtuais.isNotEmpty) ...[
              _tituloGrupo(context, 'Jornada atual'),
              for (final atividade in atividadesAtuais)
                _AtividadePendenteTile(
                  atividade: atividade,
                  selecionada: _atividadesConcluidasIds.contains(atividade.id),
                  onChanged: (marcada) =>
                      _alternarAtividade(atividade.id, marcada),
                ),
            ],
            if (atividadesAnteriores.isNotEmpty) ...[
              const SizedBox(height: 12),
              _tituloGrupo(context, 'Pendências anteriores'),
              for (final atividade in atividadesAnteriores)
                _AtividadePendenteTile(
                  atividade: atividade,
                  selecionada: _atividadesConcluidasIds.contains(atividade.id),
                  onChanged: (marcada) =>
                      _alternarAtividade(atividade.id, marcada),
                ),
            ],
            if (atividadeProvider.planejadas.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Nenhuma atividade planejada está pendente.'),
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

  void _alternarAtividade(int atividadeId, bool? marcada) {
    setState(() {
      if (marcada ?? false) {
        _atividadesConcluidasIds.add(atividadeId);
      } else {
        _atividadesConcluidasIds.remove(atividadeId);
      }
    });
  }

  Widget _tituloGrupo(BuildContext context, String titulo) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      titulo,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}

class _AtividadePendenteTile extends StatelessWidget {
  const _AtividadePendenteTile({
    required this.atividade,
    required this.selecionada,
    required this.onChanged,
  });

  final Atividade atividade;
  final bool selecionada;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: CheckboxListTile(
      value: selecionada,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      secondary: const Icon(LucideIcons.listTodo, size: 20),
      title: Text(atividade.descricao),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          'Jornada ${atividade.jornadaId} • '
          '${DateFormat('dd/MM/yyyy • HH:mm').format(atividade.jornadaEntrada)}',
        ),
      ),
    ),
  );
}
