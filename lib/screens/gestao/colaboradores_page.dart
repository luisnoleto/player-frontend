import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/colaborador.dart';
import '../../providers/colaborador_provider.dart';

class ColaboradoresPage extends StatefulWidget {
  const ColaboradoresPage({super.key});

  @override
  State<ColaboradoresPage> createState() => _ColaboradoresPageState();
}

class _ColaboradoresPageState extends State<ColaboradoresPage> {
  bool _mostrarTodos = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _carregarColaboradores();
      }
    });
  }

  Future<void> _carregarColaboradores() async {
    final provider = context.read<ColaboradorProvider>();
    if (_mostrarTodos) {
      await provider.listarTodos();
    } else {
      await provider.listarAtivos();
    }

    if (!mounted) return;
    if (provider.error != null) {
      _mostrarMensagem(_mensagemDeErro(provider.error!));
    }
  }

  Future<bool> _confirmarAcao({
    required String titulo,
    required String mensagem,
    required String botaoConfirmar,
    required Color corConfirmar,
  }) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: corConfirmar),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(botaoConfirmar),
          ),
        ],
      ),
    );

    return confirmado ?? false;
  }

  Future<void> _inativar(Colaborador colaborador) async {
    final confirmado = await _confirmarAcao(
      titulo: 'Inativar colaborador',
      mensagem: 'Deseja inativar ${colaborador.nome}?',
      botaoConfirmar: 'Inativar',
      corConfirmar: Theme.of(context).colorScheme.error,
    );
    if (!confirmado) return;

    final provider = context.read<ColaboradorProvider>();
    await provider.inativar(colaborador.id);

    if (!mounted) return;
    if (provider.error == null) {
      await _carregarColaboradores();
      _mostrarMensagem('${colaborador.nome} foi inativado.');
    } else {
      _mostrarMensagem(_mensagemDeErro(provider.error!));
    }
  }

  Future<void> _reativar(Colaborador colaborador) async {
    final confirmado = await _confirmarAcao(
      titulo: 'Reativar colaborador',
      mensagem: 'Deseja reativar ${colaborador.nome}?',
      botaoConfirmar: 'Reativar',
      corConfirmar: Theme.of(context).colorScheme.primary,
    );
    if (!confirmado) return;

    final provider = context.read<ColaboradorProvider>();
    await provider.reativar(colaborador.id);

    if (!mounted) return;
    if (provider.error == null) {
      await _carregarColaboradores();
      _mostrarMensagem('${colaborador.nome} foi reativado.');
    } else {
      _mostrarMensagem(_mensagemDeErro(provider.error!));
    }
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
          constraints: const BoxConstraints(maxWidth: 720, minWidth: 420),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cpfController,
                    decoration: const InputDecoration(labelText: 'CPF'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      const _CpfInputFormatter(),
                    ],
                    validator: (value) {
                      final cpf = _somenteDigitos(value ?? '');
                      if (cpf.length != 11) {
                        return 'Informe um CPF com 11 dígitos.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
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
                  await _carregarColaboradores();
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
    final lower = error.toLowerCase();
    if (lower.contains('cpf')) {
      return 'Não foi possível salvar: este CPF já está cadastrado.';
    }
    return error;
  }

  static String _somenteDigitos(String value) => value.replaceAll(RegExp(r'\D'), '');

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mostrar todos (inclui inativos)'),
                    value: _mostrarTodos,
                    onChanged: (value) async {
                      setState(() => _mostrarTodos = value);
                      await _carregarColaboradores();
                    },
                  ),
                ),
                if (provider.error != null)
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.errorContainer,
                    padding: const EdgeInsets.all(16),
                    child: Text(_mensagemDeErro(provider.error!)),
                  ),
                Expanded(
                  child: provider.colaboradores.isEmpty
                      ? Center(
                          child: Text(
                            _mostrarTodos
                                ? 'Nenhum colaborador encontrado.'
                                : 'Nenhum colaborador ativo encontrado.',
                          ),
                        )
                      : ListView.separated(
                          itemCount: provider.colaboradores.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final colaborador = provider.colaboradores[index];
                            final ativo = colaborador.ativo;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: ativo
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  ativo
                                      ? Icons.person_outline
                                      : Icons.person_off_outlined,
                                ),
                              ),
                              title: Text(colaborador.nome),
                              subtitle: Text(
                                'CPF: ${colaborador.cpf}\nCargo: ${colaborador.cargo ?? '—'}\nStatus: ${ativo ? 'Ativo' : 'Inativo'}',
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                onPressed: ativo
                                    ? () => _inativar(colaborador)
                                    : () => _reativar(colaborador),
                                icon: Icon(
                                  ativo
                                      ? Icons.person_off_outlined
                                      : Icons.person_add_alt_1_outlined,
                                ),
                                tooltip: ativo
                                    ? 'Inativar colaborador'
                                    : 'Reativar colaborador',
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

class _CpfInputFormatter extends TextInputFormatter {
  const _CpfInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    final formatted = _formatarCpf(limited);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _formatarCpf(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('.');
      }
      if (i == 9) {
        buffer.write('-');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
