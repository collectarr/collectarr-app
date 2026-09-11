import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';

class WorkspaceCommonProjection {
  const WorkspaceCommonProjection({
    required this.title,
    this.synopsis,
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

  factory WorkspaceCommonProjection.fromStructuralShelf(
    LibraryWorkspaceSource source,
    LibraryNodeRef node, {
    String? overrideTitle,
    DateTime? overrideReleaseDate,
    String? overrideCoverImageUrl,
  }) {
    final catalog = source.catalogTransport;
    final edition = node is LibraryReleaseNodeRef ? node.edition : null;

    return WorkspaceCommonProjection(
      title: overrideTitle ?? catalog?.displayTitle ?? catalog?.title ?? '',
      synopsis: catalog?.synopsis,
      releaseDate:
          overrideReleaseDate ?? edition?.releaseDate ?? catalog?.releaseDate,
      currency: source.ownedSummary?.currency,
      coverImageUrl: overrideCoverImageUrl ?? catalog?.coverImageUrl,
    );
  }

  final String title;
  final String? synopsis;
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
    LibraryWorkspaceSource source, {
    LibraryReleaseState? releaseState,
  }) {
    return PersonalCopyProjection(
      isOwned: releaseState?.isOwned ?? source.isOwned,
      isWishlisted: releaseState?.isWishlisted ?? source.isWishlisted,
      isTracked: releaseState?.isTracked ?? source.isTracked,
      condition: null,
      locationPath: source.locationPath,
      trackingStatus: mediaTrackingStatusToStorageValue(source.trackingStatus),
      rating: source.trackingRating,
      pricePaidCents: source.ownedSummary?.pricePaidCents,
      addedAt: source.addedAt,
      updatedAt: source.updatedAt,
      tags: null,
      collectionStatus: null,
      notes: source.ownedSummary?.notes,
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
  String? get synopsis => common.synopsis;

  /// Opaque identifier exposed to structural actions such as Copy/Scan.
  /// The concrete kind decides whether it is an ISBN, UPC, barcode, or
  /// another identifier; generic workspace code never interprets it.
  String? get identifierCode => null;
  String? get itemNumber => common.itemNumber;
  DateTime? get releaseDate => common.releaseDate;
  String? get variant => common.variant;
  String? get country => common.country;
  String? get language => common.language;
  String? get currency => common.currency;
  String? get referenceFormatLabel => common.referenceFormatLabel;
  String? get format => common.referenceFormatLabel;
}
