import 'package:flutter/foundation.dart';

import '../core/app_exception.dart';
import '../models/colaborador.dart';
import '../services/colaborador_service.dart';

class ColaboradorProvider extends ChangeNotifier {
  ColaboradorProvider(this._service);

  final ColaboradorService _service;

  List<Colaborador> colaboradores = [];
  bool isLoading = false;
  String? error;

  Future<void> listarAtivos() async {
    _setLoading();
    try {
      colaboradores = await _service.listarAtivos();
    } on AppException catch (exception) {
      error = exception.message;
    } finally {
      _finishLoading();
    }
  }

  Future<void> criar(ColaboradorRequest request) async {
    _setLoading();
    try {
      final colaborador = await _service.criar(request);
      colaboradores = [...colaboradores, colaborador];
    } on AppException catch (exception) {
      error = exception.message;
    } finally {
      _finishLoading();
    }
  }

  Future<void> inativar(int id) async {
    _setLoading();
    try {
      await _service.inativar(id);
      colaboradores = colaboradores.where((item) => item.id != id).toList();
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
