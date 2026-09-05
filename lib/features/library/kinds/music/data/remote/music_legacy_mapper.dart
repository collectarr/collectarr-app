import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_media.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';

List<String>? tryGetList(dynamic Function() fn) {
  try {
    final res = fn();
    if (res is List) return res.whereType<String>().toList();
  } catch (_) {}
  return null;
}

MusicRelease musicReleaseFromDto(MusicReleaseDto dto) {
  return MusicCoreMapper.fromReleaseDto(dto);
}

MusicMedia musicMediaFromDto(MusicMediaDto dto) =>
    MusicCoreMapper.fromMediaDto(dto);

MusicTrack musicTrackFromDto(MusicTrackDto dto) =>
    MusicCoreMapper.fromTrackDto(dto);
