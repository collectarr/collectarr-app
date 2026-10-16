import 'package:collectarr_app/features/library/config/presentation/library_alphabet_field.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';

const musicAlphabetFields = [
  LibraryAlphabetField(id: 'artist', label: 'Artist', values: _artists),
  LibraryAlphabetField(id: 'composer', label: 'Composer', values: _composers),
  LibraryAlphabetField.title,
];

Iterable<String> _artists(LibraryProjectionView item) {
  final data = item.source.kindPresentationData;
  if (data is! MusicWorkspaceData) return const [];
  final artist = data.music.artist?.trim();
  return [if (artist != null && artist.isNotEmpty) artist];
}

Iterable<String> _composers(LibraryProjectionView item) {
  final data = item.source.kindPresentationData;
  if (data is! MusicWorkspaceData) return const [];
  return {
    for (final credit in [
      ...data.music.credits,
      ...data.music.discs.expand((disc) => disc.credits)
    ])
      if (credit.role.trim().toLowerCase() == 'composer' &&
          credit.name.trim().isNotEmpty)
        credit.name.trim(),
  };
}
