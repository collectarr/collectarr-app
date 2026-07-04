import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_domain.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('boardgame workspace entry stays domain-first and avoids raw platforms',
      () {
    final work = BoardGameWork(
      id: 'boardgame-1',
      title: 'Example Board Game',
      contributors: const ['Klaus Teuber'],
      categories: const ['strategy'],
      mechanics: const ['dice rolling'],
      editions: [
        BoardGameEdition(
          id: 'edition-1',
          title: 'Core Box',
          format: 'Deluxe',
          publisher: 'Kosmos',
          releaseDate: DateTime.utc(1995, 1, 1),
        ),
      ],
    );

    final entry = buildBoardGameWorkspaceEntry(
      work,
      const BoardGamePersonalOverlay(),
    );

    expect(entry, isA<BoardGameWorkspaceEntry>());
    expect((entry as BoardGameWorkspaceEntry).boardGameWork, isNotNull);
    expect(entry.boardGameWork!.editions, hasLength(1));
    expect(entry.referenceFormatLabel, 'Deluxe');

    final editionEntry = buildBoardGameEditionWorkspaceEntry(
      titleEntry: entry,
      edition: work.editions.first,
      overlay: const BoardGamePersonalOverlay(),
    );
    expect(editionEntry, isA<BoardGameWorkspaceEntry>());
    expect((editionEntry as BoardGameWorkspaceEntry).boardGameWork, isNotNull);
    expect(editionEntry.releaseId, 'edition-1');
    expect(editionEntry.referenceEditionId, 'edition-1');
  });
}
