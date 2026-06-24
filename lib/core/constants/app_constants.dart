/// App-wide constants and Supabase table names (single source of truth).
class AppConstants {
  const AppConstants._();

  static const String appName = 'MotoVerse';

  // SharedPreferences keys
  static const String kThemeMode = 'mv_theme_mode';
  static const String kOnboardingDone = 'mv_onboarding_done';

  // Supabase tables
  static const String tProfiles = 'profiles';
  static const String tMotorcycles = 'motorcycles';
  static const String tMaintenanceRecords = 'maintenance_records';
  static const String tInsurancePolicies = 'insurance_policies';
  static const String tServiceCenters = 'service_centers';
  static const String tRoadsideRequests = 'roadside_requests';
  static const String tProducts = 'products';
  static const String tProductReviews = 'product_reviews';
  static const String tFavorites = 'favorites';
  static const String tCartItems = 'cart_items';
  static const String tOrders = 'orders';
  static const String tOrderItems = 'order_items';
  static const String tWalletTransactions = 'wallet_transactions';
  static const String tNewsArticles = 'news_articles';
  static const String tNotifications = 'notifications';
}
