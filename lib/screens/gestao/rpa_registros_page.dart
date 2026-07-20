import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../models/registro_rpa.dart';
import '../../providers/registro_rpa_provider.dart';

class RpaRegistrosPage extends StatefulWidget {
  const RpaRegistrosPage({super.key});

  @override
  State<RpaRegistrosPage> createState() => _RpaRegistrosPageState();
}

class _RpaRegistrosPageState extends State<RpaRegistrosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarRegistros());
  }

  Future<void> _carregarRegistros() async {
    if (!mounted) return;
    final provider = context.read<RegistroRpaProvider>();
    await provider.listarPendentes();
    if (mounted && provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<RegistroRpaProvider>(
    builder: (context, provider, _) => Scaffold(
      appBar: AppBar(title: const Text('Registros RPA')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.registrosPendentes.isEmpty
          ? const Center(
              child: Text('Nenhum registro pendente de processamento'),
            )
          : RefreshIndicator(
              onRefresh: _carregarRegistros,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: provider.registrosPendentes.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) => _RegistroRpaTile(
                  registro: provider.registrosPendentes[index],
                ),
              ),
            ),
    ),
  );
}

class _RegistroRpaTile extends StatelessWidget {
  const _RegistroRpaTile({required this.registro});

  final RegistroRpa registro;

  @override
  Widget build(BuildContext context) {
    final entrada = registro.tipoRegistro == 'ENTRADA';
    return ListTile(
      leading: Icon(entrada ? LucideIcons.logIn : LucideIcons.logOut),
      title: Text(registro.tipoRegistro),
      subtitle: Text(
        '${_formatarDataHora(registro.dataHoraRegistro)}\n'
        'Origem: ${registro.origem} • Colaborador #${registro.colaboradorId}',
      ),
      isThreeLine: true,
    );
  }

  static String _formatarDataHora(DateTime dataHora) {
    final dia = dataHora.day.toString().padLeft(2, '0');
    final mes = dataHora.month.toString().padLeft(2, '0');
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${dataHora.year} $hora:$minuto';
  }
}
