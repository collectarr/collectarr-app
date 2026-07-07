import 'package:collectarr_app/features/imports/framework/import_models.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';

/// Reads normalized [ImportRow]s from a specific third-party provider (a MAL
/// XML export, an AniList GraphQL response, a Trakt CSV, ...). Implementations
/// live next to their provider; the rest of the pipeline stays provider-neutral.
abstract class ImportSource {
  ProviderImportId get provider;

  /// Produce normalized rows from already-loaded source content (file bytes,
  /// decoded JSON, an authenticated API response, ...).
  Future<List<ImportRow>> readRows();
}

/// Resolves a normalized row against the catalog.
typedef ImportMatcher = Future<ImportMapping> Function(ImportRow row);

/// Detects conflicts between a matched mapping and existing local state.
typedef ImportConflictDetector = Future<List<ImportConflict>> Function(
  ImportMapping mapping,
);

/// Applies a matched mapping to local data, returning what happened.
typedef ImportApplier = Future<ImportRowOutcome> Function(
  ImportMapping mapping,
  ImportRunConfig config,
);

/// Provider-agnostic import pipeline.
///
/// The matching, conflict detection, and applying steps are injected so this
/// runner can be unit-tested with pure functions and reused unchanged for every
/// provider ([ImportSource]).
class ImportRunner {
  const ImportRunner({
    required this.matcher,
    required this.applier,
    this.conflictDetector,
  });

  final ImportMatcher matcher;
  final ImportApplier applier;
  final ImportConflictDetector? conflictDetector;

  Future<ImportResult> run(
    List<ImportRow> rows,
    ImportRunConfig config,
  ) async {
    final result = ImportResult()..bindContext(config);
    for (final row in rows) {
      result.rows++;
      final mapping = await matcher(row);
      if (mapping.state == ImportMappingState.matched) {
        result.matched++;
        if (conflictDetector != null) {
          result.conflicts.addAll(await conflictDetector!(mapping));
        }
        final outcome = await applier(mapping, config);
        result.record(outcome);
      } else {
        result.unmatched++;
        if (config.proposeUnmatched) {
          result.record(ImportRowOutcome.proposed);
        }
      }
    }
    return result;
  }
}
