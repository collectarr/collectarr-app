import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_watch_session_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_watch_session_codec.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';

/// Composition-root registrations for TV and Anime watch-session storage.
const List<WatchSessionCodec> collectarrWatchSessionCodecs = [
  TvWatchSessionCodec(),
  AnimeWatchSessionCodec(),
];
