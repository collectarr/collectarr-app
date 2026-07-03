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
}
