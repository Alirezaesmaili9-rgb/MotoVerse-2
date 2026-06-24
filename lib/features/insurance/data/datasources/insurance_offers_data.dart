import '../../domain/entities/insurance_offer.dart';
import '../../domain/entities/insurance_policy.dart';

/// Static provider catalog used to generate comparable offers. Swap for a live
/// aggregator API later — the [InsuranceOffer] shape stays the same.
class InsuranceOffersData {
  const InsuranceOffersData._();

  static const _basePremium = {
    InsuranceKind.thirdParty: 1800000,
    InsuranceKind.comprehensive: 4500000,
    InsuranceKind.theft: 2200000,
  };

  static const _providers = [
    (name: 'بیمه ایران', factor: 1.00, rating: 4.6),
    (name: 'بیمه آسیا', factor: 0.96, rating: 4.4),
    (name: 'بیمه البرز', factor: 1.04, rating: 4.5),
    (name: 'بیمه پاسارگاد', factor: 0.92, rating: 4.7),
    (name: 'بیمه دی', factor: 1.08, rating: 4.2),
  ];

  static List<InsuranceOffer> forKind(InsuranceKind kind) {
    final base = _basePremium[kind]!;
    final offers = _providers
        .map((p) => InsuranceOffer(
              provider: p.name,
              kind: kind,
              premium: (base * p.factor).round(),
              rating: p.rating,
              highlights: _highlights(kind),
            ))
        .toList()
      ..sort((a, b) => a.premium.compareTo(b.premium));
    return offers;
  }

  static List<String> _highlights(InsuranceKind kind) => switch (kind) {
        InsuranceKind.thirdParty => const [
            'پوشش قانونی اجباری',
            'صدور آنی',
            'تخفیف عدم خسارت',
          ],
        InsuranceKind.comprehensive => const [
            'پوشش تصادف و واژگونی',
            'پوشش آتش‌سوزی',
            'کارشناسی رایگان',
          ],
        InsuranceKind.theft => const [
            'پوشش سرقت کلی',
            'پوشش سرقت قطعات',
            'پرداخت سریع خسارت',
          ],
      };
}
