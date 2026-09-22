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
import 'package:collectarr_app/features/collection/csv/collection_csv_kind_profile.dart';
import 'package:collectarr_app/features/library/config/library_export_preview_contributor.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/config/library_shelf_extension_contributor.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';
import 'package:collectarr_app/features/providers/adapters/tmdb/tmdb_import_kind_contribution.dart';
import 'package:collectarr_app/features/providers/adapters/tmdb/tmdb_tracking_import_contribution.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
export 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
export 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';

final class LibraryKindRegistry {
  LibraryKindRegistry(
    Iterable<LibraryKindRegistration> specs,
  ) : _byKind = _buildValidatedRegistry(specs);

  final Map<CatalogMediaKind, LibraryKindRegistration> _byKind;

  static Map<CatalogMediaKind, LibraryKindRegistration> _buildValidatedRegistry(
    Iterable<LibraryKindRegistration> specs,
  ) {
    final map = <CatalogMediaKind, LibraryKindRegistration>{};
    for (final spec in specs) {
      if (map.containsKey(spec.kind)) {
        throw StateError(
          'Duplicate kind registration for kind: ${spec.kind}',
        );
      }
      map[spec.kind] = spec;
    }
    return Map.unmodifiable(map);
  }

  LibraryKindRegistration require(CatalogMediaKind kind) {
    final registration = _byKind[kind];
    if (registration == null) {
      throw ArgumentError(
          'No LibraryKindRegistration registered for kind: $kind');
    }
    return registration;
  }

  LibraryKindRegistration? tryGet(CatalogMediaKind kind) => _byKind[kind];

  LibraryKindRegistration getByKind(CatalogMediaKind kind) => require(kind);

  List<LibraryKindRegistration> get allKinds =>
      List.unmodifiable(_byKind.values);
}

final defaultLibraryKindRegistry = (() {
  registerTmdbTrackingImportContribution(
    CatalogMediaKind.tv,
    const TvTrackingImportContribution(),
  );
  registerTmdbImportKindContribution(const AnimeTmdbImportContribution());
  registerTmdbImportKindContribution(const MovieTmdbImportContribution());
  registerTmdbImportKindContribution(const TvTmdbImportContribution());
  return LibraryKindRegistry(collectarrKindRegistrationsList);
})();

final Map<CatalogMediaKind, CollectionCsvKindProfile>
    _collectionCsvProjections = Map.unmodifiable(
  collectionCsvProfilesByKind,
);

Iterable<CollectionCsvKindProfile> get collectionCsvKindProfiles =>
    _collectionCsvProjections.values;

final Map<CatalogMediaKind, LibraryShelfExtensionContributor>
    _shelfExtensionContributors = Map.unmodifiable(
  collectionShelfExtensionsByKind,
);

final Map<CatalogMediaKind, LibraryExportPreviewContributor>
    _exportPreviewContributors = Map.unmodifiable(
  collectionExportPreviewContributorsByKind,
);

final Map<CatalogMediaKind, LibraryCalendarContributor> _calendarContributors =
    Map.unmodifiable(
  libraryCalendarContributorsByKind,
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
  libraryActivityContributorsByKind,
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
  libraryAdminContributorsByKind,
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
  libraryBarcodeResolversByKind,
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
CollectionCsvKindProfile? collectionCsvKindProfileFor(
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

LibraryKindRegistration libraryKindRegistration(
  CatalogMediaKind kind, {
  LibraryKindRegistry? registry,
}) =>
    libraryKindRegistrationForKind(kind, registry: registry);

LibraryKindRegistration libraryKindRegistrationForKind(
  CatalogMediaKind kind, {
  LibraryKindRegistry? registry,
}) {
  final reg = registry ?? defaultLibraryKindRegistry;
  return reg.require(kind);
}

/// Workspace dispatch is separate from the identity/page registration. The
/// composition map binds each entry to its concrete workspace DTO type.
LibraryKindWorkspace libraryKindWorkspaceForKind(CatalogMediaKind kind) {
  final workspace = collectarrKindWorkspaces[kind];
  if (workspace == null) {
    throw ArgumentError('No LibraryKindWorkspace registered for kind: $kind');
  }
  return workspace;
}

/// Composition-root dispatch for kind-owned facet extraction and remote facet
/// loading. The generic library only receives the structural facet contract;
/// it does not read facet semantics from [LibraryKindRegistration].
LibraryFacetModule? libraryKindFacetModuleForKind(CatalogMediaKind kind) {
  return collectarrKindFacetModules[kind];
}

ProviderCorrectionBuilder? libraryKindProviderCorrectionBuilderForKind(
  CatalogMediaKind kind,
) {
  return libraryProviderCorrectionBuildersByKind[kind];
}

bool libraryGroupModeSupportsCompletion(
  LibraryKindRegistration type,
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
