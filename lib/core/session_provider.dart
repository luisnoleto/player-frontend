import 'package:flutter/foundation.dart';

import '../models/colaborador.dart';

/// Substituto temporário da autenticação: guarda login e identidade apenas em
/// memória durante a sessão. Usuário e senha não são validados contra nada;
/// qualquer par não vazio é aceito para permitir desenhar o fluxo antes do JWT.
/// Deve ser substituído por um fluxo de login real quando essa etapa existir.
class SessionProvider extends ChangeNotifier {
  Colaborador? colaboradorAtual;
  String? usuarioLogado;
  bool isGestor = false;

  bool get temColaboradorSelecionado => colaboradorAtual != null;
  bool get estaLogado => usuarioLogado != null;

  void login(String usuario) {
    usuarioLogado = usuario;
    isGestor = usuario.trim().toLowerCase() == 'playercontabilidade';
    notifyListeners();
  }

  void selecionar(Colaborador colaborador) {
    colaboradorAtual = colaborador;
    notifyListeners();
  }

  void limpar() {
    colaboradorAtual = null;
    notifyListeners();
  }

  void logout() {
    usuarioLogado = null;
    isGestor = false;
    colaboradorAtual = null;
    notifyListeners();
  }
}
