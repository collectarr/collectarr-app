import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_credits_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_disc_details_view.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Credits edits role and album/disc scope, then prunes credits for a removed disc',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      const discId = MusicDiscId('disc-one');
      final album = MusicAlbum(
        title: 'Mixed Edition',
        credits: [
          MusicCredit(
            id: const MusicCreditId('album-credit'),
            name: 'Alice Example',
            role: 'Producer',
            instruments: const [],
            sequence: 1,
          ),
        ],
        discs: [
          MusicDisc(
            id: discId,
            discNumber: 1,
            format: 'CD',
            formatFamily: MusicDiscFormatFamily.opticalDisc,
            credits: [
              MusicCredit(
                id: const MusicCreditId('disc-credit'),
                name: 'Bob Example',
                role: 'Guitarist',
                instruments: const ['Guitar'],
                sequence: 1,
              ),
            ],
          ),
        ],
      );
      final draft = MusicAlbumEditDraft.fromAlbum(album);
      final editor = MusicAlbumCreditsEditor(draft: draft);

      Widget buildSubject() => ProviderScope(
            overrides: [localDatabaseProvider.overrideWithValue(db)],
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: MusicAlbumCreditsTab(
                    editor: editor,
                    accent: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Applies to'), findsOneWidget);
      expect(find.text('Instruments'), findsWidgets);
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));

      final roleField = find.byType(SingleValuePickField).first;
      final roleInput = find.descendant(
        of: roleField,
        matching: find.byType(TextField),
      );
      await tester.enterText(roleInput, 'Composer');
      await tester.pump();
      expect(draft.credits.single.role, 'Composer');

      final albumScope = find.byType(DropdownButtonFormField<String>).first;
      await tester.tap(albumScope);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Disc 1').last);
      await tester.pumpAndSettle();

      expect(draft.credits, isEmpty);
      expect(draft.discs.single.credits.map((credit) => credit.name), [
        'Alice Example',
        'Bob Example',
      ]);
      expect(draft.discs.single.credits.first.role, 'Composer');

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Album').last);
      await tester.pumpAndSettle();

      expect(draft.credits.single.role, 'Composer');
      expect(draft.discs.single.credits.map((credit) => credit.name), [
        'Bob Example',
      ]);

      draft.discList.removeDisc(discId);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(draft.discs, isEmpty);
      expect(draft.credits.single.name, 'Alice Example');
      expect(draft.credits.single.role, 'Composer');
      expect(find.text('Bob Example'), findsNothing);
    },
  );

  testWidgets('known Music formats hide Family while custom formats expose it',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final knownAlbum = MusicAlbum(
      title: 'Known Format',
      discs: [
        MusicDisc(
          id: const MusicDiscId('known-disc'),
          discNumber: 1,
          format: 'CD',
          formatFamily: MusicDiscFormatFamily.opticalDisc,
        ),
      ],
    );
    final knownDraft = MusicAlbumEditDraft.fromAlbum(knownAlbum);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MusicDiscDetailsView(
                disc: knownDraft.discs.single,
                draft: knownDraft,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Family'), findsNothing);

    final customAlbum = MusicAlbum(
      title: 'Custom Format',
      discs: [
        MusicDisc(
          id: const MusicDiscId('custom-disc'),
          discNumber: 1,
          format: 'Custom Silver Disc',
        ),
      ],
    );
    final customDraft = MusicAlbumEditDraft.fromAlbum(customAlbum);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MusicDiscDetailsView(
                disc: customDraft.discs.single,
                draft: customDraft,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Family'), findsOneWidget);

    await tester
        .tap(find.byType(DropdownButtonFormField<MusicDiscFormatFamily>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OTHER').last);
    await tester.pumpAndSettle();
    expect(customDraft.discs.single.formatFamily, MusicDiscFormatFamily.other);
  });
}
