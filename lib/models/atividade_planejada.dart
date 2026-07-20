class AtividadePlanejada {
  const AtividadePlanejada({
    required this.id,
    required this.descricao,
    required this.concluida,
    this.dataConclusao,
  });

  final int id;
  final String descricao;
  final bool concluida;
  final DateTime? dataConclusao;

  factory AtividadePlanejada.fromJson(Map<String, dynamic> json) =>
      AtividadePlanejada(
        id: (json['id'] as num).toInt(),
        descricao: json['descricao'] as String,
        concluida: json['concluida'] as bool,
        dataConclusao: json['dataConclusao'] == null
            ? null
            : DateTime.parse(json['dataConclusao'] as String),
      );
}
