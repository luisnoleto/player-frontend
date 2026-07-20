import '../core/date_utils.dart';

class Colaborador {
  const Colaborador({
    required this.id,
    required this.nome,
    required this.cpf,
    this.cargo,
    required this.dataAdmissao,
    required this.ativo,
  });

  final int id;
  final String nome;
  final String cpf;
  final String? cargo;
  final DateTime dataAdmissao;
  final bool ativo;

  factory Colaborador.fromJson(Map<String, dynamic> json) => Colaborador(
    id: (json['id'] as num).toInt(),
    nome: json['nome'] as String,
    cpf: json['cpf'] as String,
    cargo: json['cargo'] as String?,
    dataAdmissao: DateTime.parse(json['dataAdmissao'] as String),
    ativo: json['ativo'] as bool,
  );
}

class ColaboradorRequest {
  const ColaboradorRequest({
    required this.nome,
    required this.cpf,
    this.cargo,
    required this.dataAdmissao,
  });

  final String nome;
  final String cpf;
  final String? cargo;
  final DateTime dataAdmissao;

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'cpf': cpf,
    'cargo': cargo,
    'dataAdmissao': formatApiDate(dataAdmissao),
  };
}
