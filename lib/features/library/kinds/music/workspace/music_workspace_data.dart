import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_facts.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';

/// Music workspace data for one concrete album item.
///
/// Discs and tracks remain contained under [music].
final class MusicWorkspaceData implements LibraryWorkspaceKindData {
  MusicWorkspaceData({
    required this.music,
    this.listeningSummary,
    MusicWorkspaceFacts? facts,
  }) : facts = facts ?? MusicWorkspaceFacts.fromAlbum(music);

  factory MusicWorkspaceData.fromMusic(
    MusicAlbum music, {
    MusicEntryListeningSummary? listeningSummary,
  }) {
    return MusicWorkspaceData(
      music: music,
      listeningSummary: listeningSummary,
    );
  }

  final MusicAlbum music;
  final MusicEntryListeningSummary? listeningSummary;
  final MusicWorkspaceFacts facts;

  MusicWorkspaceData copyWith({
    MusicEntryListeningSummary? listeningSummary,
  }) =>
      MusicWorkspaceData(
        music: music,
        listeningSummary: listeningSummary ?? this.listeningSummary,
        facts: facts,
      );

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;
  @override
  String get displayLabel => music.title;
}
