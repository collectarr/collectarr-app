import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

abstract interface class MusicWorkspaceProjection
    implements LibraryWorkspaceDto {
  WorkspaceCommonProjection get common;
  PersonalEntryProjection get personal;
  MusicAlbum get music;
  MusicEntryListeningSummary? get listeningSummary;

  String? get currency;
  String? get artist;
  String? get catalogNumber;
  String? get format;
  String? get referenceFormatLabel;
  String? get packaging;
  String? get boxSet;
  String? get publisher;
  String? get genre;
  DateTime? get releaseDate;
  String? get identifierCode;
  String? get barcode;
  String? get country;
  int? get listenCount;
  DateTime? get lastListened;
  int? get discCount;
  int? get trackCount;
  bool? get isLive;
  List<String> get genres;
  List<Map<String, dynamic>> get credits;
}

abstract class MusicWorkspaceProjectionValues
    implements MusicWorkspaceProjection {
  MusicWorkspaceProjectionValues({
    required this.common,
    required this.personal,
    required this.music,
    this.listeningSummary,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalEntryProjection personal;
  @override
  final MusicAlbum music;
  @override
  final MusicEntryListeningSummary? listeningSummary;

  String get title => common.title;

  @override
  String get primaryLabel => title;

  @override
  String? get imageUrl => common.coverImageUrl;

  @override
  String? get secondaryLabel => null;

  @override
  String? get currency => common.currency;

  @override
  String? get artist {
    final value = music.artist?.trim();
    if (value != null && value.isNotEmpty) return value;
    for (final contribution in music.contributions) {
      final role = contribution.role.trim().toLowerCase();
      if (!(role.contains('artist') ||
          role.contains('performer') ||
          role.contains('musician') ||
          role.contains('band'))) {
        continue;
      }
      final name = contribution.displayName?.trim();
      if (name != null && name.isNotEmpty) return name;
    }
    return null;
  }

  @override
  String? get catalogNumber => music.catalogNumber;

  @override
  String? get format => music.formatSummary;

  @override
  String? get referenceFormatLabel => format;

  @override
  String? get packaging => music.packaging;

  @override
  String? get boxSet => music.boxSet;

  @override
  String? get publisher => music.publisher;

  @override
  String? get genre => music.genres.isEmpty ? null : music.genres.join(', ');

  @override
  DateTime? get releaseDate => music.releaseDate;

  @override
  String? get identifierCode => music.barcode;

  @override
  String? get barcode => identifierCode;

  @override
  String? get country => music.countryCode;

  @override
  int? get listenCount => listeningSummary?.totalListenCount;

  @override
  DateTime? get lastListened => listeningSummary?.lastListened;

  String? get coverImageUrl => music.coverImageUrl ?? common.coverImageUrl;

  @override
  int? get discCount => music.discs.isEmpty ? null : music.discs.length;

  @override
  int? get trackCount => music.trackCount;

  @override
  bool? get isLive => music.isLive;

  @override
  List<String> get genres => music.genres;

  @override
  List<Map<String, dynamic>> get credits => [
        for (final credit in music.contributions) credit.toJson(),
        for (final credit in music.artistCredits) credit.toJson(),
      ];

  @override
  Iterable<String> get searchTokens => [
        if (artist != null) artist!,
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
        if (catalogNumber != null) catalogNumber!,
        ...genres,
      ];
}

final class MusicCatalogItemWorkspaceDto
    extends MusicWorkspaceProjectionValues {
  MusicCatalogItemWorkspaceDto({
    required super.common,
    required super.personal,
    required super.music,
    super.listeningSummary,
  });
}

final class MusicLibraryEntryWorkspaceDto
    extends MusicWorkspaceProjectionValues {
  MusicLibraryEntryWorkspaceDto({
    required super.common,
    required super.personal,
    required super.music,
    super.listeningSummary,
  });
}
