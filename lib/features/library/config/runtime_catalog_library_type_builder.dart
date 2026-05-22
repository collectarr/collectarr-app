import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/providers/library_catalog_resolution.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

LibraryTypeConfig buildRuntimeCatalogLibraryTypeConfig(CatalogMediaType type) {
  final normalizedType = normalizeCatalogMediaTypeDefaults(type);
  const presentation = genericLibraryMediaPresentation;
  return LibraryTypeConfig(
    workspace: LibraryWorkspaceConfig(
      kind: normalizedType.kind,
      title: catalogDisplayLabel(
        normalizedType.pluralLabel,
        normalizedType.kind,
        plural: true,
      ),
      icon: libraryIconForKind(normalizedType.kind),
      preferencePrefix: 'catalog_${normalizedType.kind}',
      defaultSortColumn: LibrarySortColumn.title,
      defaultVisibleColumns: presentation.defaultVisibleColumns,
    ),
    singularLabel: catalogDisplayLabel(
      normalizedType.singularLabel,
      normalizedType.kind,
    ),
    pluralLabel: catalogDisplayLabel(
      normalizedType.pluralLabel,
      normalizedType.kind,
      plural: true,
    ),
    defaultMetadataProvider: normalizedType.defaultProvider ??
        (normalizedType.providers.isEmpty ? '' : normalizedType.providers.first),
    metadataProviders: const [],
    trackingProfile: catalogTrackingProfileForKind(normalizedType.kind),
    presentation: presentation,
  ).resolveWithCatalog([normalizedType]);
}