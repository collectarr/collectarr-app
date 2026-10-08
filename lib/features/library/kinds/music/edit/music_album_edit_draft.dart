import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_album_form_values.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_track_list_editor.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_disc_list_editor.dart';
import 'package:collectarr_app/features/library/edit/session/library_vocabulary_edit_accumulator.dart';

final class MusicAlbumEditDraft {
  MusicAlbumEditDraft.fromAlbum(
    MusicAlbum album,
  )   : original = album,
        values = MusicAlbumFormValues.fromAlbum(album),
        contributions = List.of(album.contributions),
        discList = MusicDiscListEditor.fromDiscs(album.discs),
        externalLinks = List.of(album.externalLinks);

  final MusicAlbum original;
  final MusicAlbumFormValues values;
  List<MusicAlbumContribution> contributions;
  final MusicDiscListEditor discList;
  List<MusicDisc> get discs => discList.discs;
  MusicTrackListEditor get trackList => discList.trackList;
  String? get formatSummary => discList.formatSummary;
  List<MusicExternalLink> externalLinks;
  LibraryVocabularyEditAccumulator vocabularyEdits =
      LibraryVocabularyEditAccumulator();

  MusicAlbum toAlbum() {
    return MusicAlbumFormAdapter.update(
      original,
      values,
      discs: discList.discs,
      externalLinks: externalLinks
          .where((link) => link.url.trim().isNotEmpty)
          .toList(growable: false),
      contributions: contributions,
    );
  }
}
