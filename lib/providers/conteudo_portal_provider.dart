import 'package:flutter/foundation.dart';

import '../core/app_exception.dart';
import '../models/conteudo_portal.dart';
import '../services/conteudo_portal_service.dart';

class ConteudoPortalProvider extends ChangeNotifier {
  ConteudoPortalProvider(this._service);

  final ConteudoPortalService _service;

  List<ConteudoPortal> conteudos = [];
  bool isLoading = false;
  String? error;

  Future<void> listar() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      conteudos = await _service.listar();
    } on AppException catch (exception) {
      error = exception.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
