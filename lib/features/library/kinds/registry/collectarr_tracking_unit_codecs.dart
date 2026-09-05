import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_codec.dart';

/// Composition-root registrations for kind-owned tracking-unit persistence.
///
/// The collection repository receives this list from the application root;
/// it does not import or dispatch to concrete kinds itself.
const List<TrackingUnitCodec> collectarrTrackingUnitCodecs = [
  TvTrackingUnitCodec(),
  AnimeTrackingUnitCodec(),
  BookTrackingUnitCodec(),
  MangaTrackingUnitCodec(),
  ComicTrackingUnitCodec(),
];
