import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_search_unified.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/providers/domain/models/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Music release groups show provider provenance cleanly',
      (tester) async {
    const release = MusicReleaseCandidate(
      identity: ProviderEntityIdentity(
        provider: 'musicbrainz',
        externalId: 'release-1',
        scope: LibraryEntityScope.release,
      ),
      title: 'Kind of Blue',
      releaseGroupId: 'group-1',
      releaseGroupTitle: 'Kind of Blue',
      artist: 'Miles Davis',
      provenance: ProviderProvenance(fetchedAt: '2026-09-16T00:00:00Z'),
    );
    const groupCandidate = MusicReleaseGroupCandidate(
      identity: ProviderEntityIdentity(
        provider: 'musicbrainz',
        externalId: 'group-1',
        scope: LibraryEntityScope.work,
      ),
      title: 'Kind of Blue',
      artist: 'Miles Davis',
      provenance: ProviderProvenance(fetchedAt: '2026-09-16T00:00:00Z'),
    );
    const group = LibraryAddUnifiedSearchGroup(
      key: 'musicbrainz::group-1',
      title: 'Kind of Blue',
      artist: 'Miles Davis',
      groupCandidate: groupCandidate,
      providerItems: [release],
      sources: {'musicbrainz'},
      showGroupCandidateAsChild: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 640,
            child: LibraryAddUnifiedGroupNode(
              type: const MusicRegistration(),
              group: group,
              accent: Colors.deepPurple,
              selectedResultId: null,
              selectedProviderCandidateId: null,
              checkedResultIds: const {},
              checkedProviderIds: const {},
              ownedCatalogRefs: const {},
              queuedProviderIngests: const {},
              providerLabel: (_) => 'MusicBrainz',
              onSelectResult: (_) {},
              onSelectProviderCandidate: (_) {},
              onToggleResultCheck: (_) {},
              onToggleProviderCheck: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(LibraryAddResultBadge), findsOneWidget);
    expect(find.text('MusicBrainz'), findsOneWidget);
    expect(find.text('Miles Davis'), findsOneWidget);
    expect(find.text('1 item'), findsOneWidget);
    expect(find.textContaining('Ã'), findsNothing);

    await tester.tap(find.text('Kind of Blue').last);
    await tester.pumpAndSettle();

    expect(find.byType(LibraryAddResultBadge), findsNWidgets(2));
    expect(find.text('MusicBrainz'), findsNWidgets(2));
  });
}
