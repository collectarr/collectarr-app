import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_box_set_membership.dart';

final class MusicReleaseEditDraft {
  MusicReleaseEditDraft.fromRelease(
    MusicRelease release, {
    TrackingSummary? trackingSummary,
  })  : original = release,
        title = release.title,
        sortTitle = release.sortTitle,
        subtitle = release.subtitle,
        releaseType = release.releaseType,
        releaseStatus = release.releaseStatus,
        releaseDate = release.releaseDate,
        publisher = release.publisher,
        countryCode = release.countryCode,
        language = release.language,
        barcode = release.barcode,
        upc = release.upc,
        catalogNumber = release.catalogNumber,
        packaging = release.packaging,
        physicalFormat = release.physicalFormat,
        physicalFormatLabel = release.physicalFormatLabel,
        coverImageUrl = release.coverImageUrl,
        externalLinks = List.of(release.externalLinks),
        boxSetMembership = release.boxSetMembership,
        trackingStatus = trackingSummary?.statusStorageValue,
        trackingRating = trackingSummary?.rating,
        trackingNotes = trackingSummary?.notes,
        _trackingSummary = trackingSummary;

  final MusicRelease original;
  String title;
  String? sortTitle;
  String? subtitle;
  String? releaseType;
  String? releaseStatus;
  DateTime? releaseDate;
  String? publisher;
  String? countryCode;
  String? language;
  String? barcode;
  String? upc;
  String? catalogNumber;
  String? packaging;
  String? physicalFormat;
  String? physicalFormatLabel;
  String? coverImageUrl;
  List<MusicExternalLink> externalLinks;
  MusicBoxSetMembership? boxSetMembership;

  String? trackingStatus;
  int? trackingRating;
  String? trackingNotes;

  final TrackingSummary? _trackingSummary;

  bool get hasTrackingEdits =>
      _trackingSummary != null ||
      trackingStatus != null ||
      trackingRating != null ||
      trackingNotes != null;

  LibraryTrackingEditSelection? trackingSelection(
    CatalogEntityRef targetRef,
  ) {
    if (!hasTrackingEdits) return null;
    return LibraryTrackingEditSelection(
      targetRef: targetRef,
      rating: trackingRating,
      readStatus: _text(trackingStatus),
      notes: _text(trackingNotes),
    );
  }

  MusicRelease toRelease() => MusicRelease(
        id: original.id,
        releaseGroupId: original.releaseGroupId,
        title: title.trim(),
        sortTitle: _text(sortTitle),
        subtitle: _text(subtitle),
        releaseType: _text(releaseType),
        releaseStatus: _text(releaseStatus),
        releaseDate: releaseDate,
        publisher: _text(publisher),
        countryCode: _text(countryCode),
        language: _text(language),
        barcode: _text(barcode),
        upc: _text(upc),
        catalogNumber: _text(catalogNumber),
        packaging: _text(packaging),
        physicalFormat: _text(physicalFormat),
        physicalFormatLabel: _text(physicalFormatLabel),
        coverImageUrl: _text(coverImageUrl),
        coverImageKey: original.coverImageKey,
        externalLinks: List.unmodifiable(externalLinks),
        boxSetMembership: boxSetMembership,
        createdAt: original.createdAt,
        updatedAt: original.updatedAt,
        contributions: original.contributions,
        identifiers: original.identifiers,
        mediums: original.mediums,
        boxSetName: original.boxSetName,
      );
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
