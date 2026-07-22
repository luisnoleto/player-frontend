enum PerfilUsuario {
  gestor,
  colaborador;

  String get apiValue => name.toUpperCase();

  String get label => this == PerfilUsuario.gestor ? 'Gestor' : 'Colaborador';

  static PerfilUsuario fromJson(String value) =>
      value.toUpperCase() == 'GESTOR' ? gestor : colaborador;
}

class UsuarioAutenticado {
  const UsuarioAutenticado({
    required this.token,
    required this.id,
    required this.nome,
    required this.perfil,
  });

  final String token;
  final int id;
  final String nome;
  final PerfilUsuario perfil;

  factory UsuarioAutenticado.fromJson(Map<String, dynamic> json) =>
      UsuarioAutenticado(
        token: json['token'] as String,
        id: (json['id'] as num).toInt(),
        nome: json['nome'] as String,
        perfil: PerfilUsuario.fromJson(json['perfil'] as String),
      );
}
