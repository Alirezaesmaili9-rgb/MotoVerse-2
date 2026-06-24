import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/core_providers.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_news_screen.dart';
import '../../features/admin/presentation/screens/admin_orders_screen.dart';
import '../../features/admin/presentation/screens/admin_products_screen.dart';
import '../../features/admin/presentation/screens/admin_roadside_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/phone_login_screen.dart';
import '../../features/garage/domain/entities/motorcycle.dart';
import '../../features/garage/presentation/screens/garage_screen.dart';
import '../../features/home/presentation/screens/home_shell.dart';
import '../../features/maintenance/presentation/screens/maintenance_screen.dart';
import '../../features/marketplace/presentation/screens/cart_screen.dart';
import '../../features/marketplace/presentation/screens/checkout_screen.dart';
import '../../features/marketplace/presentation/screens/favorites_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../../features/marketplace/presentation/screens/orders_screen.dart';
import '../../features/copilot/presentation/screens/copilot_screen.dart';
import '../../features/insurance/presentation/screens/insurance_screen.dart';
import '../../features/insurance/presentation/screens/policies_screen.dart';
import '../../features/marketplace/presentation/screens/product_detail_screen.dart';
import '../../features/motor_world/presentation/screens/article_detail_screen.dart';
import '../../features/motor_world/presentation/screens/motor_world_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/roadside/presentation/screens/roadside_history_screen.dart';
import '../../features/roadside/presentation/screens/roadside_screen.dart';
import '../../features/roadside/presentation/screens/roadside_tracking_screen.dart';
import '../../features/service_centers/presentation/screens/bookings_screen.dart';
import '../../features/service_centers/presentation/screens/service_centers_screen.dart';
import '../../features/tools/domain/entities/embedded_tool.dart';
import '../../features/tools/presentation/screens/tool_webview_screen.dart';
import '../../features/tools/presentation/screens/tools_hub_screen.dart';
import '../../features/wallet/presentation/screens/recharge_screen.dart';
import '../../features/wallet/presentation/screens/transactions_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
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

      // Admin area guard (RLS also enforces this server-side).
      if (state.matchedLocation.startsWith(AppRoutes.admin)) {
        final user = ref.read(appUserProvider).valueOrNull;
        if (user != null && !user.isAdmin) return AppRoutes.home;
      }
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
      GoRoute(
        path: AppRoutes.maintenance,
        builder: (_, state) =>
            MaintenanceScreen(motorcycle: state.extra! as Motorcycle),
      ),

      // Marketplace
      GoRoute(
        path: AppRoutes.marketplace,
        builder: (_, __) => const MarketplaceScreen(),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        builder: (_, state) =>
            ProductDetailScreen(productId: state.extra! as String),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        builder: (_, __) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (_, __) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (_, __) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (_, __) => const OrdersScreen(),
      ),

      // Intelligent tools
      GoRoute(
        path: AppRoutes.tools,
        builder: (_, __) => const ToolsHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.toolView,
        builder: (_, state) =>
            ToolWebViewScreen(tool: state.extra! as EmbeddedTool),
      ),

      // AI Copilot
      GoRoute(
        path: AppRoutes.copilot,
        builder: (_, __) => const CopilotScreen(),
      ),

      // Insurance
      GoRoute(
        path: AppRoutes.insurance,
        builder: (_, __) => const InsuranceScreen(),
      ),
      GoRoute(
        path: AppRoutes.policies,
        builder: (_, __) => const PoliciesScreen(),
      ),

      // Service centers
      GoRoute(
        path: AppRoutes.serviceCenters,
        builder: (_, __) => const ServiceCentersScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookings,
        builder: (_, __) => const BookingsScreen(),
      ),

      // Roadside assistance
      GoRoute(
        path: AppRoutes.roadside,
        builder: (_, __) => const RoadsideScreen(),
      ),
      GoRoute(
        path: AppRoutes.roadsideTracking,
        builder: (_, state) =>
            RoadsideTrackingScreen(requestId: state.extra! as String),
      ),
      GoRoute(
        path: AppRoutes.roadsideHistory,
        builder: (_, __) => const RoadsideHistoryScreen(),
      ),

      // Motor World
      GoRoute(
        path: AppRoutes.motorWorld,
        builder: (_, __) => const MotorWorldScreen(),
      ),
      GoRoute(
        path: AppRoutes.newsArticle,
        builder: (_, state) =>
            ArticleDetailScreen(articleId: state.extra! as String),
      ),

      // Notifications
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),

      // Admin
      GoRoute(
        path: AppRoutes.admin,
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        builder: (_, __) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminProducts,
        builder: (_, __) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminNews,
        builder: (_, __) => const AdminNewsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminOrders,
        builder: (_, __) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminRoadside,
        builder: (_, __) => const AdminRoadsideScreen(),
      ),

      // Wallet
      GoRoute(
        path: AppRoutes.wallet,
        builder: (_, __) => const WalletScreen(),
      ),
      GoRoute(
        path: AppRoutes.walletRecharge,
        builder: (_, __) => const RechargeScreen(),
      ),
      GoRoute(
        path: AppRoutes.walletTransactions,
        builder: (_, __) => const TransactionsScreen(),
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
