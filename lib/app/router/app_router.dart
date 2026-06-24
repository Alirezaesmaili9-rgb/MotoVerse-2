import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/core_providers.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/phone_login_screen.dart';
import '../../features/garage/presentation/screens/garage_screen.dart';
import '../../features/home/presentation/screens/home_shell.dart';
import 'routes.dart';

/// App router with auth-aware redirects. Unauthenticated users are sent to
/// the login flow; authenticated users are kept out of it.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: _AuthRefresh(ref),
    redirect: (context, state) {
      final loggedIn = ref.read(supabaseClientProvider).auth.currentUser != null;
      final loggingIn = state.matchedLocation.startsWith(AppRoutes.login);

      if (!loggedIn) return loggingIn ? null : AppRoutes.login;
      if (loggingIn) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const PhoneLoginScreen(),
        routes: [
          GoRoute(
            path: 'otp',
            builder: (_, __) => const OtpScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomeShell(),
      ),
      GoRoute(
        path: AppRoutes.garage,
        builder: (_, __) => const GarageScreen(),
      ),
    ],
  );
});

/// Bridges the Supabase auth stream to GoRouter's [Listenable] refresh.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen(authStateChangesProvider, (_, __) => notifyListeners());
  }
}
