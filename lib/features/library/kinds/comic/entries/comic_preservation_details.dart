import 'package:flutter/foundation.dart';

@immutable
class ComicPreservationDetails {
  const ComicPreservationDetails({
    this.keyComic = false,
    this.keyReason,
    this.keyCategory,
    this.keySeverity,
    this.coverPriceCents,
    this.lastBagBoardDate,
  });

  final bool keyComic;
  final String? keyReason;
  final String? keyCategory;
  final String? keySeverity;
  final int? coverPriceCents;
  final DateTime? lastBagBoardDate;

  Map<String, dynamic> toJson() => {
        'key_comic': keyComic,
        if (keyReason != null) 'key_reason': keyReason,
        if (keyCategory != null) 'key_category': keyCategory,
        if (keySeverity != null) 'key_severity': keySeverity,
        if (coverPriceCents != null) 'cover_price_cents': coverPriceCents,
        if (lastBagBoardDate != null)
          'last_bag_board_date': lastBagBoardDate!.toUtc().toIso8601String(),
      };

  factory ComicPreservationDetails.fromJson(Map<String, dynamic> json) {
    return ComicPreservationDetails(
      keyComic: json['key_comic'] as bool? ?? false,
      keyReason: json['key_reason'] as String?,
      keyCategory: json['key_category'] as String?,
      keySeverity: json['key_severity'] as String?,
      coverPriceCents: json['cover_price_cents'] as int?,
      lastBagBoardDate: json['last_bag_board_date'] == null
          ? null
          : DateTime.parse(json['last_bag_board_date'] as String),
    );
  }

  ComicPreservationDetails copyWith({
    bool? keyComic,
    String? keyReason,
    String? keyCategory,
    String? keySeverity,
    int? coverPriceCents,
    DateTime? lastBagBoardDate,
  }) {
    return ComicPreservationDetails(
      keyComic: keyComic ?? this.keyComic,
      keyReason: keyReason ?? this.keyReason,
      keyCategory: keyCategory ?? this.keyCategory,
      keySeverity: keySeverity ?? this.keySeverity,
      coverPriceCents: coverPriceCents ?? this.coverPriceCents,
      lastBagBoardDate: lastBagBoardDate ?? this.lastBagBoardDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComicPreservationDetails &&
          runtimeType == other.runtimeType &&
          keyComic == other.keyComic &&
          keyReason == other.keyReason &&
          keyCategory == other.keyCategory &&
          keySeverity == other.keySeverity &&
          coverPriceCents == other.coverPriceCents &&
          lastBagBoardDate == other.lastBagBoardDate;

  @override
  int get hashCode => Object.hash(
        keyComic,
        keyReason,
        keyCategory,
        keySeverity,
        coverPriceCents,
        lastBagBoardDate,
      );
}
