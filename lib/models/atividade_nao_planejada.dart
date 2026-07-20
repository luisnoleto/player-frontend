class AtividadeNaoPlanejada {
  const AtividadeNaoPlanejada({
    required this.id,
    required this.descricao,
    required this.dataCadastro,
  });

  final int id;
  final String descricao;
  final DateTime dataCadastro;

  factory AtividadeNaoPlanejada.fromJson(Map<String, dynamic> json) =>
      AtividadeNaoPlanejada(
        id: (json['id'] as num).toInt(),
        descricao: json['descricao'] as String,
        dataCadastro: DateTime.parse(json['dataCadastro'] as String),
      );
}
