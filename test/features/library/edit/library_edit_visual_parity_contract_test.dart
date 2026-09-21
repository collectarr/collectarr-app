import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
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
    hasOwnedTargetOptions: true,
    hasAdditionalTargetOptions: true,
    hasCustomFields: true,
    scope: LibraryEntityScope.work,
  ),
  LibraryEditPresentationContext(
    isOwned: false,
    isTrackingOnly: true,
    hasTrackingContext: true,
    hasWishlistContext: false,
    isDigitalFormat: true,
    hasPhysicalFormats: false,
    hasOwnedTargetOptions: false,
    hasAdditionalTargetOptions: false,
    hasCustomFields: false,
    scope: LibraryEntityScope.work,
  ),
  LibraryEditPresentationContext(
    isOwned: false,
    isTrackingOnly: false,
    hasTrackingContext: false,
    hasWishlistContext: false,
    isDigitalFormat: false,
    hasPhysicalFormats: true,
    hasOwnedTargetOptions: false,
    hasAdditionalTargetOptions: false,
    hasCustomFields: true,
    scope: LibraryEntityScope.work,
  ),
];

void main() {
  testWidgets('all active kinds render edit presentation parity matrix',
      (tester) async {
    expect(collectarrKindRegistrationsList, hasLength(9));

    for (final runtime in collectarrKindRegistrationsList) {
      expect(runtime.kind, isNot(CatalogMediaKind.unknown));
      // Music has dedicated Group/Release/Copy editors and intentionally does
      // not participate in the retired generic edit-tab renderer.
      if (runtime.kind == CatalogMediaKind.music) continue;
      for (final context in _editContexts) {
        final builder = libraryEditPresentationForKind(runtime.kind)
            .presentation
            .builderForScope(
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
