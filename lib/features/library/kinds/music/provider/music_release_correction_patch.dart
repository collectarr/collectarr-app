import 'package:collectarr_app/features/providers/transport/provider_patch.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';

/// Typed fields that may be corrected on a Music Release.
///
/// Conversion to the admin wire map happens only in [toFields], at the HTTP
/// boundary.  Work fields and Release fields are intentionally separate
/// contracts.
final class MusicReleaseCorrectionPatch {
  const MusicReleaseCorrectionPatch({
    this.title = const ProviderPatch.unchanged(),
    this.synopsis = const ProviderPatch.unchanged(),
    this.publisher = const ProviderPatch.unchanged(),
    this.catalogNumber = const ProviderPatch.unchanged(),
    this.barcode = const ProviderPatch.unchanged(),
    this.coverImageUrl = const ProviderPatch.unchanged(),
    this.releaseDate = const ProviderPatch.unchanged(),
    this.physicalFormat = const ProviderPatch.unchanged(),
  });

  final ProviderPatch<String> title;
  final ProviderPatch<String> synopsis;
  final ProviderPatch<String> publisher;
  final ProviderPatch<String> catalogNumber;
  final ProviderPatch<String> barcode;
  final ProviderPatch<String> coverImageUrl;
  final ProviderPatch<DateTime> releaseDate;
  final ProviderPatch<String> physicalFormat;

  bool get isEmpty => [
        title,
        synopsis,
        publisher,
        catalogNumber,
        barcode,
        coverImageUrl,
        releaseDate,
        physicalFormat,
      ].every(_isUnchanged);

  Iterable<ProviderCorrectionChange> toChanges() => [
        ProviderCorrectionChange.fromPatch(
          field: 'title',
          patch: title,
          encode: (value) => value,
        ),
        ProviderCorrectionChange.fromPatch(
          field: 'synopsis',
          patch: synopsis,
          encode: (value) => value,
        ),
        ProviderCorrectionChange.fromPatch(
          field: 'publisher',
          patch: publisher,
          encode: (value) => value,
        ),
        ProviderCorrectionChange.fromPatch(
          field: 'catalog_number',
          patch: catalogNumber,
          encode: (value) => value,
        ),
        ProviderCorrectionChange.fromPatch(
          field: 'barcode',
          patch: barcode,
          encode: (value) => value,
        ),
        ProviderCorrectionChange.fromPatch(
          field: 'cover_image_url',
          patch: coverImageUrl,
          encode: (value) => value,
        ),
        ProviderCorrectionChange.fromPatch(
          field: 'release_date',
          patch: releaseDate,
          encode: (value) => value.toUtc().toIso8601String(),
        ),
        ProviderCorrectionChange.fromPatch(
          field: 'physical_format',
          patch: physicalFormat,
          encode: (value) => value,
        ),
      ];
}

ProviderCorrectionPatch buildMusicProviderCorrections({
  required CatalogSearchCandidate preview,
  required CatalogSearchCandidate edited,
}) {
  return ProviderCorrectionPatch.fromChanges(
    buildMusicReleaseCorrectionPatch(
      preview: preview,
      edited: edited,
    ).toChanges(),
  );
}

MusicReleaseCorrectionPatch buildMusicReleaseCorrectionPatch({
  required CatalogSearchCandidate preview,
  required CatalogSearchCandidate edited,
}) {
  return MusicReleaseCorrectionPatch(
    title: _stringPatch(preview.title, edited.title),
    synopsis: _stringPatch(preview.synopsis, edited.synopsis),
    publisher: _stringPatch(preview.publisher, edited.publisher),
    catalogNumber: _stringPatch(
      _musicCatalogNumber(preview),
      _musicCatalogNumber(edited),
    ),
    barcode: _stringPatch(preview.barcode, edited.barcode),
    coverImageUrl: _stringPatch(
      preview.coverImageUrl,
      edited.coverImageUrl,
    ),
    releaseDate: _datePatch(preview.releaseDate, edited.releaseDate),
    physicalFormat: _stringPatch(
      preview.physicalFormat,
      edited.physicalFormat,
    ),
  );
}

bool _isUnchanged(Object patch) => patch is ProviderUnchanged;

ProviderPatch<String> _stringPatch(String? current, String? updated) {
  if (current == updated) return const ProviderPatch.unchanged();
  return updated == null
      ? const ProviderPatch.clear()
      : ProviderPatch.set(updated);
}

ProviderPatch<DateTime> _datePatch(DateTime? current, DateTime? updated) {
  if (current == updated) return const ProviderPatch.unchanged();
  return updated == null
      ? const ProviderPatch.clear()
      : ProviderPatch.set(updated);
}

String? _musicCatalogNumber(CatalogSearchCandidate item) => item.mapTransport(
      (transport) {
        final metadata = transport.kindMetadata;
        if (metadata is MusicRelease) return metadata.catalogNumber;
        if (metadata is MusicReleaseGroup) {
          return metadata.primaryRelease?.catalogNumber;
        }
        return null;
      },
    );
