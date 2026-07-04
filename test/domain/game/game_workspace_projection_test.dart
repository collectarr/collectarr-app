import 'package:collectarr_app/features/library/kinds/game/game_domain.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('game workspace entry uses domain releases and no raw platforms', () {
    final work = GameWork(
      id: 'game-1',
      title: 'Example Game',
      platforms: const ['Switch'],
      releases: [
        GameRelease(
          id: 'release-1',
          title: 'Standard',
          platform: 'Switch',
          format: 'Physical',
          isPrimary: true,
        ),
      ],
    );

    final entry = buildGameWorkspaceEntry(
      work,
      const GamePersonalOverlay(),
    );

    expect(entry, isA<GameWorkspaceEntry>());
    expect(entry.game?.platforms, ['Switch']);
    expect(entry.referenceFormatLabel, 'Physical');
    expect(entry.gameReleases, hasLength(1));
    expect(entry.gameReleases.first.title, 'Standard');
  });

  test('game release workspace entry uses typed release input', () {
    final work = GameWork(
      id: 'game-1',
      title: 'Example Game',
    );
    final titleEntry = buildGameWorkspaceEntry(
      work,
      const GamePersonalOverlay(),
    ) as GameWorkspaceEntry;

    final entry = buildGameReleaseWorkspaceEntry(
      titleEntry: titleEntry,
      release: const GameRelease(
        id: 'release-2',
        title: 'Deluxe',
        platform: 'PS5',
        barcode: '1234567890',
      ),
      overlay: const GamePersonalOverlay(isOwnedOverride: true),
    );

    expect(entry.releaseId, 'release-2');
    expect(entry.barcode, '1234567890');
    expect(entry.referenceFormatLabel, 'PS5');
    expect(entry.isOwned, isTrue);
  });
}
