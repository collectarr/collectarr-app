import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';

class WorkspaceCommonProjection {
  const WorkspaceCommonProjection({
    required this.title,
    this.synopsis,
    this.releaseDate,
    this.currency,
    this.coverImageUrl,
  });

  factory WorkspaceCommonProjection.fromKindPresentation(
    WorkspaceItem item,
    {
    required String title,
    String? synopsis,
    DateTime? releaseDate,
    String? coverImageUrl,
  }) {
    return WorkspaceCommonProjection(
      title: title,
      synopsis: synopsis,
      releaseDate: releaseDate,
      currency: item.entrySummary?.currency,
      coverImageUrl: coverImageUrl ?? item.presentation?.imageUrl,
    );
  }

  final String title;
  final String? synopsis;
  final DateTime? releaseDate;
  final String? currency;
  final String? coverImageUrl;
}

class PersonalEntryProjection {
  PersonalEntryProjection({
    this.isEntry = false,
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

  factory PersonalEntryProjection.fromShelf(
    WorkspaceItem item,
    PersonalOverlay personal,
  ) {
    final tracking = personal.tracking;
    final entryUpdatedAt = item.entrySummary?.updatedAt;
    final personalUpdatedAt = personal.updatedAt;
    return PersonalEntryProjection(
      isEntry: item.entrySummary != null,
      isWishlisted: personal.isWishlisted,
      isTracked: personal.isTracked,
      condition: null,
      locationPath: personal.locationPath,
      trackingStatus: mediaTrackingStatusToStorageValue(tracking?.status),
      rating: tracking?.rating,
      pricePaidCents: item.entrySummary?.pricePaidCents,
      addedAt: item.entrySummary?.createdAt ?? personal.wishlist?.createdAt,
      updatedAt: entryUpdatedAt == null ||
              !entryUpdatedAt.isAfter(personalUpdatedAt)
          ? personalUpdatedAt
          : entryUpdatedAt,
      tags: null,
      collectionStatus: null,
      notes: item.entrySummary?.notes,
    );
  }

  final bool isEntry;
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
