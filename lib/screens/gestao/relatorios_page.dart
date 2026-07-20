import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/relatorio_provider.dart';
import '../../widgets/adherence_progress_bar.dart';
import '../../widgets/stat_card.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  DateTime? _inicio;
  DateTime? _fim;

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

  Future<void> _gerarRelatorio() async {
    if (_inicio == null || _fim == null) return;
    final provider = context.read<RelatorioProvider>();
    await provider.gerarConsolidado(inicio: _inicio, fim: _fim);
    if (mounted && provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<RelatorioProvider>(
    builder: (context, provider, _) {
      if (provider.isLoading) {
        return Scaffold(
          appBar: AppBar(title: const Text('Relatórios')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      final relatorio = provider.relatorio;
      return Scaffold(
        appBar: AppBar(title: const Text('Relatórios')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Período do relatório',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selecionarData(inicio: true),
                    child: Text(
                      _inicio == null
                          ? 'Data inicial'
                          : _formatarData(_inicio!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selecionarData(inicio: false),
                    child: Text(
                      _fim == null ? 'Data final' : _formatarData(_fim!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _inicio == null || _fim == null
                  ? null
                  : _gerarRelatorio,
              child: const Text('Gerar Relatório'),
            ),
            if (relatorio != null) ...[
              const SizedBox(height: 28),
              StatCard(
                label: 'Horas Trabalhadas',
                value:
                    '${relatorio.totalHorasTrabalhadas.toStringAsFixed(1)} h',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Planejadas',
                      value: '${relatorio.quantidadeAtividadesPlanejadas}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Concluídas',
                      value: '${relatorio.quantidadeAtividadesConcluidas}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AdherenceProgressBar(
                percentual: relatorio.percentualAderenciaMedio,
              ),
            ],
          ],
        ),
      );
    },
  );

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }
}
