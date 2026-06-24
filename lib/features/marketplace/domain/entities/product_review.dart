import 'package:equatable/equatable.dart';

class ProductReview extends Equatable {
  const ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.comment,
    this.authorName,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String userId;
  final int rating; // 1..5
  final String? comment;
  final String? authorName;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, productId, userId, rating, comment, createdAt];
}
