import 'package:flutter/foundation.dart';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_image_candidate.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_parent_hint.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_role.dart';

/// Kind-owned typed candidate union used by Music provider transport.
sealed class MusicProviderCandidate implements ProviderSearchCandidate {
  const MusicProviderCandidate();
}

@immutable
final class MusicTrackCandidate {
  const MusicTrackCandidate({
    required this.position,
    required this.title,
    this.durationMs,
    this.artist,
    this.recordingId,
    this.isHeader = false,
    this.indentLevel = 0,
    this.parentHeaderId,
  });

  final int position;
  final String title;
  final int? durationMs;
  final String? artist;
  final String? recordingId;
  final bool isHeader;
  final int indentLevel;
  final String? parentHeaderId;
}

@immutable
final class MusicMediumCandidate {
  const MusicMediumCandidate({
    required this.mediumNumber,
    this.format,
    this.trackCount,
    this.title,
    this.tracks = const <MusicTrackCandidate>[],
  });

  final int mediumNumber;
  final String? format;
  final int? trackCount;
  final String? title;
  final List<MusicTrackCandidate> tracks;
}

@immutable
final class MusicReleaseSummaryCandidate {
  const MusicReleaseSummaryCandidate({
    required this.providerItemId,
    required this.title,
    this.releaseDate,
    this.country,
    this.status,
    this.packaging,
    this.format,
    this.publisher,
    this.catalogNumber,
    this.barcode,
    this.images = const <ProviderImageCandidate>[],
  });

  final String providerItemId;
  final String title;
  final DateTime? releaseDate;
  final String? country;
  final String? status;
  final String? packaging;
  final String? format;
  final String? publisher;
  final String? catalogNumber;
  final String? barcode;
  final List<ProviderImageCandidate> images;
}

@immutable
final class MusicReleaseCandidate extends MusicProviderCandidate {
  const MusicReleaseCandidate({
    required this.identity,
    required this.title,
    required this.releaseGroupId,
    this.releaseGroupTitle,
    this.artist,
    this.releaseDate,
    this.country,
    this.barcode,
    this.publisher,
    this.catalogNumber,
    this.releaseType,
    this.releaseStatus,
    this.packaging,
    this.language,
    this.mediums = const <MusicMediumCandidate>[],
    this.genres = const <String>[],
    this.tags = const <String>[],
    required this.provenance,
    this.images = const <ProviderImageCandidate>[],
    this.releaseGroupImages = const <ProviderImageCandidate>[],
    this.attribution,
    this.isHydrated = false,
  });

  @override
  final ProviderEntityIdentity identity;
  @override
  final String title;
  final String? releaseGroupId;
  final String? releaseGroupTitle;
  final String? artist;
  final DateTime? releaseDate;
  final String? country;
  final String? barcode;
  final String? publisher;
  final String? catalogNumber;
  final String? releaseType;
  final String? releaseStatus;
  final String? packaging;
  final String? language;
  final List<MusicMediumCandidate> mediums;
  final List<String> genres;
  final List<String> tags;
  final ProviderProvenance provenance;
  final List<ProviderImageCandidate> images;
  final List<ProviderImageCandidate> releaseGroupImages;
  final ProviderAttribution? attribution;
  final bool isHydrated;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;
  @override
  String get provider => identity.provider;

  @override
  String get providerItemId => identity.externalId;

  @override
  String? get imageUrl => primaryImageUrl?.toString();

  @override
  ProviderSearchRole get searchRole => ProviderSearchRole.edition;

  @override
  // A Music provider result is already a concrete Catalog Item. Keep the
  // release-group ID on the candidate for provider provenance and hydration,
  // but do not expose it as a parent in Add search: that would recreate the
  // Work -> Release navigation the catalog model is removing.
  ProviderSearchParentHint? get parent => null;

  @override
  bool get previewOnly => false;

  @override
  bool get isStub => false;

  @override
  String get localCatalogId =>
      'provider:${provider.trim().toLowerCase()}:${kind.apiValue}:${Uri.encodeComponent(providerItemId)}';

  @override
  String? get summary {
    final values = <String>[];
    void add(String? value) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) values.add(trimmed);
    }

    add(artist);
    if (releaseDate case final value?) add(value.year.toString());
    final formats = mediums
        .map((medium) => medium.format?.trim())
        .whereType<String>()
        .where((format) => format.isNotEmpty)
        .toSet();
    if (formats.isNotEmpty) add(formats.join(', '));
    add(country);
    add(publisher);
    add(catalogNumber);
    add(barcode);
    return values.isEmpty ? null : values.join(' / ');
  }

  Uri? get primaryImageUrl => images.isEmpty ? null : images.first.url;
}

@immutable
final class MusicReleaseGroupCandidate extends MusicProviderCandidate {
  const MusicReleaseGroupCandidate({
    required this.identity,
    required this.title,
    this.artist,
    this.originalReleaseDate,
    this.primaryType,
    this.releases = const <MusicReleaseSummaryCandidate>[],
    this.genres = const <String>[],
    this.tags = const <String>[],
    required this.provenance,
    this.images = const <ProviderImageCandidate>[],
    this.attribution,
  });

  @override
  final ProviderEntityIdentity identity;
  @override
  final String title;
  final String? artist;
  final DateTime? originalReleaseDate;
  final String? primaryType;
  final List<MusicReleaseSummaryCandidate> releases;
  final List<String> genres;
  final List<String> tags;
  final ProviderProvenance provenance;
  final List<ProviderImageCandidate> images;
  final ProviderAttribution? attribution;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;
  @override
  String get provider => identity.provider;

  @override
  String get providerItemId => 'release-group:${identity.externalId}';

  @override
  String? get imageUrl => primaryImageUrl?.toString();

  @override
  ProviderSearchRole get searchRole => ProviderSearchRole.series;

  @override
  ProviderSearchParentHint get parent => ProviderSearchParentHint(
        id: identity.externalId,
        title: title,
      );

  @override
  bool get previewOnly => true;

  @override
  bool get isStub => false;

  @override
  String get localCatalogId =>
      'provider:${provider.trim().toLowerCase()}:${kind.apiValue}:${Uri.encodeComponent(providerItemId)}';

  @override
  String? get summary {
    final values = <String>[
      if (artist?.trim() case final value? when value.isNotEmpty) value,
      if (originalReleaseDate case final value?)
        value.toIso8601String().split('T').first,
      if (primaryType?.trim() case final value? when value.isNotEmpty) value,
      if (releases.isNotEmpty) '${releases.length} releases',
    ];
    return values.isEmpty ? null : values.join(' / ');
  }

  Uri? get primaryImageUrl => images.isEmpty ? null : images.first.url;
}
