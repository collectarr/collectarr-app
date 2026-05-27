import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/anime/presentation.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/presentation.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/kinds/game/presentation.dart';
import 'package:collectarr_app/features/library/kinds/generic/presentation.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation.dart';
import 'package:collectarr_app/features/library/kinds/movie/presentation.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/shared/edit_presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/tv/presentation.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

LibraryTypeConfig buildRuntimeCatalogLibraryTypeConfig(CatalogMediaType type) {
  final normalizedType = normalizeCatalogMediaTypeDefaults(type);
  final mediaKind = catalogMediaKindFromApiValue(normalizedType.kind);
  final presentation = _presentationForCatalogKind(normalizedType.kind);
  final editPresentation = _editPresentationForCatalogKind(normalizedType.kind);
  return LibraryTypeConfig(
    workspace: LibraryWorkspaceConfig(
      kind: mediaKind,
      title: _runtimeCatalogDisplayLabel(
        normalizedType.pluralLabel,
        normalizedType.kind,
        plural: true,
      ),
      icon: libraryIconForKind(mediaKind),
      preferencePrefix: 'catalog_${normalizedType.kind}',
      defaultSortColumn: LibrarySortColumn.title,
      defaultVisibleColumns: presentation.defaultVisibleColumns,
    ),
    singularLabel: _runtimeCatalogDisplayLabel(
      normalizedType.singularLabel,
      normalizedType.kind,
    ),
    pluralLabel: _runtimeCatalogDisplayLabel(
      normalizedType.pluralLabel,
      normalizedType.kind,
      plural: true,
    ),
    defaultMetadataProvider: normalizedType.defaultProvider ??
        (normalizedType.providers.isEmpty ? '' : normalizedType.providers.first),
    metadataProviders: _resolveRuntimeMetadataProviders(normalizedType),
    trackingProfile: catalogTrackingProfileForKind(mediaKind),
    presentation: presentation,
    editPresentation: editPresentation,
  );
}

List<LibraryMetadataProviderOption> _resolveRuntimeMetadataProviders(
  CatalogMediaType type,
) {
  return [
    for (final providerId in type.providers)
      _resolveRuntimeMetadataProvider(type.kind, providerId),
  ];
}

LibraryMetadataProviderOption _resolveRuntimeMetadataProvider(
  String kind,
  String providerId,
) {
  final normalizedProviderId = providerId.trim();
  final option = collectarrMetadataProviderRegistry.byId(normalizedProviderId);
  if (option == null) {
    return LibraryMetadataProviderOption(
      id: normalizedProviderId,
      label: catalogTitleFromToken(normalizedProviderId),
      supportedKinds: {kind},
    );
  }
  if (option.supportedKinds.contains(kind)) {
    return option;
  }
  return LibraryMetadataProviderOption(
    id: option.id,
    label: option.label,
    description: option.description,
    supportedKinds: {...option.supportedKinds, kind},
    requiresApiKey: option.requiresApiKey,
    usagePolicy: option.usagePolicy,
  );
}

String _runtimeCatalogDisplayLabel(
  String value,
  String rawKind, {
  bool plural = false,
}) {
  final trimmed = value.trim();
  if (trimmed.isNotEmpty) {
    return trimmed;
  }
  final label = catalogTitleFromToken(rawKind, emptyLabel: 'Library');
  return plural ? '${label}s' : label;
}

LibraryMediaPresentation _presentationForCatalogKind(String kind) {
  switch (kind.trim().toLowerCase()) {
    case 'anime':
      return animeLibraryMediaPresentation;
    case 'boardgame':
      return boardGamesLibraryMediaPresentation;
    case 'book':
      return booksLibraryMediaPresentation;
    case 'comic':
      return comicsLibraryMediaPresentation;
    case 'game':
      return gamesLibraryMediaPresentation;
    case 'manga':
      return mangaLibraryMediaPresentation;
    case 'movie':
      return moviesLibraryMediaPresentation;
    case 'music':
      return musicLibraryMediaPresentation;
    case 'tv':
      return tvLibraryMediaPresentation;
    default:
      return genericLibraryMediaPresentation;
  }
}

LibraryEditPresentation _editPresentationForCatalogKind(String kind) {
  switch (kind.trim().toLowerCase()) {
    case 'comic':
      return comicsLibraryEditPresentation;
    case 'manga':
      return mangaLibraryEditPresentation;
    default:
      return genericLibraryEditPresentation;
  }
}