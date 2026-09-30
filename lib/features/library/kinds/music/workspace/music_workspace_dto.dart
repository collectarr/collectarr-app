import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

abstract interface class MusicWorkspaceProjection
    implements LibraryWorkspaceDto {
  WorkspaceCommonProjection get common;
  PersonalCopyProjection get personal;
  MusicRelease get music;
  MusicCatalogItemListeningSummary? get listeningSummary;

  String? get currency;
  String? get artist;
  String? get catalogNumber;
  String? get format;
  String? get referenceFormatLabel;
  String? get releaseType;
  String? get packaging;
  String? get boxSet;
  String? get publisher;
  String? get genre;
  DateTime? get releaseDate;
  String? get identifierCode;
  String? get barcode;
  String? get country;
  String? get language;
  int? get listenCount;
  DateTime? get lastListened;
  int? get discCount;
  int? get trackCount;
  String? get releaseStatus;
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
  final PersonalCopyProjection personal;
  @override
  final MusicRelease music;
  @override
  final MusicCatalogItemListeningSummary? listeningSummary;

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
  String? get format => music.physicalFormatLabel ?? music.releaseType;

  @override
  String? get referenceFormatLabel => format;

  @override
  String? get releaseType => music.releaseType;

  @override
  String? get packaging => music.packaging;

  @override
  String? get boxSet => music.boxSetTitle;

  @override
  String? get publisher => music.publisher;

  @override
  String? get genre => music.genres.isEmpty ? null : music.genres.join(', ');

  @override
  DateTime? get releaseDate => music.releaseDate;

  @override
  String? get identifierCode => music.barcode ?? music.upc;

  @override
  String? get barcode => identifierCode;

  @override
  String? get country => music.countryCode;

  @override
  String? get language => music.language;

  @override
  int? get listenCount => listeningSummary?.totalListenCount;

  @override
  DateTime? get lastListened => listeningSummary?.lastListened;

  String? get coverImageUrl => music.coverImageUrl ?? common.coverImageUrl;

  @override
  int? get discCount => music.mediums.isEmpty ? null : music.mediums.length;

  @override
  int? get trackCount => music.trackCount;

  @override
  String? get releaseStatus => music.releaseStatus;

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

final class MusicOwnedCopyWorkspaceDto extends MusicWorkspaceProjectionValues {
  MusicOwnedCopyWorkspaceDto({
    required super.common,
    required super.personal,
    required super.music,
    super.listeningSummary,
  });
}
