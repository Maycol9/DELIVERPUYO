import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_controller.dart';
import 'router/app_router.dart';
import 'services/sentry_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();

  // Set up FlutterError.onError BEFORE Sentry init so the SDK's
  // FlutterErrorIntegration preserves and chains this handler.
  SentryService.setupFlutterError();

  await SentryService.initApp(() async {
    await container.read(authControllerProvider.notifier).restore();
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const DeliverPuyoApp(),
      ),
    );
  });
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
