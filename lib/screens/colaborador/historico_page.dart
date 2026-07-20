import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/session_provider.dart';
import '../../providers/jornada_provider.dart';
import '../../widgets/jornada_list_tile.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarHistorico());
  }

  Future<void> _carregarHistorico() async {
    final colaborador = context.read<SessionProvider>().colaboradorAtual;
    if (colaborador == null) {
      context.replace('/area-colaborador');
      return;
    }

    final provider = context.read<JornadaProvider>();
    await provider.buscarHistorico(colaborador.id);
    if (mounted && provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<JornadaProvider>(
    builder: (context, provider, _) => Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.historico.isEmpty
          ? const Center(child: Text('Nenhuma jornada encontrada.'))
          : RefreshIndicator(
              onRefresh: _carregarHistorico,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: provider.historico.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) => JornadaListTile(
                  jornada: provider.historico[index],
                  mostrarColaborador: false,
                ),
              ),
            ),
    ),
  );
}
