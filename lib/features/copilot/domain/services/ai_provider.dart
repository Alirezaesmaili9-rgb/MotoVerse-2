import '../entities/chat_message.dart';
import '../entities/copilot_context.dart';

/// Provider-agnostic AI abstraction for the Copilot.
///
/// Mirrors the payment-gateway pattern: the Copilot UI/controller depends only
/// on this interface. Swap the mock for Claude / OpenAI / a self-hosted model
/// by providing a new implementation and overriding `aiProviderProvider` — no
/// UI or controller changes required.
abstract interface class AiProvider {
  /// Human-readable provider name (shown in the Copilot header).
  String get displayName;

  /// Whether this provider talks to a real backend (vs. the offline mock).
  bool get isLive;

  /// Streams the assistant reply as incremental text deltas (tokens/chunks).
  /// [history] is the full conversation so far (last item is the user's
  /// message); [context] grounds the answer in the rider's bike.
  Stream<String> streamReply({
    required List<ChatMessage> history,
    required CopilotContext context,
  });
}

/// Optional configuration a live provider needs. Read from `Env` / secure
/// storage when a real backend is wired in.
class AiProviderConfig {
  const AiProviderConfig({
    this.apiKey = '',
    this.model = '',
    this.baseUrl = '',
  });

  final String apiKey;
  final String model;
  final String baseUrl;

  bool get isConfigured => apiKey.isNotEmpty;
}
