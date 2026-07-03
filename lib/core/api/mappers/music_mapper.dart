import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/music/music_domain.dart';

MusicRelease musicReleaseFromDto(MusicReleaseDto dto) =>
    MusicRelease.fromDto(dto);

MusicMedia musicMediaFromDto(MusicMediaDto dto) => MusicMedia.fromDto(dto);

MusicTrack musicTrackFromDto(MusicTrackDto dto) => MusicTrack.fromDto(dto);
