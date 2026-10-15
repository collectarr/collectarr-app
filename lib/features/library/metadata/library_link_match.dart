import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_metadata_capability.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';

/// A ranked suggestion never writes provenance. Ambiguous high scores require
/// manual review, even when the first candidate has the highest score.
class LibraryLinkMatch {
  const LibraryLinkMatch(
      {this.candidate, this.score, this.canBulkLink = false});
  final CatalogSearchCandidate? candidate;
  final LibraryMetadataMatchScore? score;
  final bool canBulkLink;

  factory LibraryLinkMatch.rank(
      LibraryWorkspaceContext source,
      List<CatalogSearchCandidate> candidates,
      LibraryMetadataMatchScorer? scorer) {
    final seen = <String>{};
    final ranked = [
      for (final candidate in candidates)
        if (candidate.catalogRef != null && seen.add(candidate.catalogRef!.key))
          (
            candidate: candidate,
            score:
                scorer?.call(source, candidate) ?? LibraryMetadataMatchScore.low
          )
    ];
    if (ranked.isEmpty) return const LibraryLinkMatch();
    ranked.sort((a, b) => a.score.index.compareTo(b.score.index));
    final first = ranked.first;
    return LibraryLinkMatch(
        candidate: first.candidate,
        score: first.score,
        canBulkLink: first.score == LibraryMetadataMatchScore.high &&
            ranked
                    .where(
                        (item) => item.score == LibraryMetadataMatchScore.high)
                    .length ==
                1);
  }
}
