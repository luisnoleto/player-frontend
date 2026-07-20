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
      colaboradores.listarAtivos(),
      jornadas.listarComFiltros(),
    ]);
    if (!mounted) return;
    final error = colaboradores.error ?? jornadas.error;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
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
                    onInicio: () => _selecionarData(inicio: true),
                    onFim: () => _selecionarData(inicio: false),
                    onFiltrar: _filtrar,
                  ),
                ),
                Expanded(
                  child: jornadasProvider.jornadas.isEmpty
                      ? const Center(child: Text('Nenhuma jornada encontrada'))
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

class _FiltrosJornada extends StatelessWidget {
  const _FiltrosJornada({
    required this.status,
    required this.colaboradorId,
    required this.colaboradores,
    required this.inicio,
    required this.fim,
    required this.onStatusChanged,
    required this.onColaboradorChanged,
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
  final VoidCallback onInicio;
  final VoidCallback onFim;
  final VoidCallback onFiltrar;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      DropdownButtonFormField<String?>(
        initialValue: status,
        decoration: const InputDecoration(
          labelText: 'Status',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: null, child: Text('Todos')),
          DropdownMenuItem(value: 'EM_ANDAMENTO', child: Text('Em Andamento')),
          DropdownMenuItem(value: 'FINALIZADA', child: Text('Finalizada')),
        ],
        onChanged: onStatusChanged,
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<int?>(
        initialValue: colaboradorId,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Colaborador',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('Todos')),
          ...colaboradores.map(
            (colaborador) => DropdownMenuItem(
              value: colaborador.id,
              child: Text(colaborador.nome),
            ),
          ),
        ],
        onChanged: onColaboradorChanged,
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

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }
}
