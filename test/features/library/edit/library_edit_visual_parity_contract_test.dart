import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/features/library/ui/library_section_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _editContexts = <LibraryEditPresentationContext>[
  LibraryEditPresentationContext(
    isOwned: true,
    isTrackingOnly: false,
    hasTrackingContext: true,
    hasWishlistContext: true,
    isDigitalFormat: false,
    hasPhysicalFormats: true,
    hasEditionAnchors: true,
    hasBundleReleaseAnchors: true,
    hasCustomFields: true,
    scope: LibraryEditScope.all,
  ),
  LibraryEditPresentationContext(
    isOwned: false,
    isTrackingOnly: true,
    hasTrackingContext: true,
    hasWishlistContext: false,
    isDigitalFormat: true,
    hasPhysicalFormats: false,
    hasEditionAnchors: false,
    hasBundleReleaseAnchors: false,
    hasCustomFields: false,
    scope: LibraryEditScope.all,
  ),
  LibraryEditPresentationContext(
    isOwned: false,
    isTrackingOnly: false,
    hasTrackingContext: false,
    hasWishlistContext: false,
    isDigitalFormat: false,
    hasPhysicalFormats: true,
    hasEditionAnchors: false,
    hasBundleReleaseAnchors: false,
    hasCustomFields: true,
    scope: LibraryEditScope.media,
  ),
];

void main() {
  testWidgets('all active kinds render edit presentation parity matrix',
      (tester) async {
    expect(collectarrKindModules, hasLength(9));

    for (final runtime in collectarrKindModules) {
      expect(runtime.kind, isNot(CatalogMediaKind.unknown));
      for (final context in _editContexts) {
        final builder = runtime.edit.presentation.builderForScope(
          context.scope,
        );
        final tabs = builder.buildTabs(context: context);
        final state = builder.build(context: context);

        expect(tabs, isNotEmpty, reason: '${runtime.kind} has no edit tabs');
        expect(state.trackingSectionTitle.trim(), isNotEmpty);

        for (final density in LibraryDensity.values) {
          await tester.pumpWidget(
            MaterialApp(
              home: LibraryDensityScope(
                density: density,
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final tab in tabs)
                          LibrarySectionPanel(
                            density: density,
                            title: Text(tab.label),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final sectionId
                                    in builder.buildTabSectionIds(
                                  context: context,
                                  tabId: tab.id,
                                ))
                                  Text(sectionId),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          expect(find.byType(LibrarySectionPanel), findsNWidgets(tabs.length));
          for (final tab in tabs) {
            expect(find.text(tab.label), findsAtLeastNWidgets(1));
          }
        }
      }
    }
  });
}
