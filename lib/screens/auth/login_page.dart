import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/session_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;

  bool get _podeEntrar =>
      _usuarioController.text.trim().isNotEmpty &&
      _senhaController.text.isNotEmpty;

  @override
  void dispose() {
    _usuarioController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _entrar() {
    if (!_podeEntrar) return;
    final session = context.read<SessionProvider>();
    session.login(_usuarioController.text.trim());
    context.go(session.isGestor ? '/gestao' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 102,
                        height: 102,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            '../../lib/assets/playerLogo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const Gap(24),
                    Text(
                      'Bem-vindo',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Gap(24),
                    TextField(
                      controller: _usuarioController,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const Gap(16),
                    TextField(
                      controller: _senhaController,
                      onChanged: (_) => setState(() {}),
                      obscureText: !_senhaVisivel,
                      onSubmitted: (_) => _entrar(),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _senhaVisivel = !_senhaVisivel),
                          tooltip: _senhaVisivel
                              ? 'Ocultar senha'
                              : 'Mostrar senha',
                          icon: Icon(
                            _senhaVisivel
                                ? LucideIcons.eyeOff
                                : LucideIcons.eye,
                          ),
                        ),
                      ),
                    ),
                    const Gap(24),
                    FilledButton(
                      onPressed: _podeEntrar ? _entrar : null,
                      child: const Text('Entrar'),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0),
          ),
        ),
      ),
    );
  }
}
