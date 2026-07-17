import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

LibraryTypeConfig buildRuntimeCatalogLibraryTypeConfig(CatalogMediaType type) {
  final normalizedType = normalizeCatalogMediaTypeDefaults(type);
  final mediaKind = catalogMediaKindFromApiValue(normalizedType.kind);
  final knownType = collectarrLibraryTypes.byKind(normalizedType.kind);
  final presentation = knownType?.presentation ?? genericLibraryMediaPresentation;
  final editPresentation =
      knownType?.editPresentation ?? const LibraryEditPresentation(
        builder: DefaultLibraryEditPresentationBuilder(),
      );
  final defaultVisibleColumns = (knownType != null
          ? libraryKindModuleForType(knownType).fields.defaultVisibleColumnIds
          : const <String>{
              'status',
              'cover',
              'title',
              'publisher',
              'release_date',
              'barcode',
              'condition',
              'price',
              'location',
              'wishlist',
              'updated',
            })
      .toSet();
  return LibraryTypeConfig(
    workspace: LibraryWorkspaceConfig(
      kind: mediaKind,
      title: _runtimeCatalogDisplayLabel(
        normalizedType.pluralLabel,
        normalizedType.kind,
        plural: true,
      ),
      icon: libraryIconForKind(mediaKind),
      accent: libraryAccentForKind(mediaKind),
      preferencePrefix: 'catalog_${normalizedType.kind}',
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
    workspaceBehavior:
        knownType?.workspaceBehavior ?? const LibraryKindWorkspaceBehavior(),
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
