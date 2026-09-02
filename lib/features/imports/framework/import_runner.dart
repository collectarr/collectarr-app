import 'package:collectarr_app/features/imports/framework/import_models.dart';
import 'package:collectarr_app/features/providers/domain/engine/external_state_engine.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';

/// Reads normalized entries from a specific third-party provider (a MAL
/// XML export, an AniList GraphQL response, a Trakt CSV, ...). Implementations
/// live next to their provider; the rest of the pipeline stays provider-neutral.
abstract class ImportSource {
  ProviderId get provider;

  /// Produce normalized rows / entries from already-loaded source content.
  Future<List<dynamic>> readRows();
}

/// Resolves an incoming entry against the catalog.
typedef ImportMatcher = Future<ImportMapping> Function(dynamic rowOrEntry);

/// Detects conflicts between a matched mapping and existing local state.
typedef ImportConflictDetector = Future<List<ImportConflict>> Function(
  ImportMapping mapping,
);

/// Handles entries that did not resolve to a catalog target.
typedef ImportUnmatchedHandler = Future<void> Function(
  dynamic rowOrEntry,
  ImportRunConfig config,
);

/// Applies a matched mapping to local data, returning what happened.
typedef ImportApplier = Future<ImportRowOutcome> Function(
  ImportMapping mapping,
  ImportRunConfig config,
);

/// Provider-agnostic import pipeline backed by [ExternalStateEngine].
class ImportRunner {
  const ImportRunner({
    required this.matcher,
    required this.applier,
    this.conflictDetector,
    this.unmatchedHandler,
    this.engine = const ExternalStateEngine(),
  });

  final ImportMatcher matcher;
  final ImportApplier applier;
  final ImportConflictDetector? conflictDetector;
  final ImportUnmatchedHandler? unmatchedHandler;
  final ExternalStateEngine engine;

  Future<ImportResult> runSource(
    ImportSource source,
    ImportRunConfig config,
  ) async {
    return run(await source.readRows(), config);
  }

  Future<ImportResult> run(
    List<dynamic> rows,
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
        if (unmatchedHandler != null) {
          await unmatchedHandler!(row, config);
        }
        if (config.proposeUnmatched) {
          result.record(ImportRowOutcome.proposed);
        }
      }
    }
    return result;
  }
}
