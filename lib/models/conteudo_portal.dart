class ConteudoPortal {
  const ConteudoPortal({
    required this.id,
    required this.categoria,
    required this.chaveExterna,
    required this.titulo,
    this.descricao,
    this.valor,
    this.link,
    required this.fonteUrl,
    required this.ordem,
    required this.coletadoEm,
  });

  final int id;
  final String categoria;
  final String chaveExterna;
  final String titulo;
  final String? descricao;
  final String? valor;
  final String? link;
  final String fonteUrl;
  final int ordem;
  final DateTime coletadoEm;

  factory ConteudoPortal.fromJson(Map<String, dynamic> json) => ConteudoPortal(
    id: (json['id'] as num).toInt(),
    categoria: json['categoria'] as String,
    chaveExterna: json['chaveExterna'] as String,
    titulo: json['titulo'] as String,
    descricao: json['descricao'] as String?,
    valor: json['valor'] as String?,
    link: json['link'] as String?,
    fonteUrl: json['fonteUrl'] as String,
    ordem: (json['ordem'] as num).toInt(),
    coletadoEm: DateTime.parse(json['coletadoEm'] as String),
  );
}
