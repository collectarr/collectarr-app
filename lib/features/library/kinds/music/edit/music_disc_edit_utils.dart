import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';

MusicDisc copyMusicDisc(
  MusicDisc disc, {
  int? discNumber,
  String? title,
  bool replaceTitle = false,
  MusicDiscFormatFamily? formatFamily,
  bool replaceFormatFamily = false,
  String? format,
  bool replaceFormat = false,
  List<String>? soundTypes,
  bool replaceSoundTypes = false,
  PartialDate? recordingDate,
  bool replaceRecordingDate = false,
  List<String>? recordingLocations,
  bool replaceRecordingLocations = false,
  bool? isLive,
  bool replaceIsLive = false,
  String? sparsCode,
  bool replaceSparsCode = false,
  List<MusicCredit>? credits,
  String? color,
  bool replaceColor = false,
  int? vinylWeightGrams,
  bool replaceVinylWeightGrams = false,
  String? rpm,
  bool replaceRpm = false,
  String? matrixNumber,
  bool replaceMatrixNumber = false,
  String? matrixNumberSideA,
  bool replaceMatrixNumberSideA = false,
  String? matrixNumberSideB,
  bool replaceMatrixNumberSideB = false,
  List<MusicTrack>? tracks,
}) {
  return MusicDisc(
    id: disc.id,
    discNumber: discNumber ?? disc.discNumber,
    title: replaceTitle ? title : title ?? disc.title,
    formatFamily:
        replaceFormatFamily ? formatFamily : formatFamily ?? disc.formatFamily,
    format: replaceFormat ? format : format ?? disc.format,
    soundTypes: replaceSoundTypes
        ? (soundTypes ?? const [])
        : (soundTypes ?? disc.soundTypes),
    recordingDate: replaceRecordingDate
        ? recordingDate
        : recordingDate ?? disc.recordingDate,
    recordingLocations: replaceRecordingLocations
        ? (recordingLocations ?? const [])
        : (recordingLocations ?? disc.recordingLocations),
    isLive: replaceIsLive ? isLive : isLive ?? disc.isLive,
    sparsCode: replaceSparsCode ? sparsCode : sparsCode ?? disc.sparsCode,
    credits: credits ?? disc.credits,
    color: replaceColor ? color : color ?? disc.color,
    vinylWeightGrams: replaceVinylWeightGrams
        ? vinylWeightGrams
        : vinylWeightGrams ?? disc.vinylWeightGrams,
    rpm: replaceRpm ? rpm : rpm ?? disc.rpm,
    matrixNumber:
        replaceMatrixNumber ? matrixNumber : matrixNumber ?? disc.matrixNumber,
    matrixNumberSideA: replaceMatrixNumberSideA
        ? matrixNumberSideA
        : matrixNumberSideA ?? disc.matrixNumberSideA,
    matrixNumberSideB: replaceMatrixNumberSideB
        ? matrixNumberSideB
        : matrixNumberSideB ?? disc.matrixNumberSideB,
    tracks: tracks ?? disc.tracks,
  );
}
