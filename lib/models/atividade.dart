enum TipoAtividade {
  planejada,
  naoPlanejada;

  factory TipoAtividade.fromJson(String value) => switch (value) {
    'PLANEJADA' => planejada,
    'NAO_PLANEJADA' => naoPlanejada,
    _ => throw FormatException('Tipo de atividade inválido: $value'),
  };
}

enum StatusAtividade {
  pendente,
  emAndamento,
  concluida;

  factory StatusAtividade.fromJson(String value) => switch (value) {
    'PENDENTE' => pendente,
    'EM_ANDAMENTO' => emAndamento,
    'CONCLUIDA' => concluida,
    _ => throw FormatException('Status de atividade inválido: $value'),
  };
}

class Atividade {
  const Atividade({
    required this.id,
    required this.descricao,
    required this.tipo,
    required this.status,
    required this.jornadaId,
    required this.colaboradorId,
    required this.dataCadastro,
    this.dataConclusao,
  });

  final int id;
  final String descricao;
  final TipoAtividade tipo;
  final StatusAtividade status;
  final int jornadaId;
  final int colaboradorId;
  final DateTime dataCadastro;
  final DateTime? dataConclusao;

  bool get concluida => status == StatusAtividade.concluida;

  factory Atividade.fromJson(Map<String, dynamic> json) => Atividade(
    id: (json['id'] as num).toInt(),
    descricao: json['descricao'] as String,
    tipo: TipoAtividade.fromJson(json['tipo'] as String),
    status: StatusAtividade.fromJson(json['status'] as String),
    jornadaId: (json['jornadaId'] as num).toInt(),
    colaboradorId: (json['colaboradorId'] as num).toInt(),
    dataCadastro: DateTime.parse(json['dataCadastro'] as String),
    dataConclusao: json['dataConclusao'] == null
        ? null
        : DateTime.parse(json['dataConclusao'] as String),
  );
}
