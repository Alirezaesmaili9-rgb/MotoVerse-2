/// Aggregated counts shown on the admin dashboard.
class AdminStats {
  const AdminStats({
    this.users = 0,
    this.products = 0,
    this.orders = 0,
    this.revenue = 0,
    this.activeRoadside = 0,
    this.pendingBookings = 0,
    this.policies = 0,
    this.news = 0,
  });

  final int users;
  final int products;
  final int orders;
  final int revenue; // Toman, from paid+ orders
  final int activeRoadside;
  final int pendingBookings;
  final int policies;
  final int news;
}
