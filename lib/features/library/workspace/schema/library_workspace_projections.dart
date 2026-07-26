import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

// Epoch DateTime used as default updatedAt sentinel.
const _kEpoch = Duration.zero;

class WorkspaceCommonProjection {
  const WorkspaceCommonProjection({
    required this.title,
    this.seriesTitle,
    this.itemNumber,
    this.publisher,
    this.releaseDate,
    this.variant,
    this.barcode,
    this.grade,
    this.country,
    this.language,
    this.currency,
    this.referenceFormatLabel,
    this.coverImageUrl,
  });

  final String title;
  final String? seriesTitle;
  final String? itemNumber;
  final String? publisher;
  final DateTime? releaseDate;
  final String? variant;
  final String? barcode;
  final String? grade;
  final String? country;
  final String? language;
  final String? currency;
  final String? referenceFormatLabel;
  final String? coverImageUrl;
}

class PersonalCopyProjection {
  PersonalCopyProjection({
    this.isOwned = false,
    this.isWishlisted = false,
    this.condition,
    this.locationPath,
    this.rating,
    this.pricePaidCents,
    this.addedAt,
    DateTime? updatedAt,
    this.tags,
    this.collectionStatus,
  }) : updatedAt = updatedAt ?? DateTime.utc(1970);

  final bool isOwned;
  final bool isWishlisted;
  final String? condition;
  final String? locationPath;
  final int? rating;
  final int? pricePaidCents;
  final DateTime? addedAt;
  final DateTime updatedAt;
  final String? tags;
  final String? collectionStatus;
}

/// Abstract base adapter for Workspace DTOs implementing standard [LibraryWorkspaceDto] getters
/// by delegating to [common] and [personal] projections.
abstract class WorkspaceDtoAdapter implements LibraryWorkspaceDto {
  WorkspaceDtoAdapter();

  WorkspaceCommonProjection get common;
  PersonalCopyProjection get personal;

  // Delegated LibraryWorkspaceDto getters from WorkspaceCommonProjection:
  @override
  String get title => common.title;
  @override
  String? get seriesTitle => common.seriesTitle;
  @override
  String? get itemNumber => common.itemNumber;
  @override
  String? get publisher => common.publisher;
  @override
  DateTime? get releaseDate => common.releaseDate;
  @override
  String? get variant => common.variant;
  @override
  String? get barcode => common.barcode;
  @override
  String? get grade => common.grade;
  @override
  String? get country => common.country;
  @override
  String? get language => common.language;
  @override
  String? get currency => common.currency;
  @override
  String? get referenceFormatLabel => common.referenceFormatLabel;
  @override
  String? get coverImageUrl => common.coverImageUrl;

  // Delegated LibraryWorkspaceDto getters from PersonalCopyProjection:
  @override
  bool get isOwned => personal.isOwned;
  @override
  bool get isWishlisted => personal.isWishlisted;
  @override
  String? get condition => personal.condition;
  @override
  String? get locationPath => personal.locationPath;
  @override
  int? get rating => personal.rating;
  @override
  int? get pricePaidCents => personal.pricePaidCents;
  @override
  DateTime? get addedAt => personal.addedAt;
  @override
  DateTime get updatedAt => personal.updatedAt;
  @override
  String? get tags => personal.tags;
  @override
  String? get collectionStatus => personal.collectionStatus;
}
