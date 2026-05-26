
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/pin_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/inventory/inventory_screen.dart';
import '../../features/inbox/inbox_screen.dart';
import '../../features/loyalty/loyalty_screen.dart';
import '../providers/auth_provider.dart';

GoRouter buildAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final status = authProvider.status;
      final isOnSplash = state.uri.path == '/splash';
      final isOnLogin = state.uri.path == '/login';
      final isOnPin = state.uri.path == '/pin';
      final isAuthRoute = isOnSplash || isOnLogin || isOnPin;

      if (isOnSplash) return null;

      if (status == AuthStatus.unauthenticated && !isOnLogin) {
        return '/login';
      }
      if (status == AuthStatus.pinRequired && !isOnPin) {
        return '/pin';
      }
      if (status == AuthStatus.pinSetup && !isOnPin) {
        return '/pin';
      }
      if (status == AuthStatus.authenticated && isAuthRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/pin',
        builder: (context, state) => const PinScreen(),
      ),
      GoRoute(
        path: '/inbox',
        builder: (context, state) => const InboxScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: '/loyalty',
            builder: (context, state) => const LoyaltyScreen(),
          ),
        ],
      ),
    ],
  );
}
