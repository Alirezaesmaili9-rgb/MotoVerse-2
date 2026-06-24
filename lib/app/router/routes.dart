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

  // AI Copilot (globally accessible)
  static const String copilot = '/copilot';

  // Insurance (MotoBimeh)
  static const String insurance = '/insurance';
  static const String policies = '/insurance/policies';

  // Service centers
  static const String serviceCenters = '/service-centers';
  static const String bookings = '/service-centers/bookings';

  // Roadside assistance
  static const String roadside = '/roadside';
  static const String roadsideTracking = '/roadside/tracking';
  static const String roadsideHistory = '/roadside/history';

  // Motor World (news)
  static const String motorWorld = '/motor-world';
  static const String newsArticle = '/motor-world/article';

  // Notifications
  static const String notifications = '/notifications';

  // Admin
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminProducts = '/admin/products';
  static const String adminNews = '/admin/news';
  static const String adminOrders = '/admin/orders';
  static const String adminRoadside = '/admin/roadside';

  // Wallet
  static const String wallet = '/wallet';
  static const String walletRecharge = '/wallet/recharge';
  static const String walletTransactions = '/wallet/transactions';
}
