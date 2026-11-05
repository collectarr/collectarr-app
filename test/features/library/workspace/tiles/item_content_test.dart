import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/presentation/media_presentation.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/builders/workspace_item_builder.dart';

void main() {
  testWidgets(
      'a registered synthetic contribution replaces every content surface',
      (tester) async {
    final base = libraryPresentationForKind(CatalogMediaKind.music);
    final item = LibraryProjectionItem.fromShelf(
        testLibraryWorkspaceSource(itemId: 'synthetic', kind: 'music'),
        libraryKindRegistrationForKind(CatalogMediaKind.music));
    Widget body(String label, LibraryCardBodyData data) => Column(children: [
          Text(label),
          data.buildCover(alignment: Alignment.center),
          Text('active: ${data.active}')
        ]);
    final synthetic = LibraryCardPresentation(
      coverBodyBuilder: (_, data) => body('custom cover', data),
      verticalBodyBuilder: (_, data) => body('custom vertical', data),
      horizontalBodyBuilder: (_, data) => body('custom horizontal', data),
      flowBodyBuilder: (_, data) => body('custom flow', data),
      shelfBodyBuilder: (_, data) => body('custom shelf', data),
      flowFooterBuilder: (_, data) =>
          Text('custom footer ${data.index}/${data.total}'),
    );
    final presentation = LibraryMediaPresentation(
      searchFieldLabels: base.searchFieldLabels,
      filterLabels: base.filterLabels,
      groupLabels: base.groupLabels,
      builder: base.builder,
      bucketLabelBuilder: base.bucketLabelBuilder,
      cardPresentationBuilder: (item, {required coverFocused}) => synthetic,
    ).buildCardPresentation(item, coverFocused: false);
    final data = LibraryCardBodyData(
        item: item,
        presentation: presentation,
        selected: false,
        active: true,
        showHeadline: true,
        titleColor: Colors.black,
        detailColor: Colors.black,
        mutedColor: Colors.grey,
        customFieldBadges: const [],
        coverWidth: 100,
        buildCover: ({required alignment}) => const Text('shared image slot'),
        pillStatus: const SizedBox(),
        coverStatus: const SizedBox());
    final labels = ['cover', 'vertical', 'horizontal', 'flow', 'shelf'];
    for (var index = 0; index < LibraryItemContentView.values.length; index++) {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: LibraryItemContent(
                  view: LibraryItemContentView.values[index], data: data))));
      expect(find.text('custom ${labels[index]}'), findsOneWidget);
      expect(find.text('shared image slot'), findsOneWidget);
      expect(find.text('active: true'), findsOneWidget);
    }
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => presentation.flowFooterBuilder(
                context,
                const LibraryFlowFooterData(
                    index: 2, total: 5, accent: Colors.blue)))));
    expect(find.text('custom footer 2/5'), findsOneWidget);
  });
}
