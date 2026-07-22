import 'package:flutter/foundation.dart';

import '../core/app_exception.dart';
import '../models/atividade.dart';
import '../services/atividade_service.dart';

class AtividadeProvider extends ChangeNotifier {
  AtividadeProvider(this._service);

  final AtividadeService _service;

  List<Atividade> atividades = [];
  bool isLoading = false;
  String? error;

  List<Atividade> get planejadas => atividades
      .where(
        (atividade) =>
            atividade.tipo == TipoAtividade.planejada &&
            atividade.status != StatusAtividade.concluida,
      )
      .toList(growable: false);

  List<Atividade> get concluidas => atividades
      .where((atividade) => atividade.status == StatusAtividade.concluida)
      .toList(growable: false);

  Future<void> listarTodas() => _carregar(_service.listarTodas);

  Future<void> listarPorColaborador(int colaboradorId) =>
      _carregar(() => _service.listarPorColaborador(colaboradorId));

  Future<void> _carregar(Future<List<Atividade>> Function() consulta) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      atividades = await consulta();
    } on AppException catch (exception) {
      error = exception.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
