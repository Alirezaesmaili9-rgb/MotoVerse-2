import 'package:equatable/equatable.dart';

/// A Motor World news article.
class NewsArticle extends Equatable {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.publishedAt,
    this.summary,
    this.body,
    this.coverUrl,
    this.tag,
    this.source,
  });

  final String id;
  final String title;
  final DateTime publishedAt;
  final String? summary;
  final String? body;
  final String? coverUrl;
  final String? tag;
  final String? source;

  @override
  List<Object?> get props => [id, title, publishedAt, tag];
}
