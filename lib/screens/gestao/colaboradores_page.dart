import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/colaborador.dart';
import '../../providers/colaborador_provider.dart';

class ColaboradoresPage extends StatefulWidget {
  const ColaboradoresPage({super.key});

  @override
  State<ColaboradoresPage> createState() => _ColaboradoresPageState();
}

class _ColaboradoresPageState extends State<ColaboradoresPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ColaboradorProvider>().listarAtivos();
      }
    });
  }

  Future<void> _inativar(Colaborador colaborador) async {
    final provider = context.read<ColaboradorProvider>();
    await provider.inativar(colaborador.id);

    if (!mounted) return;

    if (provider.error == null) {
      await provider.listarAtivos();
    }

    if (!mounted) return;
    _mostrarMensagem(provider.error ?? '${colaborador.nome} foi inativado.');
  }

  Future<void> _abrirFormulario() async {
    final nomeController = TextEditingController();
    final cpfController = TextEditingController();
    final cargoController = TextEditingController();
    DateTime? dataAdmissao;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Novo colaborador'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomeController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe o nome.'
                        : null,
                  ),
                  TextFormField(
                    controller: cpfController,
                    decoration: const InputDecoration(labelText: 'CPF'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe o CPF.'
                        : null,
                  ),
                  TextFormField(
                    controller: cargoController,
                    decoration: const InputDecoration(
                      labelText: 'Cargo (opcional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        final selecionada = await showDatePicker(
                          context: dialogContext,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          initialDate: dataAdmissao ?? DateTime.now(),
                        );
                        if (selecionada != null) {
                          setDialogState(() => dataAdmissao = selecionada);
                        }
                      },
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        dataAdmissao == null
                            ? 'Selecionar data de admissão'
                            : _formatarData(dataAdmissao!),
                      ),
                    ),
                  ),
                  if (dataAdmissao == null)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'A data de admissão é obrigatória.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false) ||
                    dataAdmissao == null) {
                  setDialogState(() {});
                  return;
                }

                final provider = context.read<ColaboradorProvider>();
                await provider.criar(
                  ColaboradorRequest(
                    nome: nomeController.text.trim(),
                    cpf: cpfController.text.trim(),
                    cargo: cargoController.text.trim().isEmpty
                        ? null
                        : cargoController.text.trim(),
                    dataAdmissao: dataAdmissao!,
                  ),
                );

                if (!context.mounted) return;
                if (provider.error == null) {
                  Navigator.of(dialogContext).pop();
                  _mostrarMensagem('Colaborador cadastrado com sucesso.');
                } else {
                  _mostrarMensagem(_mensagemDeErro(provider.error!));
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    nomeController.dispose();
    cpfController.dispose();
    cargoController.dispose();
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  static String _mensagemDeErro(String error) {
    if (error.toLowerCase().contains('cpf')) {
      return 'Não foi possível salvar: este CPF já está cadastrado.';
    }
    return error;
  }

  @override
  Widget build(BuildContext context) => Consumer<ColaboradorProvider>(
    builder: (context, provider, _) => Scaffold(
      appBar: AppBar(title: const Text('Colaboradores')),
      floatingActionButton: FloatingActionButton(
        onPressed: provider.isLoading ? null : _abrirFormulario,
        tooltip: 'Adicionar colaborador',
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (provider.error != null)
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.errorContainer,
                    padding: const EdgeInsets.all(16),
                    child: Text(_mensagemDeErro(provider.error!)),
                  ),
                Expanded(
                  child: provider.colaboradores.isEmpty
                      ? const Center(
                          child: Text('Nenhum colaborador ativo encontrado.'),
                        )
                      : ListView.separated(
                          itemCount: provider.colaboradores.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final colaborador = provider.colaboradores[index];
                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person_outline),
                              ),
                              title: Text(colaborador.nome),
                              subtitle: Text(
                                'CPF: ${colaborador.cpf}\nCargo: ${colaborador.cargo ?? '—'}',
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                onPressed: () => _inativar(colaborador),
                                icon: const Icon(Icons.person_off_outlined),
                                tooltip: 'Inativar colaborador',
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    ),
  );
}
