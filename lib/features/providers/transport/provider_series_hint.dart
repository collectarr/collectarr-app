import 'package:flutter/foundation.dart';

/// Small provider-search hint owned by the provider transport boundary.
///
/// This intentionally is not a Core catalog DTO. A provider result may carry
/// a series label and an origin year for ranking/preview, while the owning
/// kind decides how those values become catalog metadata.
@immutable
final class ProviderSeriesHint {
  const ProviderSeriesHint({
    this.seriesTitle,
    this.volumeStartYear,
  });

  factory ProviderSeriesHint.fromJson(Map<String, dynamic> json) {
    return ProviderSeriesHint(
      seriesTitle: json['series_title']?.toString(),
      volumeStartYear: _parseInt(json['volume_start_year']),
    );
  }

  final String? seriesTitle;
  final int? volumeStartYear;

  bool get hasData =>
      (seriesTitle?.trim().isNotEmpty ?? false) || volumeStartYear != null;

  Map<String, dynamic> toJson() => {
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (volumeStartYear != null) 'volume_start_year': volumeStartYear,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderSeriesHint &&
          seriesTitle == other.seriesTitle &&
          volumeStartYear == other.volumeStartYear;

  @override
  int get hashCode => Object.hash(seriesTitle, volumeStartYear);
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
