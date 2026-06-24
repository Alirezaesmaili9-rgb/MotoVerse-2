import 'package:equatable/equatable.dart';

/// Order lifecycle states (mirrors the `orders.status` check constraint).
enum OrderStatus {
  pending('در انتظار پرداخت'),
  paid('پرداخت شده'),
  shipped('ارسال شده'),
  delivered('تحویل شده'),
  cancelled('لغو شده');

  const OrderStatus(this.label);
  final String label;

  static OrderStatus fromKey(String key) => values.firstWhere(
        (s) => s.name == key,
        orElse: () => OrderStatus.pending,
      );

  /// Progress step index for the tracking timeline (cancelled → -1).
  int get step => switch (this) {
        OrderStatus.pending => 0,
        OrderStatus.paid => 1,
        OrderStatus.shipped => 2,
        OrderStatus.delivered => 3,
        OrderStatus.cancelled => -1,
      };
}

class OrderLine extends Equatable {
  const OrderLine({
    required this.title,
    required this.quantity,
    required this.unitPrice,
    this.imageUrl,
  });

  final String title;
  final int quantity;
  final int unitPrice;
  final String? imageUrl;

  int get lineTotal => unitPrice * quantity;

  @override
  List<Object?> get props => [title, quantity, unitPrice];
}

class MarketOrder extends Equatable {
  const MarketOrder({
    required this.id,
    required this.total,
    required this.status,
    required this.createdAt,
    this.lines = const [],
  });

  final String id;
  final int total;
  final OrderStatus status;
  final DateTime createdAt;
  final List<OrderLine> lines;

  String get shortId => id.substring(0, 8).toUpperCase();

  @override
  List<Object?> get props => [id, total, status, createdAt, lines];
}
