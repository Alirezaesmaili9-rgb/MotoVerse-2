import '../../domain/entities/insurance_policy.dart';

class InsurancePolicyModel {
  const InsurancePolicyModel._();

  static InsurancePolicy fromJson(Map<String, dynamic> json) {
    return InsurancePolicy(
      id: json['id'] as String,
      motorcycleId: json['motorcycle_id'] as String,
      kind: InsuranceKind.fromKey(json['kind'] as String),
      status: PolicyStatus.fromKey(json['status'] as String),
      provider: json['provider'] as String?,
      premium: (json['premium'] as num?)?.toInt(),
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
    );
  }
}
