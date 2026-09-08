import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';

class WorkspaceCommonProjection {
  const WorkspaceCommonProjection({
    required this.title,
    this.seriesTitle,
    this.itemNumber,
    this.releaseDate,
    this.variant,
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
    DateTime? overrideReleaseDate,
    String? overrideVariant,
    String? overrideCoverImageUrl,
  }) {
    final catalog = source.catalogItem;
    final edition = node is LibraryReleaseNodeRef ? node.edition : null;
    CatalogVariantDto? primaryVariant;
    if (edition != null) {
      for (final v in edition.variants) {
        if (v.isPrimary) {
          primaryVariant = v;
          break;
        }
      }
      primaryVariant ??=
          edition.variants.isEmpty ? null : edition.variants.first;
    }

    final payload = catalog?.payload ?? const {};
    final rawSeries = payload['series'];
    final seriesMap = rawSeries is Map ? rawSeries : null;

    return WorkspaceCommonProjection(
      title: overrideTitle ?? catalog?.displayTitle ?? catalog?.title ?? '',
      seriesTitle: overrideSeriesTitle ??
          (seriesMap?['series_title'] ??
                  seriesMap?['seriesTitle'] ??
                  (rawSeries is String ? rawSeries : null) ??
                  payload['series_title'] ??
                  payload['seriesTitle'])
              ?.toString(),
      itemNumber: (payload['item_number'] ?? payload['itemNumber'])?.toString(),
      releaseDate:
          overrideReleaseDate ?? edition?.releaseDate ?? catalog?.releaseDate,
      variant: overrideVariant ??
          primaryVariant?.name ??
          edition?.title ??
          payload['variant']?.toString(),
      country: (payload['country'] ??
              (payload['publishing'] as Map?)?['original_country'])
          ?.toString(),
      language: edition?.language ??
          (payload['language'] ??
                  (payload['publishing'] as Map?)?['original_language'])
              ?.toString(),
      currency: source.ownedItem?.currency,
      referenceFormatLabel: primaryVariant?.physicalFormat ??
          edition?.format ??
          (payload['physical_format_label'] ?? payload['physical_format'])
              ?.toString(),
      coverImageUrl: overrideCoverImageUrl ??
          primaryVariant?.coverImageUrl ??
          primaryVariant?.thumbnailImageUrl ??
          catalog?.coverImageUrl,
    );
  }

  final String title;
  final String? seriesTitle;
  final String? itemNumber;
  final DateTime? releaseDate;
  final String? variant;
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
    this.trackingStatus,
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
    final tracking = source.trackingEntry;
    return PersonalCopyProjection(
      isOwned: releaseState?.isOwned ?? source.isOwned,
      isWishlisted: releaseState?.isWishlisted ?? source.isWishlisted,
      isTracked: releaseState?.isTracked ?? source.isTracked,
      condition: owned?.condition,
      locationPath: owned?.locationId,
      trackingStatus: tracking?.statusStorageValue,
      rating: tracking?.rating,
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
  final String? trackingStatus;
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

  @override
  Iterable<String> get searchTokens => const <String>[];

  @override
  String get title => common.title;

  @override
  String? get coverImageUrl => common.coverImageUrl;

  String? get seriesTitle => common.seriesTitle;
  String? get itemNumber => common.itemNumber;
  DateTime? get releaseDate => common.releaseDate;
  String? get variant => common.variant;
  String? get country => common.country;
  String? get language => common.language;
  String? get currency => common.currency;
  String? get referenceFormatLabel => common.referenceFormatLabel;
  String? get format => common.referenceFormatLabel;
}
