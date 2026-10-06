import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_details_pane.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_structure_tabs.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_details_form_pane.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_disc_details_view.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/theme/library_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Music Details sub-tabs and Tracks tab refactor', () {
    testWidgets('LibraryPartialDateInput divider is vertically centered with fields', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildLibraryTheme(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: LibraryPartialDateInput(
                value: null,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ));

      // Two divider containers between 3 fields
      final containers = tester.widgetList<Container>(find.byType(Container)).toList();
      expect(containers.length, greaterThanOrEqualTo(2));

      // Find the divider render boxes
      final dividerElements = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.constraints?.maxWidth == 8 &&
          widget.constraints?.maxHeight == 1);
      expect(dividerElements, findsNWidgets(2));

      final firstDividerRect = tester.getRect(dividerElements.first);
      final firstFieldRect = tester.getRect(find.byType(TextFormField).first);

      // The vertical center of the divider line must match the vertical center of the field box (within 1px tolerance)
      final fieldCenterY = (firstFieldRect.top + firstFieldRect.bottom) / 2;
      final dividerCenterY = (firstDividerRect.top + firstDividerRect.bottom) / 2;
      expect((fieldCenterY - dividerCenterY).abs(), lessThan(1.5));
    });

    testWidgets('MusicAlbumDetailsPane renders General + Disc sub-tabs', (tester) async {
      final album = MusicAlbum(
        id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'test-album'),
        title: 'Abbey Road',
        discs: [
          MusicDisc(
            id: const MusicDiscId('disc-1'),
            discNumber: 1,
            format: 'Vinyl',
            vinylColor: 'Black',
            tracks: [
              MusicTrack(
                id: const MusicTrackId('t1'),
                position: '1',
                title: 'Come Together',
              ),
            ],
          ),
          MusicDisc(
            id: const MusicDiscId('disc-2'),
            discNumber: 2,
            format: 'CD',
            tracks: [],
          ),
        ],
      );
      final draft = MusicAlbumEditDraft.fromAlbum(album);

      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: buildLibraryTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: MusicAlbumDetailsPane(draft: draft),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Sub-tab buttons must be present
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Disc 1 · Vinyl'), findsOneWidget);
      expect(find.text('Disc 2 · CD'), findsOneWidget);
      expect(find.text('Add Disc'), findsOneWidget);

      // Default sub-tab is General: MusicDetailsFormPane is shown
      expect(find.byType(MusicDetailsFormPane<MusicAlbumEditDraft>), findsOneWidget);
      expect(find.byType(MusicDiscDetailsView), findsNothing);

      // Tap Disc 1 sub-tab
      await tester.tap(find.text('Disc 1 · Vinyl'));
      await tester.pumpAndSettle();

      // General form is no longer shown, MusicDiscDetailsView is shown
      expect(find.byType(MusicDetailsFormPane<MusicAlbumEditDraft>), findsNothing);
      expect(find.byType(MusicDiscDetailsView), findsOneWidget);
      // For vinyl disc, the Vinyl group and fields appear
      expect(find.widgetWithText(LibraryFormGroup, 'Vinyl'), findsOneWidget);
      expect(find.text('Matrix No. Side A'), findsOneWidget);

      // Tap General sub-tab again
      await tester.tap(find.text('General'));
      await tester.pumpAndSettle();
      expect(find.byType(MusicDetailsFormPane<MusicAlbumEditDraft>), findsOneWidget);
      expect(find.byType(MusicDiscDetailsView), findsNothing);
    });

    testWidgets('MusicAlbumStructureTab (Tracks tab) does not display disc extra fields', (tester) async {
      final album = MusicAlbum(
        id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'test-album'),
        title: 'Abbey Road',
        discs: [
          MusicDisc(
            id: const MusicDiscId('disc-1'),
            discNumber: 1,
            format: 'Vinyl',
            vinylColor: 'Black',
            vinylWeight: '180',
            rpm: 33,
            tracks: [
              MusicTrack(
                id: const MusicTrackId('t1'),
                position: '1',
                title: 'Come Together',
              ),
            ],
          ),
        ],
      );
      final draft = MusicAlbumEditDraft.fromAlbum(album);

      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: buildLibraryTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: MusicAlbumStructureTab(
                draft: draft,
                accent: Colors.blue,
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // The track table and track title must be present
      expect(find.text('Come Together'), findsOneWidget);
      expect(find.text('Add Track'), findsOneWidget);
      expect(find.text('Add Header'), findsOneWidget);

      // Extra disc fields (such as Vinyl group, Weight (g), RPM, SPARS, Matrix No.) must NOT be in Tracks tab
      expect(find.text('Weight (g)'), findsNothing);
      expect(find.text('RPM'), findsNothing);
      expect(find.text('SPARS'), findsNothing);
      expect(find.text('Matrix No. Side A'), findsNothing);
      expect(find.text('Storage Device'), findsNothing);

      // CLZ Disc Title and Add Disc button must be present
      expect(find.text('Disc Title'), findsOneWidget);
      expect(find.text('Add Disc'), findsOneWidget);
      expect(find.text('Tracks'), findsOneWidget);

      // Table header must show Title, Artist, Length when nothing is selected
      expect(find.text('Title'), findsAtLeastNWidgets(1));
      expect(find.text('Artist'), findsAtLeastNWidgets(1));
      expect(find.text('Length'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('Autocap'), findsNothing);

      // Tap on the track selection checkbox to select track
      final trackCheckboxFinder = find.byWidgetPredicate(
        (widget) => widget is Container && widget.decoration is BoxDecoration && (widget.decoration as BoxDecoration).color == Colors.transparent,
      );
      if (trackCheckboxFinder.evaluate().isNotEmpty) {
        await tester.tap(trackCheckboxFinder.first);
        await tester.pumpAndSettle();

        // Selection toolbar should now be visible with Cancel, All, Autocap, Remove
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Autocap'), findsOneWidget);
        expect(find.text('Remove'), findsOneWidget);
        expect(find.text('1 of 1'), findsOneWidget);
      }
    });
  });
}
