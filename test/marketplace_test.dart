import 'package:flutter_test/flutter_test.dart';
import 'package:motoverse/features/marketplace/domain/entities/cart_item.dart';
import 'package:motoverse/features/marketplace/domain/entities/order.dart';
import 'package:motoverse/features/marketplace/domain/entities/product.dart';

void main() {
  const product = Product(
    id: 'p1',
    title: 'فیلتر روغن',
    category: ProductCategory.parts,
    price: 185000,
    stock: 5,
  );

  group('CartItem', () {
    test('lineTotal multiplies price by quantity', () {
      const item = CartItem(product: product, quantity: 3);
      expect(item.lineTotal, 555000);
    });
  });

  group('Product', () {
    test('inStock reflects stock count', () {
      expect(product.inStock, isTrue);
      expect(product.copyWithStock(0).inStock, isFalse);
    });

    test('category maps from key', () {
      expect(ProductCategory.fromKey('accessories'),
          ProductCategory.accessories);
      expect(ProductCategory.fromKey('unknown'), ProductCategory.parts);
    });
  });

  group('OrderStatus', () {
    test('tracking step ordering', () {
      expect(OrderStatus.pending.step, 0);
      expect(OrderStatus.paid.step, 1);
      expect(OrderStatus.shipped.step, 2);
      expect(OrderStatus.delivered.step, 3);
      expect(OrderStatus.cancelled.step, -1);
    });

    test('maps from key with fallback', () {
      expect(OrderStatus.fromKey('shipped'), OrderStatus.shipped);
      expect(OrderStatus.fromKey('???'), OrderStatus.pending);
    });
  });
}

extension on Product {
  Product copyWithStock(int s) => Product(
        id: id,
        title: title,
        category: category,
        price: price,
        stock: s,
      );
}
