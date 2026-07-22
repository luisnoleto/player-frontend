import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/session_provider.dart';
import '../../providers/jornada_provider.dart';
import '../../widgets/jornada_expansion_card.dart';

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
    final colaboradorId = context.read<SessionProvider>().colaboradorIdAtual;
    if (colaboradorId == null) {
      context.replace('/area-colaborador');
      return;
    }

    final provider = context.read<JornadaProvider>();
    await provider.buscarHistorico(colaboradorId);
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
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.historico.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: JornadaExpansionCard(
                    jornada: provider.historico[index],
                  ),
                ),
              ),
            ),
    ),
  );
}
