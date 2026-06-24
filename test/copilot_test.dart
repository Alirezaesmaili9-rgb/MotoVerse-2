import 'package:flutter_test/flutter_test.dart';
import 'package:motoverse/features/copilot/data/services/mock_ai_provider.dart';
import 'package:motoverse/features/copilot/domain/entities/chat_message.dart';
import 'package:motoverse/features/copilot/domain/entities/copilot_context.dart';

void main() {
  group('CopilotContext', () {
    test('preamble mentions the rider bike when present', () {
      const ctx = CopilotContext(bikeName: 'Honda PCX 160', mileage: 12500);
      final preamble = ctx.toSystemPreamble();
      expect(ctx.hasBike, isTrue);
      expect(preamble, contains('Honda PCX 160'));
    });

    test('no bike → still produces a system preamble', () {
      const ctx = CopilotContext();
      expect(ctx.hasBike, isFalse);
      expect(ctx.toSystemPreamble(), contains('MotoVerse'));
    });
  });

  group('MockAiProvider', () {
    const provider = MockAiProvider();

    test('is offline mock', () {
      expect(provider.isLive, isFalse);
      expect(provider.displayName, isNotEmpty);
    });

    test('streams a domain-relevant answer for an oil question', () async {
      final reply = await provider.streamReply(
        history: [ChatMessage.user('چه موقع روغن موتورم رو عوض کنم؟')],
        context: const CopilotContext(bikeName: 'Honda CG', mileage: 8000),
      ).join();
      expect(reply, contains('روغن'));
      expect(reply, isNotEmpty);
    });

    test('falls back gracefully for unknown questions', () async {
      final reply = await provider.streamReply(
        history: [ChatMessage.user('asdfghjkl')],
        context: const CopilotContext(),
      ).join();
      expect(reply.trim(), isNotEmpty);
    });
  });
}
