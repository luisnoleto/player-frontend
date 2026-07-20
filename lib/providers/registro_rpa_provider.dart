import 'package:flutter/foundation.dart';

import '../core/app_exception.dart';
import '../models/registro_rpa.dart';
import '../services/registro_rpa_service.dart';

class RegistroRpaProvider extends ChangeNotifier {
  RegistroRpaProvider(this._service);

  final RegistroRpaService _service;

  List<RegistroRpa> registrosPendentes = [];
  bool isLoading = false;
  String? error;

  Future<void> listarPendentes() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      registrosPendentes = await _service.listarPendentes();
    } on AppException catch (exception) {
      error = exception.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
