import 'package:go_router/go_router.dart';

import '../screens/auth/login_page.dart';
import '../screens/atividades/atividades_page.dart';
import '../screens/colaborador/colaborador_dashboard_page.dart';
import '../screens/colaborador/colaborador_selector_page.dart';
import '../screens/colaborador/encerrar_jornada_page.dart';
import '../screens/colaborador/historico_page.dart';
import '../screens/colaborador/iniciar_jornada_page.dart';
import '../screens/gestao/colaboradores_page.dart';
import '../screens/gestao/gestao_dashboard_page.dart';
import '../screens/gestao/horas_colaboradores_page.dart';
import '../screens/gestao/jornadas_consulta_page.dart';
import '../screens/gestao/relatorios_page.dart';
import '../screens/gestao/rpa_conteudos_page.dart';
import '../screens/home/home_page.dart';
import 'session_provider.dart';

GoRouter createAppRouter(SessionProvider session) => GoRouter(
  refreshListenable: session,
  redirect: (_, state) {
    final path = state.uri.path;
    if (!session.estaLogado) return path == '/' ? null : '/';
    if (path == '/') {
      return session.isGestor ? '/gestao' : '/area-colaborador/dashboard';
    }
    if (!session.isGestor && (path == '/home' || path == '/area-colaborador')) {
      return '/area-colaborador/dashboard';
    }
    final rotaDeGestao = path == '/colaboradores' || path.startsWith('/gestao');
    if (rotaDeGestao && !session.isGestor) {
      return '/area-colaborador/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, _) => const LoginPage()),
    GoRoute(path: '/home', builder: (_, _) => const HomePage()),
    GoRoute(
      path: '/area-colaborador',
      builder: (_, _) => const ColaboradorSelectorPage(),
    ),
    GoRoute(
      path: '/area-colaborador/dashboard',
      builder: (_, _) => const ColaboradorDashboardPage(),
    ),
    GoRoute(
      path: '/area-colaborador/iniciar',
      builder: (_, _) => const IniciarJornadaPage(),
    ),
    GoRoute(
      path: '/area-colaborador/encerrar/:jornadaId',
      builder: (_, state) => EncerrarJornadaPage(
        jornadaId: int.tryParse(state.pathParameters['jornadaId'] ?? '') ?? 0,
      ),
    ),
    GoRoute(
      path: '/area-colaborador/historico',
      builder: (_, _) => const HistoricoPage(),
    ),
    GoRoute(
      path: '/area-colaborador/atividades/:filtro',
      builder: (_, state) => AtividadesPage(
        concluidas: state.pathParameters['filtro'] == 'concluidas',
        mostrarColaborador: false,
      ),
    ),
    GoRoute(
      path: '/colaboradores',
      builder: (_, _) => const ColaboradoresPage(),
    ),
    GoRoute(path: '/gestao', builder: (_, _) => const GestaoDashboardPage()),
    GoRoute(
      path: '/gestao/horas-trabalhadas',
      builder: (_, _) => const HorasColaboradoresPage(),
    ),
    GoRoute(
      path: '/gestao/atividades/:filtro',
      builder: (_, state) => AtividadesPage(
        concluidas: state.pathParameters['filtro'] == 'concluidas',
        mostrarColaborador: true,
      ),
    ),
    GoRoute(
      path: '/gestao/jornadas',
      builder: (_, _) => const JornadasConsultaPage(),
    ),
    GoRoute(
      path: '/gestao/relatorios',
      builder: (_, _) => const RelatoriosPage(),
    ),
    GoRoute(path: '/gestao/rpa', builder: (_, _) => const RpaConteudosPage()),
  ],
);
