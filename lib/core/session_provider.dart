import 'package:flutter/foundation.dart';

import '../models/auth.dart';
import '../models/colaborador.dart';
import '../services/auth_service.dart';
import 'api_client.dart';
import 'app_exception.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider(this._authService, this._apiClient);

  final AuthService _authService;
  final ApiClient _apiClient;

  UsuarioAutenticado? usuarioAtual;
  Colaborador? colaboradorAtual;
  bool isLoading = false;
  String? error;

  bool get estaLogado => usuarioAtual != null;
  bool get isGestor => usuarioAtual?.perfil == PerfilUsuario.gestor;
  int? get colaboradorIdAtual =>
      colaboradorAtual?.id ?? (isGestor ? null : usuarioAtual?.id);
  String? get colaboradorNomeAtual =>
      colaboradorAtual?.nome ?? (isGestor ? null : usuarioAtual?.nome);
  bool get temColaboradorSelecionado => colaboradorIdAtual != null;

  Future<bool> login(String login, String senha) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      usuarioAtual = await _authService.login(login.trim(), senha);
      _apiClient.setToken(usuarioAtual!.token);
      colaboradorAtual = null;
      return true;
    } on AppException catch (exception) {
      error = exception.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selecionar(Colaborador colaborador) {
    if (!isGestor) return;
    colaboradorAtual = colaborador;
    notifyListeners();
  }

  void limpar() {
    colaboradorAtual = null;
    notifyListeners();
  }

  void logout() {
    _apiClient.clearToken();
    usuarioAtual = null;
    colaboradorAtual = null;
    error = null;
    notifyListeners();
  }
}
