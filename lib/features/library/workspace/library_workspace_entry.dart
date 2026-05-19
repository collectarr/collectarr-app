import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

class LibraryWorkspaceEntry {
  const LibraryWorkspaceEntry({
    required this.id,
    required this.mediaType,
    required this.title,
    this.itemNumber,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.publisher,
    this.releaseDate,
    this.releaseYear,
    this.barcode,
    this.variant,
    this.isOwned = false,
    this.isWishlisted = false,
    this.hasMissingCover = false,
    this.hasMissingMetadata = false,
    this.condition,
    this.grade,
    this.pricePaidCents,
    this.currency,
    this.storageBox,
    this.seriesTitle,
    this.volumeName,
    this.volumeNumber,
    this.seasonNumber,
    this.episodeNumber,
    required this.updatedAt,
  });

  final String id;
  final String mediaType;
  final String title;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? publisher;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final bool isOwned;
  final bool isWishlisted;
  final bool hasMissingCover;
  final bool hasMissingMetadata;
  final String? condition;
  final String? grade;
  final int? pricePaidCents;
  final String? currency;
  final String? storageBox;
  final String? seriesTitle;
  final String? volumeName;
  final int? volumeNumber;
  final int? seasonNumber;
  final int? episodeNumber;
  final DateTime updatedAt;

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;
}

int compareLibraryWorkspaceEntries(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
  bool ascending,
) {
  final result = switch (column) {
    LibrarySortColumn.status => _compareBools(left.isOwned, right.isOwned),
    LibrarySortColumn.title => _compareNullableStrings(left.title, right.title),
    LibrarySortColumn.issue =>
      _compareIssueNumbers(left.itemNumber, right.itemNumber),
    LibrarySortColumn.variant =>
      _compareNullableStrings(left.variant, right.variant),
    LibrarySortColumn.publisher =>
      _compareNullableStrings(left.publisher, right.publisher),
    LibrarySortColumn.releaseDate =>
      _compareNullableDates(left.releaseDate, right.releaseDate),
    LibrarySortColumn.barcode =>
      _compareNullableStrings(left.barcode, right.barcode),
    LibrarySortColumn.grade => _compareNullableStrings(left.grade, right.grade),
    LibrarySortColumn.condition =>
      _compareNullableStrings(left.condition, right.condition),
    LibrarySortColumn.price =>
      _compareNullableInts(left.pricePaidCents, right.pricePaidCents),
    LibrarySortColumn.storageBox =>
      _compareNullableStrings(left.storageBox, right.storageBox),
    LibrarySortColumn.wishlist =>
      _compareBools(left.isWishlisted, right.isWishlisted),
    LibrarySortColumn.updated => left.updatedAt.compareTo(right.updatedAt),
  };
  if (result != 0) {
    return ascending ? result : -result;
  }
  return _compareNullableStrings(left.title, right.title);
}

int _compareIssueNumbers(String? left, String? right) {
  final leftNumber = _numericPrefixSortValue(left);
  final rightNumber = _numericPrefixSortValue(right);
  if (leftNumber != null && rightNumber != null) {
    final numeric = leftNumber.compareTo(rightNumber);
    if (numeric != 0) {
      return numeric;
    }
  }
  if (leftNumber != null) {
    return -1;
  }
  if (rightNumber != null) {
    return 1;
  }
  return _compareNullableStrings(left, right);
}

double? _numericPrefixSortValue(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final match = RegExp(r'^\s*(\d+(?:\.\d+)?)').firstMatch(value);
  return match == null ? null : double.tryParse(match.group(1)!);
}

int _compareNullableStrings(String? left, String? right) {
  final leftValue = left?.toLowerCase() ?? '';
  final rightValue = right?.toLowerCase() ?? '';
  if (leftValue.isEmpty && rightValue.isNotEmpty) {
    return 1;
  }
  if (leftValue.isNotEmpty && rightValue.isEmpty) {
    return -1;
  }
  return leftValue.compareTo(rightValue);
}

int _compareNullableInts(int? left, int? right) {
  if (left == null && right != null) {
    return 1;
  }
  if (left != null && right == null) {
    return -1;
  }
  return (left ?? 0).compareTo(right ?? 0);
}

int _compareNullableDates(DateTime? left, DateTime? right) {
  if (left == null && right != null) {
    return 1;
  }
  if (left != null && right == null) {
    return -1;
  }
  return (left ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
    right ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}

int _compareBools(bool left, bool right) {
  if (left == right) {
    return 0;
  }
  return left ? -1 : 1;
}
