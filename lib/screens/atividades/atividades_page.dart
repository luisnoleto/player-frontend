import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/session_provider.dart';
import '../../providers/atividade_provider.dart';
import '../../widgets/atividade_card.dart';

class AtividadesPage extends StatefulWidget {
  const AtividadesPage({
    super.key,
    required this.concluidas,
    required this.mostrarColaborador,
  });

  final bool concluidas;
  final bool mostrarColaborador;

  @override
  State<AtividadesPage> createState() => _AtividadesPageState();
}

class _AtividadesPageState extends State<AtividadesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    final provider = context.read<AtividadeProvider>();
    if (widget.mostrarColaborador) {
      await provider.listarTodas();
    } else {
      final colaborador = context.read<SessionProvider>().colaboradorAtual;
      if (colaborador == null) {
        if (mounted) context.replace('/area-colaborador');
        return;
      }
      await provider.listarPorColaborador(colaborador.id);
    }

    if (mounted && provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<AtividadeProvider>(
    builder: (context, provider, _) {
      final atividades = widget.concluidas
          ? provider.concluidas
          : provider.planejadas;
      final titulo = widget.concluidas
          ? 'Atividades concluídas'
          : 'Atividades planejadas';

      return Scaffold(
        appBar: AppBar(title: Text(titulo)),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : atividades.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    widget.concluidas
                        ? 'Nenhuma atividade concluída encontrada.'
                        : 'Nenhuma atividade planejada pendente.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _carregar,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: atividades.length,
                  itemBuilder: (context, index) => AtividadeCard(
                    atividade: atividades[index],
                    mostrarColaborador: widget.mostrarColaborador,
                  ),
                ),
              ),
      );
    },
  );
}
