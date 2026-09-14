import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';

final class MusicReleaseEditDraft {
  MusicReleaseEditDraft.fromRelease(MusicRelease release)
      : original = release,
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
        coverImageUrl = release.coverImageUrl;

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
  String? coverImageUrl;

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
        coverImageUrl: _text(coverImageUrl),
        coverImageKey: original.coverImageKey,
        contributions: original.contributions,
        identifiers: original.identifiers,
        mediums: original.mediums,
        metadataJson: original.metadataJson,
      );
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
