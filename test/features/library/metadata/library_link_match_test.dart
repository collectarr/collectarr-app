import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_metadata_capability.dart';
import 'package:collectarr_app/features/library/metadata/library_link_match.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../support/builders/workspace_item_builder.dart';

void main() {
  final source = testLibraryWorkspaceContext(kind: 'music');
  CatalogSearchCandidate candidate(
          String id) =>
      CatalogSearchCandidate.fromSummary(
          summary: CatalogDisplaySummary.forCatalogItem(
              kind: CatalogMediaKind.music, id: id, primaryLabel: id));

  test('only one distinct high candidate is eligible for explicit bulk linking',
      () {
    final first = candidate('first');
    final second = candidate('second');
    LibraryMetadataMatchScore scorer(
            Object _, CatalogSearchCandidate candidate) =>
        candidate.catalogRef!.id == 'first'
            ? LibraryMetadataMatchScore.high
            : LibraryMetadataMatchScore.medium;
    final result =
        LibraryLinkMatch.rank(source, [second, first, first], scorer);
    expect(result.candidate, first);
    expect(result.canBulkLink, isTrue);
    expect(
        LibraryLinkMatch.rank(source, [first, second],
            (_, __) => LibraryMetadataMatchScore.high).canBulkLink,
        isFalse);
  });

  test('missing scorer and empty results never enable bulk linking', () {
    expect(
        LibraryLinkMatch.rank(source, [candidate('first')], null).canBulkLink,
        isFalse);
    final empty = LibraryLinkMatch.rank(source, [], null);
    expect(empty.candidate, isNull);
    expect(empty.score, isNull);
    expect(empty.canBulkLink, isFalse);
  });
}
