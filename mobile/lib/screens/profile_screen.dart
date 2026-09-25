import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_state.dart';
import '../providers/app_providers.dart';
import '../services/api_exception.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/sentry_test_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? _permissionMessage;

  Future<void> _probe403() async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) return;
    try {
      await ref.read(apiServiceProvider).probeForbidden(session.accessToken);
      setState(
        () => _permissionMessage = 'Operación administrativa permitida.',
      );
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        ref.read(authControllerProvider.notifier).handleUnauthorized();
        return;
      }
      setState(() => _permissionMessage = error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final state = ref.watch(authControllerProvider);
    final user = state.session?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: IconButton(
          tooltip: 'Productos',
          onPressed: () => context.go('/products'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceMd),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Usuario autenticado',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  SizedBox(height: tokens.spaceMd),
                  if (user != null) ...[
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(user.name),
                      subtitle: Text('${user.email} · ${user.role}'),
                    ),
                    SizedBox(height: tokens.spaceMd),
                    AppPrimaryButton(
                      text: 'PROBAR 403',
                      onPressed: _probe403,
                      icon: const Icon(Icons.block_outlined),
                    ),
                    if (_permissionMessage != null) ...[
                      SizedBox(height: tokens.spaceMd),
                      Text(_permissionMessage!),
                    ],
                    SizedBox(height: tokens.spaceLg),
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(authControllerProvider.notifier).logout();
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                    ),
                  ] else if (state is Unauthenticated) ...[
                    Text(state.message ?? 'No hay sesión activa.'),
                  ],
                  const SentryTestButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
