import 'package:equatable/equatable.dart';

import 'insurance_policy.dart';

/// A comparable quote from an insurance provider. For now these are generated
/// from a static provider table (no live aggregator), but the shape matches
/// what a real comparison API would return.
class InsuranceOffer extends Equatable {
  const InsuranceOffer({
    required this.provider,
    required this.kind,
    required this.premium,
    required this.rating,
    required this.highlights,
    this.instantIssue = true,
  });

  final String provider;
  final InsuranceKind kind;
  final int premium; // Toman / year
  final double rating;
  final List<String> highlights;
  final bool instantIssue;

  @override
  List<Object?> get props => [provider, kind, premium];
}
