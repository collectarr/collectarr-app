import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/activity/universal_activity_contributors.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/actions/import_export_actions.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/config/library_activity_contributor.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';
import 'package:collectarr_app/features/library/config/library_barcode_resolver.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/config/library_export_preview_contributor.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/config/library_shelf_extension_contributor.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/kinds/tv/integrations/tmdb/tv_tracking_import_contribution.dart';
import 'package:collectarr_app/features/providers/adapters/tmdb/tmdb_tracking_import_contribution.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/registry/library_kind_capabilities.dart';
export 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';

final class LibraryKindRegistry {
  LibraryKindRegistry(
    Iterable<LibraryKindModule> specs,
  ) : _byKind = _buildValidatedRegistry(specs);

  final Map<CatalogMediaKind, LibraryKindModule> _byKind;

  static Map<CatalogMediaKind, LibraryKindModule> _buildValidatedRegistry(
    Iterable<LibraryKindModule> specs,
  ) {
    final map = <CatalogMediaKind, LibraryKindModule>{};
    for (final spec in specs) {
      if (map.containsKey(spec.kind)) {
        throw StateError(
          'Duplicate LibraryKindSpec registration for kind: ${spec.kind}',
        );
      }
      map[spec.kind] = spec;
    }
    return Map.unmodifiable(map);
  }

  LibraryKindModule require(CatalogMediaKind kind) {
    final kindModule = _byKind[kind];
    if (kindModule == null) {
      throw ArgumentError('No LibraryKindModule registered for kind: $kind');
    }
    return kindModule;
  }

  LibraryKindModule? tryGet(CatalogMediaKind kind) => _byKind[kind];

  LibraryKindModule getByKind(CatalogMediaKind kind) => require(kind);

  List<LibraryKindModule> get allModules => List.unmodifiable(_byKind.values);
}

final defaultLibraryKindRegistry = (() {
  registerTmdbTrackingImportContribution(
    CatalogMediaKind.tv,
    const TvTrackingImportContribution(),
  );
  return LibraryKindRegistry(collectarrKindModules);
})();

final Map<CatalogMediaKind, LibraryCollectionCsvProjection>
    _collectionCsvProjections = Map.unmodifiable(
  collectarrKindCollectionCsvProjections,
);

Iterable<LibraryCollectionCsvProjection> get libraryCollectionCsvProjections =>
    _collectionCsvProjections.values;

final Map<CatalogMediaKind, LibraryShelfExtensionContributor>
    _shelfExtensionContributors = Map.unmodifiable(
  collectarrKindShelfExtensions,
);

final Map<CatalogMediaKind, LibraryExportPreviewContributor>
    _exportPreviewContributors = Map.unmodifiable(
  collectarrKindExportPreviewContributors,
);

final Map<CatalogMediaKind, LibraryCalendarContributor> _calendarContributors =
    Map.unmodifiable(
  collectarrKindCalendarContributors,
);

Iterable<LibraryCalendarContributor> get libraryCalendarContributors =>
    _calendarContributors.values;

LibraryCalendarContributor? libraryCalendarContributorForKind(
  CatalogMediaKind kind,
) {
  return _calendarContributors[kind];
}

final Map<CatalogMediaKind, LibraryActivityContributor> _activityContributors =
    Map.unmodifiable(
  collectarrKindActivityContributors,
);

Iterable<LibraryActivityContributor> get libraryActivityContributors =>
    _activityContributors.values;

LibraryActivityContributor? libraryActivityContributorForKind(
  CatalogMediaKind kind,
) {
  return _activityContributors[kind];
}

final Map<CatalogMediaKind, LibraryAdminContributor> _adminContributors =
    Map.unmodifiable(
  collectarrKindAdminContributors,
);

Iterable<LibraryAdminContributor> get libraryAdminContributors =>
    _adminContributors.values;

LibraryAdminContributor? libraryAdminContributorForKind(
  CatalogMediaKind kind,
) {
  return _adminContributors[kind];
}

/// Projects watch sessions through their owning kind. The fallback for kinds
/// without a semantic contributor is delegated to the universal contributor;
/// this registry only performs kind dispatch.
Iterable<ActivityEvent> libraryActivityEventsForWatchSessions(
  Iterable<WatchSession> sessions,
) sync* {
  final sessionList = sessions.toList(growable: false);
  final byKind = <CatalogMediaKind, List<WatchSession>>{};
  for (final session in sessionList) {
    byKind.putIfAbsent(session.targetRef.mediaKind, () => []).add(session);
  }

  for (final entry in byKind.entries) {
    final contributor = libraryActivityContributorForKind(entry.key);
    if (contributor != null) {
      yield* contributor.contribute(
        LibraryActivityContext(watchSessions: entry.value),
      );
      continue;
    }
  }

  yield* const GenericWatchActivityContributor().contribute(
    UniversalActivityContext(
      watchSessions: sessionList,
      hasKindContributor: (kind) =>
          libraryActivityContributorForKind(kind) != null,
    ),
  );
}

final Map<CatalogMediaKind, LibraryBarcodeResolver> _barcodeResolvers =
    Map.unmodifiable(
  collectarrKindBarcodeResolvers,
);

Iterable<LibraryBarcodeResolver> get libraryBarcodeResolvers =>
    _barcodeResolvers.values;

LibraryBarcodeResolver? libraryBarcodeResolverForKind(CatalogMediaKind kind) =>
    _barcodeResolvers[kind];

/// Resolves a raw scanner/manual value through the owning kind.
///
/// The returned value is still only the identifier accepted by the boundary;
/// generic callers do not inspect or infer its domain meaning.
String? resolveLibraryBarcodeForKind(
  CatalogMediaKind kind,
  String rawValue,
) {
  final code = ScannedCode.tryFromRaw(rawValue);
  if (code == null) {
    return null;
  }
  return libraryBarcodeResolverForKind(kind)?.resolve(code);
}

/// Returns the kind-owned semantic CSV contribution for a serialization
/// boundary. The generic Collection feature receives cells only; it never
/// inspects Comic or another kind's domain fields.
LibraryCollectionCsvProjection? libraryCollectionCsvProjectionForKind(
  CatalogMediaKind kind,
) {
  return _collectionCsvProjections[kind];
}

/// Composition-root dispatch for kind-owned extensions on the mixed Shelf.
///
/// The Collection feature owns the slot and row lifecycle. The kind registry
/// only looks up a structural contributor; it does not encode kind branches.
Widget? libraryShelfExtensionForEntry(
  LibraryWorkspaceSource entry, {
  required bool expanded,
  required VoidCallback onToggle,
}) {
  final kind = entry.catalogSummary?.kind ?? CatalogMediaKind.unknown;
  return _shelfExtensionContributors[kind]?.build(
    entry,
    expanded: expanded,
    onToggle: onToggle,
  );
}

final libraryKindRegistryProvider = Provider<LibraryKindRegistry>((ref) {
  return defaultLibraryKindRegistry;
});

LibraryKindModule libraryKindModule(
  CatalogMediaKind kind, {
  LibraryKindRegistry? registry,
}) =>
    libraryKindModuleForKind(kind, registry: registry);

LibraryKindModule libraryKindModuleForKind(
  CatalogMediaKind kind, {
  LibraryKindRegistry? registry,
}) {
  final reg = registry ?? defaultLibraryKindRegistry;
  return reg.require(kind);
}

/// Workspace dispatch is separate from the navigation/module boundary. The
/// generated map binds each entry to its concrete workspace DTO type.
LibraryKindWorkspace libraryKindWorkspaceForKind(CatalogMediaKind kind) {
  final workspace = collectarrKindWorkspaces[kind];
  if (workspace == null) {
    throw ArgumentError('No LibraryKindWorkspace registered for kind: $kind');
  }
  return workspace;
}

/// Composition-root dispatch for kind-owned facet extraction and remote facet
/// loading. The generic library only receives the structural facet module;
/// it does not read facet semantics from [LibraryKindModule].
LibraryFacetModule? libraryKindFacetModuleForKind(CatalogMediaKind kind) {
  return collectarrKindFacetModules[kind];
}

/// Composition-root dispatch for provider metadata serialization.
///
/// The selected kind still owns the mapper implementation. The registry only
/// exposes the function needed to cross the API/transport projection boundary
/// and does not leak an erased mapper object into feature code.
ProviderMetadataItemMapper? libraryKindProviderMetadataMapperForKind(
  CatalogMediaKind kind,
) {
  return collectarrKindProviderMetadataMappers[kind];
}

ProviderCorrectionBuilder? libraryKindProviderCorrectionBuilderForKind(
  CatalogMediaKind kind,
) {
  return collectarrKindProviderCorrectionBuilders[kind];
}

bool libraryGroupModeSupportsCompletion(
  LibraryKindModule type,
  String groupMode,
) {
  final workspace = libraryKindWorkspaceForKind(type.kind);
  return workspace.groupModeSupportsCompletion(
    workspace.fields.decodeGroupId(groupMode),
  );
}

/// Composition-root contributions exposed to generic feature hosts.
///
/// The registry may assemble kind implementations; callers receive only the
/// structural artifact contract and never import a concrete kind.
List<ExportPreviewArtifact> libraryExportPreviewArtifacts(
  Iterable<LibraryWorkspaceSource> entries,
) {
  return [
    for (final contributor in _exportPreviewContributors.values)
      ...contributor.build(entries),
  ];
}
