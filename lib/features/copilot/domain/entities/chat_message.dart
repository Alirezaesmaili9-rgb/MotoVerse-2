import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant }

/// A single message in a Copilot conversation.
class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.isStreaming = false,
  });

  final String id;
  final ChatRole role;
  final String content;
  final DateTime createdAt;

  /// True while assistant tokens are still arriving (drives the typing dots).
  final bool isStreaming;

  bool get isUser => role == ChatRole.user;

  factory ChatMessage.user(String content) => ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: ChatRole.user,
        content: content,
        createdAt: DateTime.now(),
      );

  factory ChatMessage.assistant(String content, {bool isStreaming = false}) =>
      ChatMessage(
        id: '${DateTime.now().microsecondsSinceEpoch}-a',
        role: ChatRole.assistant,
        content: content,
        createdAt: DateTime.now(),
        isStreaming: isStreaming,
      );

  ChatMessage copyWith({String? content, bool? isStreaming}) => ChatMessage(
        id: id,
        role: role,
        content: content ?? this.content,
        createdAt: createdAt,
        isStreaming: isStreaming ?? this.isStreaming,
      );

  @override
  List<Object?> get props => [id, role, content, isStreaming];
}
