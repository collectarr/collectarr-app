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

  Map<String, Object?> toFields() => {
        ..._field('title', title, (value) => value),
        ..._field('synopsis', synopsis, (value) => value),
        ..._field('publisher', publisher, (value) => value),
        ..._field('catalog_number', catalogNumber, (value) => value),
        ..._field('barcode', barcode, (value) => value),
        ..._field('cover_image_url', coverImageUrl, (value) => value),
        ..._field('release_date', releaseDate,
            (value) => value.toUtc().toIso8601String()),
        ..._field('physical_format', physicalFormat, (value) => value),
      };
}

ProviderCorrectionPatch buildMusicProviderCorrections({
  required CatalogSearchCandidate preview,
  required CatalogSearchCandidate edited,
}) {
  return ProviderCorrectionPatch(
    buildMusicReleaseCorrectionPatch(
      preview: preview,
      edited: edited,
    ).toFields(),
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

Map<String, Object?> _field<T>(
  String name,
  ProviderPatch<T> patch,
  Object? Function(T value) encode,
) {
  return switch (patch) {
    ProviderUnchanged<T>() => const <String, Object?>{},
    ProviderSetValue<T>(value: final value) => {name: encode(value)},
    ProviderClearValue<T>() => {name: null},
  };
}

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
