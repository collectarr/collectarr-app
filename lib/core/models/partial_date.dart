import 'package:flutter/foundation.dart';

/// A date with independently optional calendar components.
///
/// Catalog metadata may know only a year, only a month/day supplied by a
/// provider, or no component at all. The object form is therefore canonical;
/// ISO strings are accepted as a convenience for the usual year, year-month,
/// and full-date cases.
@immutable
final class PartialDate {
  const PartialDate({this.year, this.month, this.day})
      : assert(year == null || (year >= 1 && year <= 9999)),
        assert(month == null || (month >= 1 && month <= 12)),
        assert(day == null || (day >= 1 && day <= 31));

  final int? year;
  final int? month;
  final int? day;

  bool get isEmpty => year == null && month == null && day == null;
  bool get hasYear => year != null;
  bool get hasMonth => month != null;
  bool get hasDay => day != null;
  bool get isFullDate => year != null && month != null && day != null;

  /// A safe projection for consumers that require an exact [DateTime].
  /// Partial values intentionally return null instead of inventing a day.
  DateTime? get asDateTime {
    if (!isFullDate) return null;
    final value = DateTime.utc(year!, month!, day!);
    return value.year == year && value.month == month && value.day == day
        ? value
        : null;
  }

  String? get isoString {
    if (isEmpty || year == null) return null;
    final yearText = year!.toString().padLeft(4, '0');
    if (month == null) return yearText;
    final monthText = month!.toString().padLeft(2, '0');
    if (day == null) return '$yearText-$monthText';
    return '$yearText-$monthText-${day!.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        if (year != null) 'year': year,
        if (month != null) 'month': month,
        if (day != null) 'day': day,
      };

  factory PartialDate.fromDateTime(DateTime value) => PartialDate(
        year: value.year,
        month: value.month,
        day: value.day,
      );

  factory PartialDate.fromJson(Object? value) {
    if (value is DateTime) return PartialDate.fromDateTime(value);
    if (value is Map) {
      return PartialDate(
        year: _int(value['year']),
        month: _int(value['month']),
        day: _int(value['day']),
      );
    }
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return const PartialDate();
    final match =
        RegExp(r'^(\d{4})(?:-(\d{2})(?:-(\d{2}))?)?$').firstMatch(raw);
    if (match == null) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return PartialDate.fromDateTime(parsed);
      throw const FormatException('Invalid partial date');
    }
    return PartialDate(
      year: int.parse(match.group(1)!),
      month: match.group(2) == null ? null : int.parse(match.group(2)!),
      day: match.group(3) == null ? null : int.parse(match.group(3)!),
    );
  }

  static PartialDate? tryParse(Object? value) {
    try {
      final parsed = PartialDate.fromJson(value);
      return parsed.isEmpty ? null : parsed;
    } on FormatException {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartialDate &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => isoString ?? toJson().toString();
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}
