import 'package:flutter/foundation.dart';

enum ValuationSource {
  covrPrice,
  priceCharting,
  manual,
  other,
}

@immutable
final class ValuationSnapshot {
  const ValuationSnapshot({
    required this.source,
    required this.amountCents,
    this.currency = 'USD',
    this.gradeOrCondition,
    required this.capturedAt,
  });

  final ValuationSource source;
  final int amountCents;
  final String currency;
  final String? gradeOrCondition;
  final DateTime capturedAt;

  Map<String, dynamic> toJson() => {
        'source': source.name,
        'amount_cents': amountCents,
        'currency': currency,
        if (gradeOrCondition != null) 'grade_or_condition': gradeOrCondition,
        'captured_at': capturedAt.toIso8601String(),
      };

  factory ValuationSnapshot.fromJson(Map<String, dynamic> json) {
    final sourceName = json['source'] as String?;
    final source = ValuationSource.values.firstWhere(
      (e) => e.name == sourceName,
      orElse: () => ValuationSource.other,
    );
    return ValuationSnapshot(
      source: source,
      amountCents: json['amount_cents'] as int? ?? 0,
      currency: (json['currency'] as String?) ?? 'USD',
      gradeOrCondition: json['grade_or_condition'] as String?,
      capturedAt: json['captured_at'] != null
          ? DateTime.parse(json['captured_at'] as String)
          : DateTime.now(),
    );
  }
}
