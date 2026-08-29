import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_state.dart';
import '../screens/create_order_screen.dart';
import '../screens/login_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/products_screen.dart';
import '../screens/profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshNotifier();
  ref.onDispose(refresh.dispose);
  ref.listen(authControllerProvider, (_, _) => refresh.refresh());

  return GoRouter(
    initialLocation: '/products',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isLoggedIn = authState is Authenticated;
      final location = state.uri.toString();
      final isLogin = state.matchedLocation == '/login';
      final protected = _isProtectedPath(state.uri.path);

      if (!isLoggedIn && protected) {
        return '/login?from=${Uri.encodeComponent(location)}';
      }

      if (isLoggedIn && isLogin) {
        final from = state.uri.queryParameters['from'];
        return _safeInternalPath(from) ?? '/products';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          from: _safeInternalPath(state.uri.queryParameters['from']),
        ),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => ProductDetailScreen(
              productId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const CreateOrderScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

bool _isProtectedPath(String path) {
  if (path.startsWith('/orders')) return true;
  if (path.startsWith('/profile')) return true;
  return path.startsWith('/products/') && path != '/products/';
}

String? _safeInternalPath(String? value) {
  if (value == null || value.isEmpty) return null;
  final decoded = Uri.decodeComponent(value);
  final uri = Uri.tryParse(decoded);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  if (!decoded.startsWith('/') || decoded.startsWith('//')) return null;
  return decoded;
}

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
