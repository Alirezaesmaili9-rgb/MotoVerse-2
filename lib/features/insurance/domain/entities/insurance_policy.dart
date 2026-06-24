import 'package:equatable/equatable.dart';

/// Insurance products supported by MotoBimeh.
enum InsuranceKind {
  thirdParty('بیمه شخص ثالث', 'پوشش خسارت به اشخاص ثالث — اجباری طبق قانون'),
  comprehensive('بیمه بدنه', 'پوشش خسارت به موتور در تصادف و حوادث'),
  theft('بیمه سرقت', 'پوشش خسارت در صورت سرقت موتورسیکلت');

  const InsuranceKind(this.label, this.description);
  final String label;
  final String description;

  static InsuranceKind fromKey(String key) => switch (key) {
        'comprehensive' => InsuranceKind.comprehensive,
        'theft' => InsuranceKind.theft,
        _ => InsuranceKind.thirdParty,
      };

  String get key => switch (this) {
        InsuranceKind.thirdParty => 'third_party',
        InsuranceKind.comprehensive => 'comprehensive',
        InsuranceKind.theft => 'theft',
      };
}

enum PolicyStatus {
  active('فعال'),
  expired('منقضی'),
  pending('در انتظار صدور');

  const PolicyStatus(this.label);
  final String label;

  static PolicyStatus fromKey(String key) => switch (key) {
        'expired' => PolicyStatus.expired,
        'pending' => PolicyStatus.pending,
        _ => PolicyStatus.active,
      };
}

/// A purchased / in-progress insurance policy (mirrors `insurance_policies`).
class InsurancePolicy extends Equatable {
  const InsurancePolicy({
    required this.id,
    required this.motorcycleId,
    required this.kind,
    required this.status,
    this.provider,
    this.premium,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String motorcycleId;
  final InsuranceKind kind;
  final PolicyStatus status;
  final String? provider;
  final int? premium; // Toman / year
  final DateTime? startDate;
  final DateTime? endDate;

  /// Days until expiry (null if no end date). Drives renewal reminders.
  int? get daysToExpiry =>
      endDate == null ? null : endDate!.difference(DateTime.now()).inDays;

  bool get isExpiringSoon {
    final d = daysToExpiry;
    return d != null && d <= 30 && d >= 0;
  }

  @override
  List<Object?> get props =>
      [id, motorcycleId, kind, status, provider, premium, endDate];
}
