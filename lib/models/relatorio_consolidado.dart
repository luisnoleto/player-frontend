class RelatorioConsolidado {
  const RelatorioConsolidado({
    required this.periodoInicio,
    required this.periodoFim,
    required this.totalHorasTrabalhadas,
    required this.quantidadeAtividadesPlanejadas,
    required this.quantidadeAtividadesConcluidas,
    required this.quantidadeAtividadesNaoPlanejadas,
    required this.percentualAderenciaMedio,
  });

  final DateTime periodoInicio;
  final DateTime periodoFim;
  final double totalHorasTrabalhadas;
  final int quantidadeAtividadesPlanejadas;
  final int quantidadeAtividadesConcluidas;
  final int quantidadeAtividadesNaoPlanejadas;
  final double percentualAderenciaMedio;

  factory RelatorioConsolidado.fromJson(Map<String, dynamic> json) =>
      RelatorioConsolidado(
        periodoInicio: DateTime.parse(json['periodoInicio'] as String),
        periodoFim: DateTime.parse(json['periodoFim'] as String),
        totalHorasTrabalhadas: (json['totalHorasTrabalhadas'] as num)
            .toDouble(),
        quantidadeAtividadesPlanejadas:
            (json['quantidadeAtividadesPlanejadas'] as num).toInt(),
        quantidadeAtividadesConcluidas:
            (json['quantidadeAtividadesConcluidas'] as num).toInt(),
        quantidadeAtividadesNaoPlanejadas:
            (json['quantidadeAtividadesNaoPlanejadas'] as num).toInt(),
        percentualAderenciaMedio: (json['percentualAderenciaMedio'] as num)
            .toDouble(),
      );
}
