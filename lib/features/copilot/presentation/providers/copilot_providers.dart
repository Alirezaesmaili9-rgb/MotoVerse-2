import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/persian_utils.dart';
import '../../../garage/presentation/providers/garage_providers.dart';
import '../../../maintenance/presentation/providers/maintenance_providers.dart';
import '../../data/services/mock_ai_provider.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/copilot_context.dart';
import '../../domain/services/ai_provider.dart';

/// Swappable AI backend. Override this to plug in Claude / OpenAI / etc.
final aiProviderProvider = Provider<AiProvider>((ref) {
  return const MockAiProvider();
});

/// Grounding context derived from the rider's garage + maintenance state.
final copilotContextProvider = Provider<CopilotContext>((ref) {
  final bike = ref.watch(primaryMotorcycleProvider);
  final next = ref.watch(nextMaintenanceProvider);
  return CopilotContext(
    bikeName: bike?.displayName,
    productionYear: bike?.productionYear,
    mileage: bike?.mileage,
    nextServiceLabel: next?.type.label,
    nextServiceMessage:
        next != null ? PersianUtils.toFa(next.message) : null,
  );
});

/// Holds the conversation and drives streaming replies.
final chatControllerProvider =
    NotifierProvider<ChatController, List<ChatMessage>>(ChatController.new);

class ChatController extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => [
        ChatMessage.assistant(
          'سلام! من موتو‌کوپایلت هستم 🏍️ دستیار هوشمند موتورت. '
          'درباره نگهداری، عیب‌یابی، بیمه، قیمت یا خرید هر سوالی داری بپرس.',
        ),
      ];

  bool get isResponding =>
      state.isNotEmpty && state.last.isStreaming;

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isResponding) return;

    final placeholder = ChatMessage.assistant('', isStreaming: true);
    state = [...state, ChatMessage.user(trimmed), placeholder];

    final provider = ref.read(aiProviderProvider);
    final context = ref.read(copilotContextProvider);
    final buffer = StringBuffer();

    try {
      await for (final delta in provider.streamReply(
        history: state.where((m) => !m.isStreaming).toList(),
        context: context,
      )) {
        buffer.write(delta);
        _updateLast(placeholder.copyWith(content: buffer.toString()));
      }
      _updateLast(
        placeholder.copyWith(content: buffer.toString(), isStreaming: false),
      );
    } catch (_) {
      _updateLast(placeholder.copyWith(
        content: 'متأسفم، در پاسخ‌گویی مشکلی پیش آمد. دوباره تلاش کن.',
        isStreaming: false,
      ));
    }
  }

  void _updateLast(ChatMessage message) {
    state = [...state.sublist(0, state.length - 1), message];
  }

  void reset() => state = build();
}

/// Suggested starter prompts shown when the conversation is fresh.
const copilotSuggestions = <String>[
  'چه موقع روغن موتورم رو عوض کنم؟',
  'موتورم روشن نمی‌شه، چیکار کنم؟',
  'بیمه شخص ثالث چطوری بگیرم؟',
  'قیمت موتورم چنده؟',
];
