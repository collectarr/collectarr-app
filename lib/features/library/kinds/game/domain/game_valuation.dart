import 'package:collectarr_app/features/library/domain/valuation_snapshot.dart';
import 'package:flutter/foundation.dart';

/// User-owned valuation amounts recorded for one Game library entry.
@immutable
class GameValuationSet {
  const GameValuationSet({
    this.loose,
    this.cib,
    this.newSealed,
    this.graded,
    this.boxOnly,
    this.manualOnly,
  });

  final ValuationSnapshot? loose;
  final ValuationSnapshot? cib;
  final ValuationSnapshot? newSealed;
  final ValuationSnapshot? graded;
  final ValuationSnapshot? boxOnly;
  final ValuationSnapshot? manualOnly;

  Map<String, dynamic> toJson() => {
        if (loose != null) 'loose': loose!.toJson(),
        if (cib != null) 'cib': cib!.toJson(),
        if (newSealed != null) 'new_sealed': newSealed!.toJson(),
        if (graded != null) 'graded': graded!.toJson(),
        if (boxOnly != null) 'box_only': boxOnly!.toJson(),
        if (manualOnly != null) 'manual_only': manualOnly!.toJson(),
      };

  factory GameValuationSet.fromJson(Map<String, dynamic> json) {
    return GameValuationSet(
      loose: json['loose'] != null
          ? ValuationSnapshot.fromJson(json['loose'] as Map<String, dynamic>)
          : null,
      cib: json['cib'] != null
          ? ValuationSnapshot.fromJson(json['cib'] as Map<String, dynamic>)
          : null,
      newSealed: json['new_sealed'] != null
          ? ValuationSnapshot.fromJson(
              json['new_sealed'] as Map<String, dynamic>)
          : null,
      graded: json['graded'] != null
          ? ValuationSnapshot.fromJson(json['graded'] as Map<String, dynamic>)
          : null,
      boxOnly: json['box_only'] != null
          ? ValuationSnapshot.fromJson(json['box_only'] as Map<String, dynamic>)
          : null,
      manualOnly: json['manual_only'] != null
          ? ValuationSnapshot.fromJson(
              json['manual_only'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameValuationSet &&
          _sameValuation(loose, other.loose) &&
          _sameValuation(cib, other.cib) &&
          _sameValuation(newSealed, other.newSealed) &&
          _sameValuation(graded, other.graded) &&
          _sameValuation(boxOnly, other.boxOnly) &&
          _sameValuation(manualOnly, other.manualOnly);

  @override
  int get hashCode => Object.hash(
        _valuationHash(loose),
        _valuationHash(cib),
        _valuationHash(newSealed),
        _valuationHash(graded),
        _valuationHash(boxOnly),
        _valuationHash(manualOnly),
      );
}

bool _sameValuation(ValuationSnapshot? left, ValuationSnapshot? right) =>
    left == null
        ? right == null
        : right != null &&
            left.source == right.source &&
            left.amountCents == right.amountCents &&
            left.currency == right.currency &&
            left.gradeOrCondition == right.gradeOrCondition &&
            left.capturedAt == right.capturedAt;

int _valuationHash(ValuationSnapshot? value) => value == null
    ? 0
    : Object.hash(
        value.source,
        value.amountCents,
        value.currency,
        value.gradeOrCondition,
        value.capturedAt,
      );
