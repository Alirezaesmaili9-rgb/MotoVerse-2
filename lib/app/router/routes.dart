/// Centralized route paths.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/login/otp';
  static const String home = '/home';
  static const String garage = '/garage';
  static const String maintenance = '/garage/maintenance';

  // Marketplace
  static const String marketplace = '/marketplace';
  static const String productDetail = '/marketplace/product';
  static const String favorites = '/marketplace/favorites';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';

  // Intelligent tools (embedded HTML via WebView)
  static const String tools = '/tools';
  static const String toolView = '/tools/view';

  // Wallet
  static const String wallet = '/wallet';
  static const String walletRecharge = '/wallet/recharge';
  static const String walletTransactions = '/wallet/transactions';
}
