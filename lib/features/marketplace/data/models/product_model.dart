import '../../domain/entities/product.dart';

class ProductModel {
  const ProductModel._();

  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      category: ProductCategory.fromKey(json['category'] as String),
      subcategory: json['subcategory'] as String?,
      price: (json['price'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
    );
  }
}
