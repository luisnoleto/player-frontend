import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/session_provider.dart';
import 'providers/colaborador_provider.dart';
import 'providers/jornada_provider.dart';
import 'providers/registro_rpa_provider.dart';
import 'providers/relatorio_provider.dart';
import 'services/colaborador_service.dart';
import 'services/jornada_service.dart';
import 'services/registro_rpa_service.dart';
import 'services/relatorio_service.dart';
import 'screens/gestao/colaboradores_page.dart';
import 'screens/home/home_page.dart';
import 'theme/app_theme.dart';

void main() {
  final apiClient = ApiClient();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),
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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomePage()),
      GoRoute(
        path: '/colaboradores',
        builder: (_, _) => const ColaboradoresPage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Sistema de Registro de Ponto',
        theme: buildAppTheme(),
        routerConfig: _router,
      );
}
