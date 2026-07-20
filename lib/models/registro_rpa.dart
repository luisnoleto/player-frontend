class RegistroRpa {
  const RegistroRpa({
    required this.id,
    required this.colaboradorId,
    required this.tipoRegistro,
    required this.dataHoraRegistro,
    required this.origem,
    required this.processado,
  });

  final int id;
  final int colaboradorId;
  final String tipoRegistro;
  final DateTime dataHoraRegistro;
  final String origem;
  final bool processado;

  factory RegistroRpa.fromJson(Map<String, dynamic> json) => RegistroRpa(
    id: (json['id'] as num).toInt(),
    colaboradorId: (json['colaboradorId'] as num).toInt(),
    tipoRegistro: json['tipoRegistro'] as String,
    dataHoraRegistro: DateTime.parse(json['dataHoraRegistro'] as String),
    origem: json['origem'] as String,
    processado: json['processado'] as bool,
  );
}
