import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/tracking/game_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_entry_codec.dart';

/// Composition-root registrations for kind-owned tracking-entry semantics.
const List<TrackingEntryCodec> collectarrTrackingEntryCodecs = [
  ComicTrackingEntryCodec(),
  MangaTrackingEntryCodec(),
  BookTrackingEntryCodec(),
  GameTrackingEntryCodec(),
  BoardGameTrackingEntryCodec(),
  MovieTrackingEntryCodec(),
  TvTrackingEntryCodec(),
  AnimeTrackingEntryCodec(),
  MusicTrackingEntryCodec(),
];
