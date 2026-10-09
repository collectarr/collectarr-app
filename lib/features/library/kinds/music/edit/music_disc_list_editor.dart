import 'package:uuid/uuid.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_disc_edit_utils.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_track_list_editor.dart';

/// Owns disc ordering and disc metadata for one album edit session.
final class MusicDiscListEditor {
  MusicDiscListEditor.fromDiscs(Iterable<MusicDisc> source)
      : discs = [for (final disc in source) copyMusicDisc(disc)] {
    trackList = MusicTrackListEditor(discs);
  }

  final List<MusicDisc> discs;
  late final MusicTrackListEditor trackList;

  String? get formatSummary => formatAlbumDiscsSummary(discs);

  bool get hasUnclassifiedFormat =>
      discs.any((disc) => disc.format != null && disc.formatFamily == null);

  void addDisc({String? format, MusicDiscFormatFamily? formatFamily}) {
    final nextNumber = discs.fold<int>(
          0,
          (largest, disc) =>
              disc.discNumber > largest ? disc.discNumber : largest,
        ) +
        1;
    final defaultFormat =
        format ?? (discs.isNotEmpty ? discs.first.format : null);
    final defaultFamily =
        formatFamily ?? (discs.isNotEmpty ? discs.first.formatFamily : null);
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
    bool clearFormatFamily = false,
  }) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    final resolvedFormat = _text(format);
    final resolvedFamily =
        clearFormatFamily ? null : formatFamily ?? discs[index].formatFamily;
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

  void updateDiscRecordingDate(MusicDiscId discId, PartialDate? value) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = copyMusicDisc(
      discs[index],
      recordingDate: value,
      replaceRecordingDate: true,
    );
  }

  void updateDiscRecordingLocations(
    MusicDiscId discId,
    List<String> recordingLocations,
  ) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = copyMusicDisc(
      discs[index],
      recordingLocations: recordingLocations,
      replaceRecordingLocations: true,
    );
  }

  void updateDiscIsLive(MusicDiscId discId, bool? value) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = copyMusicDisc(
      discs[index],
      isLive: value,
      replaceIsLive: true,
    );
  }

  void updateDiscSparsCode(MusicDiscId discId, String? value) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = copyMusicDisc(
      discs[index],
      sparsCode: _text(value),
      replaceSparsCode: true,
    );
  }

  void updateDiscCredits(MusicDiscId discId, List<MusicCredit> credits) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = copyMusicDisc(discs[index], credits: credits);
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
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
