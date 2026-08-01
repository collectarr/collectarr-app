import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

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

  factory WorkspaceCommonProjection.fromShelf(
    ShelfEntry source,
    LibraryNodeRef node, {
    String? overrideTitle,
    String? overrideSeriesTitle,
    String? overridePublisher,
    DateTime? overrideReleaseDate,
    String? overrideVariant,
    String? overrideBarcode,
    String? overrideCoverImageUrl,
  }) {
    final item = source.catalogItem;
    final edition = node is LibraryReleaseNodeRef ? node.edition : null;
    CatalogVariant? primaryVariant;
    if (edition != null) {
      for (final v in edition.variants) {
        if (v.isPrimary) {
          primaryVariant = v;
          break;
        }
      }
      primaryVariant ??= edition.variants.isEmpty ? null : edition.variants.first;
    }

    return WorkspaceCommonProjection(
      title: overrideTitle ?? item?.title ?? '',
      seriesTitle: overrideSeriesTitle ?? item?.series?.seriesTitle,
      itemNumber: item?.itemNumber?.toString(),
      publisher: overridePublisher ?? edition?.publisher ?? item?.publisher,
      releaseDate: overrideReleaseDate ?? edition?.releaseDate ?? item?.releaseDate,
      variant: overrideVariant ?? primaryVariant?.name ?? edition?.title ?? item?.variant,
      barcode: overrideBarcode ?? primaryVariant?.barcode ?? edition?.upc ?? item?.barcode,
      grade: source.ownedItem?.grade,
      country: item?.country,
      language: edition?.language ?? item?.language,
      currency: source.ownedItem?.currency,
      referenceFormatLabel: primaryVariant?.physicalFormatLabel ?? edition?.physicalFormatLabel ?? item?.physicalFormatLabel,
      coverImageUrl: overrideCoverImageUrl ?? primaryVariant?.coverImageUrl ?? primaryVariant?.thumbnailImageUrl ?? item?.coverImageUrl,
    );
  }

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
    this.isTracked = false,
    this.condition,
    this.locationPath,
    this.rating,
    this.pricePaidCents,
    this.addedAt,
    DateTime? updatedAt,
    this.tags,
    this.collectionStatus,
    this.notes,
  }) : updatedAt = updatedAt ?? DateTime.utc(1970);

  factory PersonalCopyProjection.fromShelf(
    ShelfEntry source, {
    LibraryReleaseState? releaseState,
  }) {
    final owned = source.ownedItem;
    return PersonalCopyProjection(
      isOwned: releaseState?.isOwned ?? source.isOwned,
      isWishlisted: releaseState?.isWishlisted ?? source.isWishlisted,
      isTracked: releaseState?.isTracked ?? source.isTracked,
      condition: owned?.condition,
      locationPath: owned?.locationId,
      rating: owned?.rating,
      pricePaidCents: owned?.pricePaidCents,
      addedAt: owned?.createdAt,
      updatedAt: source.updatedAt,
      tags: owned?.tags,
      collectionStatus: owned?.collectionStatus,
      notes: owned?.personalNotes,
    );
  }

  final bool isOwned;
  final bool isWishlisted;
  final bool isTracked;
  final String? condition;
  final String? locationPath;
  final int? rating;
  final int? pricePaidCents;
  final DateTime? addedAt;
  final DateTime updatedAt;
  final String? tags;
  final String? collectionStatus;
  final String? notes;
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
  String? get format => common.referenceFormatLabel;
  @override
  String? get coverImageUrl => common.coverImageUrl;

  // Delegated LibraryWorkspaceDto getters from PersonalCopyProjection:
  @override
  bool get isOwned => personal.isOwned;
  @override
  bool get isWishlisted => personal.isWishlisted;
  @override
  bool get isTracked => personal.isTracked;
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
  @override
  String? get notes => personal.notes;
  @override
  int? get marketValueCents => null;
  @override
  String? get creator => publisher;
  @override
  String? get synopsis => null;
  @override
  String? get audienceRating => null;
  @override
  String? get ageRating => null;
  @override
  String? get editionLabel => null;
}
