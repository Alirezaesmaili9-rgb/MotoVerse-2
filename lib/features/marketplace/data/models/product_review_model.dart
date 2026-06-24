import '../../domain/entities/product_review.dart';

class ProductReviewModel {
  const ProductReviewModel._();

  static ProductReview fromJson(Map<String, dynamic> json) {
    // `profiles` is joined as a nested object when available.
    final profile = json['profiles'] as Map<String, dynamic>?;
    return ProductReview(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      authorName: profile?['full_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
