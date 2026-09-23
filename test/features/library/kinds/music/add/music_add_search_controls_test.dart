import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_search_controls.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_search_filters.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('music search controls expose only the medium filter',
      (tester) async {
    final queryController = TextEditingController();
    final identifierController = TextEditingController();
    addTearDown(queryController.dispose);
    addTearDown(identifierController.dispose);

    final filters = <LibraryAddFilterId, LibraryAddFilterValue>{
      musicAddMediumFilterId:
          LibraryAddOptionFilterValue(MusicAddMediumFilter.all.value),
    };
    var searches = 0;

    final request = LibraryAddModeBarRequest(
      type: const MusicRegistration(),
      accent: Colors.orange,
      isWideLayout: true,
      mode: LibraryAddDialogMode.search,
      queryController: queryController,
      identifierController: identifierController,
      isSearching: false,
      isSearchingProvider: false,
      onModeChanged: (_) {},
      onSearch: () => searches++,
      onQueryChanged: (_) {},
      suggestions: const <CatalogSearchCandidate>[],
      showSuggestions: false,
      onSelectSuggestion: (_) {},
      onDismissSuggestions: () {},
      canScanCover: false,
      isScanningCover: false,
      onScanCover: () {},
      onLookupIdentifier: () {},
      onManual: () {},
      showAdvanced: false,
      onToggleAdvanced: () {},
      advancedFilterState: filters,
      onAdvancedFilterChanged: (id, value) {
        if (value == null) {
          filters.remove(id);
        } else {
          filters[id] = value;
        }
      },
      advancedFilterDescriptors: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MusicAddSearchControls(request: request),
        ),
      ),
    );

    expect(find.text('Release groups'), findsNothing);
    expect(find.text('Releases'), findsNothing);
    expect(find.text('CD'), findsOneWidget);
    expect(find.text('Digital'), findsOneWidget);

    await tester.tap(find.text('CD'));
    await tester.pump();
    expect(
      filters[musicAddMediumFilterId],
      isA<LibraryAddOptionFilterValue>().having(
        (filter) => filter.value,
        'value',
        'cd',
      ),
    );
    expect(searches, 1);
  });
}
