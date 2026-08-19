import 'package:collectarr_app/features/library/media/video/catalog/video_catalog_item.dart';

class VideoMediaRef {
  const VideoMediaRef({
    required this.id,
    this.title,
    this.formatLabel,
    this.discNumber,
    this.audioTracks = const [],
    this.subtitles = const [],
  });

  final String id;
  final String? title;
  final String? formatLabel;
  final int? discNumber;
  final List<String> audioTracks;
  final List<String> subtitles;

  List<dynamic> get episodes => const [];
}

class VideoRelease {
  const VideoRelease({
    required this.id,
    required this.title,
    this.publisher,
    this.distributor,
    this.barcode,
    this.releaseDate,
    this.formatLabel,
    this.frontCoverUrl,
    this.media = const <VideoMediaRef>[],
    this.videoDetails,
  });

  final String id;
  final String title;
  final String? publisher;
  final String? distributor;
  final String? barcode;
  final DateTime? releaseDate;
  final String? formatLabel;
  final String? frontCoverUrl;
  final List<VideoMediaRef> media;
  final VideoTechnicalMetadata? videoDetails;
}
