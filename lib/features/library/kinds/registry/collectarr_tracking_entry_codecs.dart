import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_entry_codec.dart';

/// Composition-root registrations for kind-owned tracking-entry semantics.
const List<TrackingEntryCodec> collectarrTrackingEntryCodecs = [
  TvTrackingEntryCodec(),
  AnimeTrackingEntryCodec(),
];
