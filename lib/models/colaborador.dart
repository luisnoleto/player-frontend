import '../core/date_utils.dart';
import 'auth.dart';

class Colaborador {
  const Colaborador({
    required this.id,
    required this.nome,
    required this.cpf,
    this.cargo,
    required this.dataAdmissao,
    required this.ativo,
    this.login,
    required this.perfil,
  });

  final int id;
  final String nome;
  final String cpf;
  final String? cargo;
  final DateTime dataAdmissao;
  final bool ativo;
  final String? login;
  final PerfilUsuario perfil;

  factory Colaborador.fromJson(Map<String, dynamic> json) => Colaborador(
    id: (json['id'] as num).toInt(),
    nome: json['nome'] as String,
    cpf: json['cpf'] as String,
    cargo: json['cargo'] as String?,
    dataAdmissao: DateTime.parse(json['dataAdmissao'] as String),
    ativo: json['ativo'] as bool,
    login: json['login'] as String?,
    perfil: PerfilUsuario.fromJson(
      (json['perfil'] as String?) ?? 'COLABORADOR',
    ),
  );
}

class ColaboradorRequest {
  const ColaboradorRequest({
    required this.nome,
    required this.cpf,
    this.cargo,
    required this.dataAdmissao,
    required this.login,
    required this.senha,
    required this.perfil,
  });

  final String nome;
  final String cpf;
  final String? cargo;
  final DateTime dataAdmissao;
  final String login;
  final String senha;
  final PerfilUsuario perfil;

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'cpf': cpf,
    'cargo': cargo,
    'dataAdmissao': formatApiDate(dataAdmissao),
    'login': login,
    'senha': senha,
    'perfil': perfil.apiValue,
  };
}
