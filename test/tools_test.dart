import 'package:flutter_test/flutter_test.dart';
import 'package:motoverse/features/garage/domain/entities/motorcycle.dart';
import 'package:motoverse/features/tools/domain/entities/embedded_tool.dart';
import 'package:motoverse/features/tools/domain/entities/tool_context.dart';

void main() {
  group('EmbeddedTool', () {
    test('maps from id with fallback', () {
      expect(EmbeddedTool.fromId('motosanj'), EmbeddedTool.motosanj);
      expect(EmbeddedTool.fromId('mototype'), EmbeddedTool.mototype);
      expect(EmbeddedTool.fromId('???'), EmbeddedTool.motofix);
    });

    test('each tool points at a bundled asset', () {
      for (final t in EmbeddedTool.values) {
        expect(t.assetPath, startsWith('assets/tools/'));
        expect(t.assetPath, endsWith('.html'));
      }
    });
  });

  group('ToolContext', () {
    test('builds from a motorcycle', () {
      const bike = Motorcycle(
        id: 'm1',
        ownerId: 'u1',
        brand: 'Honda',
        model: 'PCX 160',
        productionYear: 1402,
        engineCc: 160,
        mileage: 12500,
      );
      final json = ToolContext.fromMotorcycle(bike).toJson();
      expect(json['brand'], 'Honda');
      expect(json['model'], 'PCX 160');
      expect(json['mileage'], 12500);
      expect(json['app'], 'MotoVerse');
    });

    test('empty context when no motorcycle', () {
      final json = ToolContext.fromMotorcycle(null).toJson();
      expect(json['brand'], isNull);
      expect(json['locale'], 'fa');
    });
  });
}
