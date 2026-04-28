import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/approval_page.dart';
import '../../features/auth/presentation/pages/pin_setup_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/buyer/presentation/pages/fuel_purchase_page.dart';
import '../../features/buyer/presentation/pages/buyer_dashboard_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/regulator/presentation/pages/regulator_dashboard_page.dart';
import '../../features/station/presentation/pages/station_dashboard_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final authController = ref.read(authControllerProvider.notifier);

  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(path: '/approval', builder: (context, state) => const ApprovalPage()),
      GoRoute(path: '/pin-setup', builder: (context, state) => const PinSetupPage()),
      GoRoute(path: '/buyer', builder: (context, state) => const BuyerDashboardPage()),
      GoRoute(path: '/fuel-purchase', builder: (context, state) => const FuelPurchasePage()),
      GoRoute(path: '/station', builder: (context, state) => const StationDashboardPage()),
      GoRoute(path: '/regulator', builder: (context, state) => const RegulatorDashboardPage()),
    ],
    redirect: (context, state) {
      if (!authState.initialized) {
        return null;
      }

      final location = state.uri.path;
      final publicPaths = {'/', '/login', '/register', '/approval', '/pin-setup'};
      final isPublic = publicPaths.contains(location);

      if (!authState.isAuthenticated) {
        return isPublic ? null : '/login';
      }

      final preferredRoute = authController.routeForRole(authState.role);
      if (isPublic) {
        return preferredRoute;
      }

      final allowedPaths = <UserRole, Set<String>>{
        UserRole.buyer: {'/buyer', '/fuel-purchase'},
        UserRole.station: {'/station'},
        UserRole.regulator: {'/regulator'},
      }[authState.role];

      if (allowedPaths != null && !allowedPaths.contains(location)) {
        return preferredRoute;
      }

      return null;
    },
  );
});
