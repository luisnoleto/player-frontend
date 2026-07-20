enum StatusJornada {
  emAndamento,
  finalizada;

  static StatusJornada fromJson(String value) {
    switch (value) {
      case 'EM_ANDAMENTO':
        return StatusJornada.emAndamento;
      case 'FINALIZADA':
        return StatusJornada.finalizada;
      default:
        throw ArgumentError.value(value, 'value', 'Status de jornada inválido');
    }
  }

  String toJson() => switch (this) {
    StatusJornada.emAndamento => 'EM_ANDAMENTO',
    StatusJornada.finalizada => 'FINALIZADA',
  };
}

class JornadaResumo {
  const JornadaResumo({
    required this.id,
    required this.colaboradorId,
    required this.colaboradorNome,
    required this.dataHoraEntrada,
    this.dataHoraSaida,
    this.duracaoMinutos,
    required this.status,
    this.percentualAderencia,
  });

  final int id;
  final int colaboradorId;
  final String colaboradorNome;
  final DateTime dataHoraEntrada;
  final DateTime? dataHoraSaida;
  final int? duracaoMinutos;
  final StatusJornada status;
  final double? percentualAderencia;

  factory JornadaResumo.fromJson(Map<String, dynamic> json) => JornadaResumo(
    id: (json['id'] as num).toInt(),
    colaboradorId: (json['colaboradorId'] as num).toInt(),
    colaboradorNome: json['colaboradorNome'] as String,
    dataHoraEntrada: DateTime.parse(json['dataHoraEntrada'] as String),
    dataHoraSaida: json['dataHoraSaida'] == null
        ? null
        : DateTime.parse(json['dataHoraSaida'] as String),
    duracaoMinutos: (json['duracaoMinutos'] as num?)?.toInt(),
    status: StatusJornada.fromJson(json['status'] as String),
    percentualAderencia: (json['percentualAderencia'] as num?)?.toDouble(),
  );
}
