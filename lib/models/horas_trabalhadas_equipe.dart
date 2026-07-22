class HorasTrabalhadasColaborador {
  const HorasTrabalhadasColaborador({
    required this.colaboradorId,
    required this.colaboradorNome,
    required this.totalHoras,
  });

  final int colaboradorId;
  final String colaboradorNome;
  final double totalHoras;

  factory HorasTrabalhadasColaborador.fromJson(Map<String, dynamic> json) =>
      HorasTrabalhadasColaborador(
        colaboradorId: (json['colaboradorId'] as num).toInt(),
        colaboradorNome: json['colaboradorNome'] as String,
        totalHoras: (json['totalHoras'] as num).toDouble(),
      );
}

class HorasTrabalhadasEquipe {
  const HorasTrabalhadasEquipe({
    required this.periodoInicio,
    required this.periodoFim,
    required this.colaboradores,
  });

  final DateTime periodoInicio;
  final DateTime periodoFim;
  final List<HorasTrabalhadasColaborador> colaboradores;

  double get totalHoras => colaboradores.fold(
    0,
    (total, colaborador) => total + colaborador.totalHoras,
  );

  double get mediaHoras =>
      colaboradores.isEmpty ? 0 : totalHoras / colaboradores.length;

  factory HorasTrabalhadasEquipe.fromJson(Map<String, dynamic> json) =>
      HorasTrabalhadasEquipe(
        periodoInicio: DateTime.parse(json['periodoInicio'] as String),
        periodoFim: DateTime.parse(json['periodoFim'] as String),
        colaboradores: (json['colaboradores'] as List<dynamic>? ?? [])
            .map(
              (item) => HorasTrabalhadasColaborador.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),
      );
}
