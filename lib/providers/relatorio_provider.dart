import 'package:flutter/foundation.dart';

import '../core/app_exception.dart';
import '../models/relatorio_consolidado.dart';
import '../services/relatorio_service.dart';

class RelatorioProvider extends ChangeNotifier {
  RelatorioProvider(this._service);

  final RelatorioService _service;

  RelatorioConsolidado? relatorio;
  bool isLoading = false;
  String? error;

  Future<void> gerarConsolidado({
    int? colaboradorId,
    DateTime? inicio,
    DateTime? fim,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      relatorio = await _service.gerarConsolidado(
        colaboradorId: colaboradorId,
        inicio: inicio,
        fim: fim,
      );
    } on AppException catch (exception) {
      error = exception.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
