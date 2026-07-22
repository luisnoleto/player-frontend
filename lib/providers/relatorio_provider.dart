import 'package:flutter/foundation.dart';

import '../core/app_exception.dart';
import '../models/relatorio_consolidado.dart';
import '../models/horas_trabalhadas_equipe.dart';
import '../services/relatorio_service.dart';

class RelatorioProvider extends ChangeNotifier {
  RelatorioProvider(this._service);

  final RelatorioService _service;

  RelatorioConsolidado? relatorio;
  RelatorioConsolidado? relatorioGestao;
  HorasTrabalhadasEquipe? horasEquipe;
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

  Future<void> carregarVisaoGestaoUltimosTrintaDias() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final resultados = await Future.wait<Object>([
        _service.gerarConsolidado(),
        _service.listarHorasPorColaborador(),
      ]);
      relatorioGestao = resultados[0] as RelatorioConsolidado;
      horasEquipe = resultados[1] as HorasTrabalhadasEquipe;
    } on AppException catch (exception) {
      error = exception.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> carregarPaginaRelatorios({
    int? colaboradorId,
    required DateTime inicio,
    required DateTime fim,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final resultados = await Future.wait<Object>([
        _service.gerarConsolidado(
          colaboradorId: colaboradorId,
          inicio: inicio,
          fim: fim,
        ),
        _service.listarHorasPorColaborador(),
      ]);
      relatorio = resultados[0] as RelatorioConsolidado;
      horasEquipe = resultados[1] as HorasTrabalhadasEquipe;
    } on AppException catch (exception) {
      error = exception.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> listarHorasPorColaborador() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      horasEquipe = await _service.listarHorasPorColaborador();
    } on AppException catch (exception) {
      error = exception.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
