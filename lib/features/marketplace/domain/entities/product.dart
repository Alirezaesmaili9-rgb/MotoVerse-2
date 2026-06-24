import 'package:equatable/equatable.dart';

/// The two marketplace verticals. Parts are themed purple, accessories pink.
enum ProductCategory {
  parts('قطعات یدکی'),
  accessories('لوازم جانبی');

  const ProductCategory(this.label);
  final String label;

  static ProductCategory fromKey(String key) => values.firstWhere(
        (c) => c.name == key,
        orElse: () => ProductCategory.parts,
      );
}

/// A marketplace product (spare part or accessory).
class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    this.subcategory,
    this.imageUrl,
    this.rating = 0,
    this.stock = 0,
    this.description,
  });

  final String id;
  final String title;
  final ProductCategory category;
  final String? subcategory;
  final int price; // Toman
  final String? imageUrl;
  final double rating;
  final int stock;
  final String? description;

  bool get inStock => stock > 0;

  @override
  List<Object?> get props =>
      [id, title, category, subcategory, price, imageUrl, rating, stock];
}
