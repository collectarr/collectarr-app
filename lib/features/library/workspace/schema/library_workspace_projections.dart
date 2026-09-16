import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';

class WorkspaceCommonProjection {
  const WorkspaceCommonProjection({
    required this.title,
    this.synopsis,
    this.releaseDate,
    this.currency,
    this.coverImageUrl,
  });

  factory WorkspaceCommonProjection.fromStructuralShelf(
    LibraryWorkspaceSource source,
    LibraryEntityRef node, {
    String? overrideTitle,
    String? overrideSynopsis,
    DateTime? overrideReleaseDate,
    String? overrideCoverImageUrl,
  }) {
    final release = node is LibraryReleaseRef ? node.release : null;

    return WorkspaceCommonProjection(
      title: overrideTitle ?? source.title,
      synopsis: overrideSynopsis ?? source.catalogData?.synopsis,
      releaseDate: overrideReleaseDate ??
          release?.releaseDate ??
          source.catalogData?.releaseDate,
      currency: source.ownedSummary?.currency,
      coverImageUrl: overrideCoverImageUrl ??
          source.catalogSummary?.imageUrl ??
          source.catalogData?.coverImageUrl,
    );
  }

  final String title;
  final String? synopsis;
  final DateTime? releaseDate;
  final String? currency;
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
    final tracking = releaseState == null
        ? source.trackingSummary
        : releaseState.trackingSummary;
    return PersonalCopyProjection(
      isOwned: releaseState?.isOwned ?? source.isOwned,
      isWishlisted: releaseState?.isWishlisted ?? source.isWishlisted,
      isTracked: releaseState?.isTracked ?? source.isTracked,
      condition: null,
      locationPath: source.locationPath,
      trackingStatus: mediaTrackingStatusToStorageValue(tracking?.status),
      rating: tracking?.rating,
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
