import '../../domain/entities/news_article.dart';

class NewsArticleModel {
  const NewsArticleModel._();

  static NewsArticle fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
      summary: json['summary'] as String?,
      body: json['body'] as String?,
      coverUrl: json['cover_url'] as String?,
      tag: json['tag'] as String?,
      source: json['source'] as String?,
    );
  }
}
