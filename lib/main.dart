import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/api_client.dart';
import 'core/app_router.dart';
import 'core/session_provider.dart';
import 'providers/colaborador_provider.dart';
import 'providers/atividade_provider.dart';
import 'providers/jornada_provider.dart';
import 'providers/registro_rpa_provider.dart';
import 'providers/relatorio_provider.dart';
import 'services/colaborador_service.dart';
import 'services/atividade_service.dart';
import 'services/jornada_service.dart';
import 'services/registro_rpa_service.dart';
import 'services/relatorio_service.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() {
  final apiClient = ApiClient();
  final session = SessionProvider(AuthService(apiClient), apiClient);
  final router = createAppRouter(session);
  apiClient.onUnauthorized = session.logout;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider(
          create: (_) => AtividadeProvider(AtividadeService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => ColaboradorProvider(ColaboradorService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => JornadaProvider(JornadaService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => RelatorioProvider(RelatorioService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => RegistroRpaProvider(RegistroRpaService(apiClient)),
        ),
      ],
      child: MyApp(router: router),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    title: 'Sistema de Registro de Ponto',
    theme: buildAppTheme(),
    routerConfig: router,
  );
}
