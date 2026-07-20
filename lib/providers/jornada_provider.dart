import 'package:flutter/foundation.dart';

import '../core/app_exception.dart';
import '../models/jornada_detalhe.dart';
import '../models/jornada_resumo.dart';
import '../services/jornada_service.dart';

class JornadaProvider extends ChangeNotifier {
  JornadaProvider(this._service);

  final JornadaService _service;

  JornadaDetalhe? jornadaDetalhe;
  List<JornadaResumo> historico = [];
  List<JornadaResumo> jornadas = [];
  bool isLoading = false;
  String? error;

  Future<void> iniciar(IniciarJornadaRequest request) async {
    _setLoading();
    try {
      jornadaDetalhe = await _service.iniciar(request);
    } on AppException catch (exception) {
      error = exception.message;
    } finally {
      _finishLoading();
    }
  }

  Future<void> encerrar(int jornadaId, EncerrarJornadaRequest request) async {
    _setLoading();
    try {
      jornadaDetalhe = await _service.encerrar(jornadaId, request);
    } on AppException catch (exception) {
      error = exception.message;
    } finally {
      _finishLoading();
    }
  }

  Future<void> buscarHistorico(int colaboradorId) async {
    _setLoading();
    try {
      historico = await _service.buscarHistorico(colaboradorId);
    } on AppException catch (exception) {
      error = exception.message;
    } finally {
      _finishLoading();
    }
  }

  Future<void> listarComFiltros({
    String? status,
    int? colaboradorId,
    DateTime? inicio,
    DateTime? fim,
  }) async {
    _setLoading();
    try {
      jornadas = await _service.listarComFiltros(
        status: status,
        colaboradorId: colaboradorId,
        inicio: inicio,
        fim: fim,
      );
    } on AppException catch (exception) {
      error = exception.message;
    } finally {
      _finishLoading();
    }
  }

  Future<void> buscarDetalhe(int id) async {
    _setLoading();
    try {
      jornadaDetalhe = await _service.buscarDetalhe(id);
    } on AppException catch (exception) {
      error = exception.message;
    } finally {
      _finishLoading();
    }
  }

  void _setLoading() {
    isLoading = true;
    error = null;
    notifyListeners();
  }

  void _finishLoading() {
    isLoading = false;
    notifyListeners();
  }
}
