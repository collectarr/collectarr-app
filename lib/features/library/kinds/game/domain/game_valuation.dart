import 'package:collectarr_app/features/library/domain/valuation_snapshot.dart';
import 'package:flutter/foundation.dart';

enum GameValuationTier {
  loose,
  cib,
  newSealed,
  graded,
  boxOnly,
  manualOnly,
}

@immutable
class GameValuationSnapshot {
  const GameValuationSnapshot({
    required this.tier,
    required this.snapshot,
  });

  final GameValuationTier tier;
  final ValuationSnapshot snapshot;

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'snapshot': snapshot.toJson(),
      };

  factory GameValuationSnapshot.fromJson(Map<String, dynamic> json) {
    final tierName = json['tier'] as String?;
    final tier = GameValuationTier.values.firstWhere(
      (e) => e.name == tierName,
      orElse: () => GameValuationTier.loose,
    );
    return GameValuationSnapshot(
      tier: tier,
      snapshot:
          ValuationSnapshot.fromJson(json['snapshot'] as Map<String, dynamic>),
    );
  }
}

@immutable
class GameValuationSet {
  const GameValuationSet({
    this.priceChartingId,
    this.loose,
    this.cib,
    this.newSealed,
    this.graded,
    this.boxOnly,
    this.manualOnly,
  });

  final String? priceChartingId;
  final ValuationSnapshot? loose;
  final ValuationSnapshot? cib;
  final ValuationSnapshot? newSealed;
  final ValuationSnapshot? graded;
  final ValuationSnapshot? boxOnly;
  final ValuationSnapshot? manualOnly;

  Map<String, dynamic> toJson() => {
        if (priceChartingId != null) 'price_charting_id': priceChartingId,
        if (loose != null) 'loose': loose!.toJson(),
        if (cib != null) 'cib': cib!.toJson(),
        if (newSealed != null) 'new_sealed': newSealed!.toJson(),
        if (graded != null) 'graded': graded!.toJson(),
        if (boxOnly != null) 'box_only': boxOnly!.toJson(),
        if (manualOnly != null) 'manual_only': manualOnly!.toJson(),
      };

  factory GameValuationSet.fromJson(Map<String, dynamic> json) {
    return GameValuationSet(
      priceChartingId: json['price_charting_id'] as String?,
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
}
