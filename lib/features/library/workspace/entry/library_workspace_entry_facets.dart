part of 'library_workspace_entry.dart';

class ComicWorkspaceDetails {
  const ComicWorkspaceDetails({
    this.rawOrSlabbed,
    this.gradingCompany,
    this.labelType,
    this.certificationNumber,
    this.keyComic = false,
    this.keyReason,
  });

  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? labelType;
  final String? certificationNumber;
  final bool keyComic;
  final String? keyReason;

  bool get hasData =>
      rawOrSlabbed != null ||
      gradingCompany != null ||
      labelType != null ||
      certificationNumber != null ||
      keyComic ||
      keyReason != null;
}

CatalogSeriesDetails? _seriesOrNull(CatalogSeriesDetails? details) {
  if (details == null) {
    return null;
  }
  return details.hasData ? details : null;
}

CatalogPublishingDetails? _publishingOrNull(CatalogPublishingDetails? details) {
  if (details == null) {
    return null;
  }
  return details.hasData ? details : null;
}

VideoCatalogDetails? _videoOrNull(VideoCatalogDetails? details) {
  if (details == null) {
    return null;
  }
  return details.hasData ? details : null;
}

MusicCatalogDetails? _musicOrNull(MusicCatalogDetails? details) {
  if (details == null) {
    return null;
  }
  return details.hasData ? details : null;
}

GameCatalogDetails? _gameOrNull(GameCatalogDetails? details) {
  if (details == null) {
    return null;
  }
  return details.hasData ? details : null;
}

ComicWorkspaceDetails? _comicOrNull({
  String? rawOrSlabbed,
  String? gradingCompany,
  String? labelType,
  String? certificationNumber,
  bool keyComic = false,
  String? keyReason,
}) {
  final details = ComicWorkspaceDetails(
    rawOrSlabbed: rawOrSlabbed,
    gradingCompany: gradingCompany,
    labelType: labelType,
    certificationNumber: certificationNumber,
    keyComic: keyComic,
    keyReason: keyReason,
  );
  return details.hasData ? details : null;
}

List<String>? _copyStringList(List<String>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.toList(growable: false);
}

List<Map<String, dynamic>>? _copyMapList(List<Map<String, dynamic>>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.toList(growable: false);
}

List<ItemImage> _copyImageList(List<ItemImage> values) {
  if (values.isEmpty) {
    return const <ItemImage>[];
  }
  return values.toList(growable: false);
}

List<CatalogEdition> _copyEditionList(List<CatalogEdition> values) {
  if (values.isEmpty) {
    return const <CatalogEdition>[];
  }
  return values.toList(growable: false);
}

List<GameRelease> _copyGameReleaseList(List<GameRelease> values) {
  if (values.isEmpty) {
    return const <GameRelease>[];
  }
  return values.toList(growable: false);
}
