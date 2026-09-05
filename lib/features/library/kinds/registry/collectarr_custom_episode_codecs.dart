import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_custom_episode_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_custom_episode_codec.dart';
import 'package:collectarr_app/features/library/tracking/custom_episode_codec.dart';

/// Composition-root registrations for TV and Anime custom-episode storage.
const List<CustomEpisodeCodec> collectarrCustomEpisodeCodecs = [
  TvCustomEpisodeCodec(),
  AnimeCustomEpisodeCodec(),
];
