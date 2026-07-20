import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/colaborador.dart';
import '../../providers/colaborador_provider.dart';
import '../../providers/jornada_provider.dart';
import '../../widgets/jornada_list_tile.dart';

class JornadasConsultaPage extends StatefulWidget {
  const JornadasConsultaPage({super.key});

  @override
  State<JornadasConsultaPage> createState() => _JornadasConsultaPageState();
}

class _JornadasConsultaPageState extends State<JornadasConsultaPage> {
  String? _status;
  int? _colaboradorId;
  DateTime? _inicio;
  DateTime? _fim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarInicial());
  }

  Future<void> _carregarInicial() async {
    if (!mounted) return;

    final colaboradores = context.read<ColaboradorProvider>();
    final jornadas = context.read<JornadaProvider>();
    await Future.wait([
      colaboradores.listarTodos(),
      jornadas.listarComFiltros(),
    ]);

    if (!mounted) return;
    final error = colaboradores.error ?? jornadas.error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _filtrar() async {
    final provider = context.read<JornadaProvider>();
    await provider.listarComFiltros(
      status: _status,
      colaboradorId: _colaboradorId,
      inicio: _inicio,
      fim: _fim,
    );
    if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
    }
  }

  Future<void> _selecionarData({required bool inicio}) async {
    final selecionada = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: (inicio ? _inicio : _fim) ?? DateTime.now(),
    );
    if (selecionada != null) {
      setState(() {
        if (inicio) {
          _inicio = selecionada;
        } else {
          _fim = selecionada;
        }
      });
    }
  }

  Future<String?> _selecionarStatus() {
    const opcoes = [
      _DialogOption<String>(
        value: 'EM_ANDAMENTO',
        title: 'Em Andamento',
        searchText: 'em andamento andamento ativo',
      ),
      _DialogOption<String>(
        value: 'FINALIZADA',
        title: 'Finalizada',
        searchText: 'finalizada encerrada concluida concluída',
      ),
    ];

    return _abrirSelecaoPesquisavel<String>(
      titulo: 'Selecionar status',
      hintPesquisa: 'Pesquisar status',
      itens: opcoes,
      labelBotaoTodos: 'Todos',
    );
  }

  Future<int?> _selecionarColaborador(List<Colaborador> colaboradores) {
    final opcoes = colaboradores
        .map(
          (colaborador) => _DialogOption<int>(
            value: colaborador.id,
            title: colaborador.nome,
            subtitle:
                'CPF: ${colaborador.cpf}${colaborador.ativo ? '' : ' • Inativo'}',
            searchText:
                '${colaborador.nome} ${colaborador.cpf} ${colaborador.ativo ? 'ativo' : 'inativo'}',
          ),
        )
        .toList();

    return _abrirSelecaoPesquisavel<int>(
      titulo: 'Selecionar colaborador',
      hintPesquisa: 'Pesquisar colaborador ou CPF',
      itens: opcoes,
      labelBotaoTodos: 'Todos',
    );
  }

  Future<T?> _abrirSelecaoPesquisavel<T>({
    required String titulo,
    required String hintPesquisa,
    required List<_DialogOption<T>> itens,
    required String labelBotaoTodos,
  }) {
    return showDialog<T>(
      context: context,
      builder: (dialogContext) => _SearchableSelectionDialog<T>(
        titulo: titulo,
        hintPesquisa: hintPesquisa,
        itens: itens,
        labelBotaoTodos: labelBotaoTodos,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) =>
      Consumer2<ColaboradorProvider, JornadaProvider>(
        builder: (context, colaboradoresProvider, jornadasProvider, _) {
          if (colaboradoresProvider.isLoading || jornadasProvider.isLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Consultar Jornadas')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Consultar Jornadas')),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _FiltrosJornada(
                    status: _status,
                    colaboradorId: _colaboradorId,
                    colaboradores: colaboradoresProvider.colaboradores,
                    inicio: _inicio,
                    fim: _fim,
                    onStatusChanged: (value) => setState(() => _status = value),
                    onColaboradorChanged: (value) =>
                        setState(() => _colaboradorId = value),
                    onAbrirStatus: () async {
                      final selecionado = await _selecionarStatus();
                      if (!mounted) return;
                      setState(() => _status = selecionado);
                    },
                    onAbrirColaborador: () async {
                      final selecionado = await _selecionarColaborador(
                        colaboradoresProvider.colaboradores,
                      );
                      if (!mounted) return;
                      setState(() => _colaboradorId = selecionado);
                    },
                    onInicio: () => _selecionarData(inicio: true),
                    onFim: () => _selecionarData(inicio: false),
                    onFiltrar: _filtrar,
                  ),
                ),
                Expanded(
                  child: jornadasProvider.jornadas.isEmpty
                      ? const Center(
                          child: Text('Nenhuma jornada encontrada'),
                        )
                      : ListView.separated(
                          itemCount: jornadasProvider.jornadas.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) => JornadaListTile(
                            jornada: jornadasProvider.jornadas[index],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      );
}

class _SearchableSelectionDialog<T> extends StatefulWidget {
  const _SearchableSelectionDialog({
    required this.titulo,
    required this.hintPesquisa,
    required this.itens,
    required this.labelBotaoTodos,
  });

  final String titulo;
  final String hintPesquisa;
  final List<_DialogOption<T>> itens;
  final String labelBotaoTodos;

  @override
  State<_SearchableSelectionDialog<T>> createState() =>
      _SearchableSelectionDialogState<T>();
}

class _SearchableSelectionDialogState<T>
    extends State<_SearchableSelectionDialog<T>> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    // O Flutter só chama isto quando o widget é REALMENTE removido da
    // árvore (após a animação de saída terminar) — nunca antes, ao
    // contrário do dispose manual logo após o Future resolver.
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtrados = widget.itens.where((item) {
      if (query.isEmpty) return true;
      return item.searchText.toLowerCase().contains(query) ||
          item.title.toLowerCase().contains(query) ||
          (item.subtitle?.toLowerCase().contains(query) ?? false);
    }).toList();

    return AlertDialog(
      constraints: const BoxConstraints(maxWidth: 560),
      title: Text(widget.titulo),
      content: SizedBox(
        width: 560,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: widget.hintPesquisa,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: filtrados.length + 1,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      leading: const Icon(Icons.clear),
                      title: Text(widget.labelBotaoTodos),
                      onTap: () => Navigator.of(context).pop(null),
                    );
                  }
                  final item = filtrados[index - 1];
                  return ListTile(
                    title: Text(item.title),
                    subtitle:
                        item.subtitle == null ? null : Text(item.subtitle!),
                    onTap: () => Navigator.of(context).pop(item.value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

 class _FiltrosJornada extends StatelessWidget {
  const _FiltrosJornada({
    required this.status,
    required this.colaboradorId,
    required this.colaboradores,
    required this.inicio,
    required this.fim,
    required this.onStatusChanged,
    required this.onColaboradorChanged,
    required this.onAbrirStatus,
    required this.onAbrirColaborador,
    required this.onInicio,
    required this.onFim,
    required this.onFiltrar,
  });

  final String? status;
  final int? colaboradorId;
  final List<Colaborador> colaboradores;
  final DateTime? inicio;
  final DateTime? fim;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<int?> onColaboradorChanged;
  final VoidCallback onAbrirStatus;
  final VoidCallback onAbrirColaborador;
  final VoidCallback onInicio;
  final VoidCallback onFim;
  final VoidCallback onFiltrar;

  @override
  Widget build(BuildContext context) {
    final colaboradorSelecionado = colaboradores
        .where((colaborador) => colaborador.id == colaboradorId)
        .cast<Colaborador?>()
        .firstOrNull;

    return Column(
      children: [
        _SearchablePickerField(
          label: 'Status',
          value: _rotuloStatus(status),
          onTap: onAbrirStatus,
        ),
        const SizedBox(height: 12),
        _SearchablePickerField(
          label: 'Colaborador',
          value: colaboradorSelecionado == null
              ? 'Todos'
              : '${colaboradorSelecionado.nome}${colaboradorSelecionado.ativo ? '' : ' (inativo)'}',
          onTap: onAbrirColaborador,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onInicio,
                child: Text(
                  inicio == null ? 'Data inicial' : _formatarData(inicio!),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: onFim,
                child: Text(fim == null ? 'Data final' : _formatarData(fim!)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: onFiltrar,
            icon: const Icon(Icons.filter_alt_outlined),
            label: const Text('Filtrar'),
          ),
        ),
      ],
    );
  }

  static String _rotuloStatus(String? status) {
    switch (status) {
      case 'EM_ANDAMENTO':
        return 'Em Andamento';
      case 'FINALIZADA':
        return 'Finalizada';
      default:
        return 'Todos';
    }
  }

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }
}

class _SearchablePickerField extends StatelessWidget {
  const _SearchablePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: ' ',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.search),
        ).copyWith(labelText: label),
        child: Text(
          value,
          style: textTheme.bodyLarge,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _DialogOption<T> {
  const _DialogOption({
    required this.value,
    required this.title,
    required this.searchText,
    this.subtitle,
  });

  final T value;
  final String title;
  final String? subtitle;
  final String searchText;
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
