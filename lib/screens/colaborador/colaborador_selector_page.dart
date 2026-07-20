// Login temporário: a identidade é selecionada apenas em memória até existir
// um fluxo de autenticação real com JWT.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/session_provider.dart';
import '../../providers/colaborador_provider.dart';

class ColaboradorSelectorPage extends StatefulWidget {
  const ColaboradorSelectorPage({super.key});

  @override
  State<ColaboradorSelectorPage> createState() =>
      _ColaboradorSelectorPageState();
}

class _ColaboradorSelectorPageState extends State<ColaboradorSelectorPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<SessionProvider>().temColaboradorSelecionado) {
        context.replace('/area-colaborador/dashboard');
        return;
      }
      _carregarColaboradores();
    });
  }

  Future<void> _carregarColaboradores() async {
    final provider = context.read<ColaboradorProvider>();
    await provider.listarAtivos();
    if (mounted && provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<ColaboradorProvider>(
    builder: (context, provider, _) => Scaffold(
      appBar: AppBar(title: const Text('Quem é você?')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: provider.colaboradores.isEmpty
                    ? const Center(
                        child: Text('Nenhum colaborador ativo encontrado.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.colaboradores.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final colaborador = provider.colaboradores[index];
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person_outline),
                              ),
                              title: Text(colaborador.nome),
                              subtitle: Text(colaborador.cargo ?? '—'),
                              onTap: () {
                                context.read<SessionProvider>().selecionar(
                                  colaborador,
                                );
                                context.push('/area-colaborador/dashboard');
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
    ),
  );
}
