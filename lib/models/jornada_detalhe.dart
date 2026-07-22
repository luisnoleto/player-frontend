import 'atividade.dart';
import 'jornada_resumo.dart';

class JornadaDetalhe {
  const JornadaDetalhe({
    required this.id,
    required this.colaboradorId,
    required this.colaboradorNome,
    required this.dataHoraEntrada,
    this.dataHoraSaida,
    this.duracaoMinutos,
    required this.status,
    this.percentualAderencia,
    this.resumoAtividades,
    required this.atividades,
  });

  final int id;
  final int colaboradorId;
  final String colaboradorNome;
  final DateTime dataHoraEntrada;
  final DateTime? dataHoraSaida;
  final int? duracaoMinutos;
  final StatusJornada status;
  final double? percentualAderencia;
  final String? resumoAtividades;
  final List<Atividade> atividades;

  List<Atividade> get atividadesPlanejadas => atividades
      .where((atividade) => atividade.tipo == TipoAtividade.planejada)
      .toList(growable: false);

  List<Atividade> get atividadesNaoPlanejadas => atividades
      .where((atividade) => atividade.tipo == TipoAtividade.naoPlanejada)
      .toList(growable: false);

  factory JornadaDetalhe.fromJson(Map<String, dynamic> json) => JornadaDetalhe(
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
    resumoAtividades: json['resumoAtividades'] as String?,
    atividades: (json['atividades'] as List<dynamic>? ?? [])
        .map((item) => Atividade.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class IniciarJornadaRequest {
  const IniciarJornadaRequest({
    required this.colaboradorId,
    required this.atividadesPlanejadas,
  });

  final int colaboradorId;
  final List<String> atividadesPlanejadas;

  Map<String, dynamic> toJson() => {
    'colaboradorId': colaboradorId,
    'atividadesPlanejadas': atividadesPlanejadas
        .map((descricao) => {'descricao': descricao})
        .toList(),
  };
}

class EncerrarJornadaRequest {
  const EncerrarJornadaRequest({
    required this.atividadesConcluidasIds,
    required this.atividadesNaoPlanejadas,
  });

  final List<int> atividadesConcluidasIds;
  final List<String> atividadesNaoPlanejadas;

  Map<String, dynamic> toJson() => {
    'atividadesConcluidasIds': atividadesConcluidasIds,
    'atividadesNaoPlanejadas': atividadesNaoPlanejadas
        .map((descricao) => {'descricao': descricao})
        .toList(),
  };
}
