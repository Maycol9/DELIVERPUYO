import 'auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(authControllerProvider.notifier).restore();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DeliverPuyoApp(),
    ),
  );
}

class DeliverPuyoApp extends ConsumerWidget {
  const DeliverPuyoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'DeliverPuyo Móvil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
