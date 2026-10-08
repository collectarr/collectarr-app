import 'package:uuid/uuid.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_album_form_values.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_track_list_editor.dart';

final class MusicAlbumEditDraft {
  MusicAlbumEditDraft.fromAlbum(
    MusicAlbum album,
  )   : original = album,
        values = MusicAlbumFormValues.fromAlbum(album),
        contributions = List.of(album.contributions),
        discs = [
          for (final disc in album.discs) copyMusicDisc(disc),
        ],
        externalLinks = List.of(album.externalLinks) {
    trackList = MusicTrackListEditor(discs);
  }

  final MusicAlbum original;
  final MusicAlbumFormValues values;
  List<MusicAlbumContribution> contributions;
  final List<MusicDisc> discs;
  late final MusicTrackListEditor trackList;
  List<MusicExternalLink> externalLinks;
  final Map<String, List<({String listName, String value, String? mediaKind})>>
      pendingDetailVocabularyValues = {};

  String? get formatSummary => formatAlbumDiscsSummary(discs);

  void addDisc({String? format, MusicDiscFormatFamily? formatFamily}) {
    final nextNumber = discs.fold<int>(
          0,
          (largest, disc) =>
              disc.discNumber > largest ? disc.discNumber : largest,
        ) +
        1;
    final defaultFormat =
        format ?? (discs.isNotEmpty ? discs.first.format : null);
    final defaultFamily = formatFamily ??
        (discs.isNotEmpty
            ? discs.first.formatFamily
            : MusicDiscFormatFamily.fromFormatName(defaultFormat));
    discs.add(
      MusicDisc(
        id: MusicDiscId(const Uuid().v4()),
        discNumber: nextNumber,
        format: defaultFormat,
        formatFamily: defaultFamily,
        tracks: const [],
      ),
    );
  }

  void removeDisc(MusicDiscId discId) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    trackList.clearDurationInputsFor(discs[index].tracks);
    discs.removeAt(index);
    _renumberDiscs();
  }

  void reorderDisc(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= discs.length) return;
    if (newIndex > oldIndex) newIndex--;
    if (newIndex < 0 || newIndex >= discs.length || newIndex == oldIndex) {
      return;
    }
    final disc = discs.removeAt(oldIndex);
    discs.insert(newIndex, disc);
    _renumberDiscs();
  }

  void _renumberDiscs() {
    for (var index = 0; index < discs.length; index++) {
      discs[index] = copyMusicDisc(
        discs[index],
        discNumber: index + 1,
      );
    }
  }

  void updateDiscTitle(MusicDiscId discId, String title) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = copyMusicDisc(
      discs[index],
      title: _text(title),
      replaceTitle: true,
    );
  }

  void updateDiscFormat(
    MusicDiscId discId,
    String? format, {
    MusicDiscFormatFamily? formatFamily,
  }) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    final resolvedFormat = _text(format);
    final resolvedFamily =
        formatFamily ?? MusicDiscFormatFamily.fromFormatName(resolvedFormat);
    discs[index] = copyMusicDisc(
      discs[index],
      format: resolvedFormat,
      replaceFormat: true,
      formatFamily: resolvedFamily,
      replaceFormatFamily: true,
    );
  }

  void updateDiscFormatFamily(
    MusicDiscId discId,
    MusicDiscFormatFamily? formatFamily,
  ) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = copyMusicDisc(
      discs[index],
      formatFamily: formatFamily,
      replaceFormatFamily: true,
    );
  }

  void updateDiscSoundTypes(MusicDiscId discId, List<String> soundTypes) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = copyMusicDisc(
      discs[index],
      soundTypes: soundTypes,
      replaceSoundTypes: true,
    );
  }

  void updateDiscColor(MusicDiscId discId, String? color) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = copyMusicDisc(
      discs[index],
      color: _text(color),
      replaceColor: true,
    );
  }

  void updateDiscVinylWeightGrams(MusicDiscId discId, int? vinylWeightGrams) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = copyMusicDisc(
      discs[index],
      vinylWeightGrams: vinylWeightGrams,
      replaceVinylWeightGrams: true,
    );
  }

  void updateDiscRpm(MusicDiscId discId, String? rpm) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = copyMusicDisc(
      discs[index],
      rpm: _text(rpm),
      replaceRpm: true,
    );
  }

  void updateDiscMatrixNumber(MusicDiscId discId, String? matrixNumber) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = copyMusicDisc(
      discs[index],
      matrixNumber: _text(matrixNumber),
      replaceMatrixNumber: true,
    );
  }

  void updateDiscMatrixNumberSideA(
      MusicDiscId discId, String? matrixNumberSideA) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = copyMusicDisc(
      discs[index],
      matrixNumberSideA: _text(matrixNumberSideA),
      replaceMatrixNumberSideA: true,
    );
  }

  void updateDiscMatrixNumberSideB(
      MusicDiscId discId, String? matrixNumberSideB) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = copyMusicDisc(
      discs[index],
      matrixNumberSideB: _text(matrixNumberSideB),
      replaceMatrixNumberSideB: true,
    );
  }

  MusicAlbum toAlbum() {
    return MusicAlbumFormAdapter.update(
      original,
      values,
      discs: discs,
      externalLinks: externalLinks
          .where((link) => link.url.trim().isNotEmpty)
          .toList(growable: false),
      contributions: contributions,
    );
  }
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
