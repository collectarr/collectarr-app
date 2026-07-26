import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_domain.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('boardgame workspace entry stays domain-first and avoids raw platforms',
      () {
    final work = BoardGameWork(
      id: 'boardgame-1',
      work: const BoardGameWorkMetadata(
        title: 'Example Board Game',
        categories: ['strategy'],
        mechanics: ['dice rolling'],
      ),
      releases: [
        BoardGameRelease(
          id: 'edition-1',
          title: 'Core Box',
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
    expect(entry.boardGameReleases, hasLength(1));

    final editionEntry = buildBoardGameEditionWorkspaceEntry(
      titleEntry: entry,
      edition: work.editions.first,
      overlay: const BoardGamePersonalOverlay(),
    );
    expect(editionEntry, isA<BoardGameWorkspaceEntry>());
    expect(editionEntry.releaseId, 'edition-1');
  });
}
