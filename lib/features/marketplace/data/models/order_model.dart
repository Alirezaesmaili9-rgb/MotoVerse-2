import '../../domain/entities/order.dart';

class OrderModel {
  const OrderModel._();

  static MarketOrder fromJson(Map<String, dynamic> json) {
    final rawItems = (json['order_items'] as List?) ?? const [];
    final lines = rawItems.map((e) {
      final item = e as Map<String, dynamic>;
      final product = item['products'] as Map<String, dynamic>?;
      return OrderLine(
        title: product?['title'] as String? ?? 'محصول',
        quantity: (item['quantity'] as num).toInt(),
        unitPrice: (item['unit_price'] as num).toInt(),
        imageUrl: product?['image_url'] as String?,
      );
    }).toList();

    return MarketOrder(
      id: json['id'] as String,
      total: (json['total'] as num).toInt(),
      status: OrderStatus.fromKey(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      lines: lines,
    );
  }
}
