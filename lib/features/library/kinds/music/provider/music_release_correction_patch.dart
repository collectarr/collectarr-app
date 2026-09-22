import 'package:collectarr_app/features/providers/transport/provider_patch.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';

/// Typed fields that may be corrected on a Music Release.
///
/// Work fields and Release fields are intentionally separate contracts. The
/// typed patch is encoded by the provider HTTP edge, never by this domain
/// object.
final class MusicReleaseCorrectionPatch implements ProviderCorrectionPatch {
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

  @override
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
}

ProviderCorrectionPatch buildMusicProviderCorrections({
  required CatalogSearchCandidate preview,
  required CatalogSearchCandidate edited,
}) {
  return buildMusicReleaseCorrectionPatch(
    preview: preview,
    edited: edited,
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

String? _musicCatalogNumber(CatalogSearchCandidate item) {
  final metadata = item.mapTransport((transport) => transport.kindMetadata);
  if (metadata is MusicRelease) return metadata.catalogNumber;
  if (metadata is MusicReleaseGroup) {
    return metadata.primaryRelease?.catalogNumber;
  }
  return null;
}
