import 'package:flutter_test/flutter_test.dart';
import 'package:motoverse/features/insurance/data/datasources/insurance_offers_data.dart';
import 'package:motoverse/features/insurance/domain/entities/insurance_policy.dart';

void main() {
  group('InsuranceOffersData', () {
    test('offers are sorted cheapest first', () {
      final offers = InsuranceOffersData.forKind(InsuranceKind.thirdParty);
      expect(offers, isNotEmpty);
      for (var i = 1; i < offers.length; i++) {
        expect(offers[i].premium >= offers[i - 1].premium, isTrue);
      }
    });

    test('comprehensive premiums exceed third-party', () {
      final tp = InsuranceOffersData.forKind(InsuranceKind.thirdParty).first;
      final comp =
          InsuranceOffersData.forKind(InsuranceKind.comprehensive).first;
      expect(comp.premium, greaterThan(tp.premium));
    });
  });

  group('InsuranceKind', () {
    test('key matches DB check constraint values', () {
      expect(InsuranceKind.thirdParty.key, 'third_party');
      expect(InsuranceKind.comprehensive.key, 'comprehensive');
      expect(InsuranceKind.theft.key, 'theft');
    });
  });

  group('InsurancePolicy', () {
    test('flags expiring soon within 30 days', () {
      final p = InsurancePolicy(
        id: '1',
        motorcycleId: 'm1',
        kind: InsuranceKind.thirdParty,
        status: PolicyStatus.active,
        endDate: DateTime.now().add(const Duration(days: 10)),
      );
      expect(p.isExpiringSoon, isTrue);
    });
  });
}
