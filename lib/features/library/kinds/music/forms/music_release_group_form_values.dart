import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';

/// Flutter independent values for the conceptual album/release group.
final class MusicReleaseGroupFormValues {
  MusicReleaseGroupFormValues({
    this.title = '',
    this.sortTitle = '',
    this.artist = '',
    this.originalTitle = '',
    this.originalReleaseDate,
    this.recordingDate,
    List<String> studios = const [],
    this.isLive,
    List<String> genres = const [],
    this.coverImageUrl = '',
  })  : genres = List<String>.of(genres),
        studios = List<String>.of(studios);

  factory MusicReleaseGroupFormValues.fromGroup(MusicReleaseGroup group) =>
      MusicReleaseGroupFormValues(
        title: group.title,
        sortTitle: group.sortTitle ?? '',
        artist: group.artist ?? '',
        originalTitle: group.originalTitle ?? '',
        originalReleaseDate: group.originalReleaseDate,
        recordingDate: group.recordingDate,
        studios: group.studios,
        isLive: group.isLive,
        genres: group.genres,
        coverImageUrl: group.coverImageUrl ?? '',
      );

  String title;
  String sortTitle;
  String artist;
  String originalTitle;
  DateTime? originalReleaseDate;
  DateTime? recordingDate;
  List<String> studios;
  bool? isLive;
  List<String> genres;
  String coverImageUrl;
}
