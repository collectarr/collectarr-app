import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class MusicWorkspaceDto implements LibraryWorkspaceDto {
  const MusicWorkspaceDto({
    required this.common,
    required this.personal,
    required this.music,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final MusicCatalogItem music;

  // Delegated LibraryWorkspaceDto getters from WorkspaceCommonProjection:
  @override
  String get title => common.title;
  @override
  String? get seriesTitle => common.seriesTitle;
  @override
  String? get itemNumber => common.itemNumber;
  @override
  String? get publisher => common.publisher;
  @override
  DateTime? get releaseDate => common.releaseDate;
  @override
  String? get variant => common.variant;
  @override
  String? get barcode => common.barcode;
  @override
  String? get grade => common.grade;
  @override
  String? get country => common.country;
  @override
  String? get language => common.language;
  @override
  String? get currency => common.currency;
  @override
  String? get referenceFormatLabel => common.referenceFormatLabel;
  @override
  String? get coverImageUrl => common.coverImageUrl;

  // Delegated LibraryWorkspaceDto getters from PersonalCopyProjection:
  @override
  bool get isOwned => personal.isOwned;
  @override
  bool get isWishlisted => personal.isWishlisted;
  @override
  String? get condition => personal.condition;
  @override
  String? get locationPath => personal.locationPath;
  @override
  int? get rating => personal.rating;
  @override
  int? get pricePaidCents => personal.pricePaidCents;
  @override
  DateTime? get addedAt => personal.addedAt;
  @override
  DateTime get updatedAt => personal.updatedAt;
  @override
  String? get tags => personal.tags;
  @override
  String? get collectionStatus => personal.collectionStatus;

  // Domain convenience getters delegating to MusicCatalogItem:
  String? get artist => music.work.artist;
  int? get trackCount => music.recording.trackCount;

  factory MusicWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    final musicCatalogItem = MusicCatalogMapper.mapWorkspaceEntryToMusic(entry);

    return MusicWorkspaceDto(
      common: WorkspaceCommonProjection(
        title: entry.resolvedTitle,
        seriesTitle: entry.series?.seriesTitle,
        itemNumber: entry.itemNumber,
        publisher: entry.publisher,
        releaseDate: entry.releaseDate,
        variant: entry.variant,
        barcode: entry.barcode,
        grade: entry.grade,
        country: entry.country,
        language: entry.language,
        currency: entry.currency,
        referenceFormatLabel: entry.referenceFormatLabel,
        coverImageUrl: entry.coverImageUrl,
      ),
      personal: PersonalCopyProjection(
        isOwned: entry.isOwned,
        isWishlisted: entry.isWishlisted,
        condition: entry.condition,
        locationPath: entry.locationPath,
        rating: entry.rating,
        pricePaidCents: entry.pricePaidCents,
        addedAt: entry.addedAt,
        updatedAt: entry.updatedAt,
        tags: entry.tags,
        collectionStatus: entry.collectionStatus,
      ),
      music: musicCatalogItem,
    );
  }
}
