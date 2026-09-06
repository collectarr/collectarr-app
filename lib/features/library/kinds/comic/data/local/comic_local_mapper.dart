import 'dart:convert';

import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_variant_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/contracts/comic_contracts.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:drift/drift.dart';

final class ComicLocalMapper {
  const ComicLocalMapper._();

  static ComicMediaRowsCompanion toMediaRow(ComicMedia media) {
    final id = media.id?.value;
    if (id == null || id.isEmpty) {
      throw StateError('Cannot persist ComicMedia without an id');
    }

    return ComicMediaRowsCompanion.insert(
      id: id,
      title: media.title,
      sortTitle: Value(media.sortTitle),
      seriesTitle: Value(media.seriesTitle),
      issueNumber: Value(media.issueNumber),
      publisher: Value(media.publisher),
      imprint: Value(media.imprint),
      releaseDate: Value(media.releaseDate),
      coverDate: Value(media.coverDate),
      pageCount: Value(media.pageCount),
      country: Value(media.country),
      language: Value(media.language),
      ageRating: Value(media.ageRating),
      crossover: Value(media.crossover),
      synopsis: Value(media.synopsis),
      genresJson: Value(_encodeStringList(media.genres)),
      searchAliasesJson: Value(_encodeStringList(media.searchAliases)),
      writersJson: Value(_encodeStringList(media.writers)),
      artistsJson: Value(_encodeStringList(media.artists)),
      inkersJson: Value(_encodeStringList(media.inkers)),
      coloristsJson: Value(_encodeStringList(media.colorists)),
      letterersJson: Value(_encodeStringList(media.letterers)),
      editorsJson: Value(_encodeStringList(media.editors)),
      coverArtistsJson: Value(_encodeStringList(media.coverArtists)),
      creatorCreditsJson: Value(_encodeMapList(
        media.creatorCredits.map((credit) => credit.toJson()),
      )),
      charactersJson: Value(_encodeStringList(media.characters)),
      characterDetailsJson: Value(_encodeMapList(media.characterDetails)),
      creatorsJson: Value(_encodeMapList(media.creators)),
      storyArcsJson: Value(_encodeStringList(media.storyArcs)),
      keyEventsJson: Value(_encodeMapList(
        media.keyEvents.map((event) => event.toJson()),
      )),
      isKeyComic: Value(media.isKeyComic),
      keyReason: Value(media.keyReason),
      variant: Value(media.variant),
      variantDescription: Value(media.variantDescription),
      barcode: Value(media.barcode),
      seriesJson: Value(_encodeOptionalMap(media.series)),
      publishingJson: Value(_encodeOptionalMap(media.publishing)),
      editionTitle: Value(media.editionTitle),
      titleExtension: Value(media.titleExtension),
      physicalFormat: Value(media.physicalFormat),
      physicalFormatLabel: Value(media.physicalFormatLabel),
      linksJson: Value(_encodeMapList(
        media.links.map((link) => link.toJson()),
      )),
      rawPayloadJson: Value(jsonEncode(media.rawPayload)),
    );
  }

  static ComicMedia fromMediaRow(
    ComicMediaRow row, {
    List<ComicRelease> releases = const <ComicRelease>[],
  }) {
    return ComicMedia(
      id: ComicMediaId(row.id),
      title: row.title,
      sortTitle: row.sortTitle,
      seriesTitle: row.seriesTitle,
      issueNumber: row.issueNumber,
      publisher: row.publisher,
      imprint: row.imprint,
      releaseDate: row.releaseDate,
      coverDate: row.coverDate,
      pageCount: row.pageCount,
      country: row.country,
      language: row.language,
      ageRating: row.ageRating,
      crossover: row.crossover,
      synopsis: row.synopsis,
      genres: _decodeStringList(row.genresJson),
      searchAliases: _decodeStringList(row.searchAliasesJson),
      writers: _decodeStringList(row.writersJson),
      artists: _decodeStringList(row.artistsJson),
      inkers: _decodeStringList(row.inkersJson),
      colorists: _decodeStringList(row.coloristsJson),
      letterers: _decodeStringList(row.letterersJson),
      editors: _decodeStringList(row.editorsJson),
      coverArtists: _decodeStringList(row.coverArtistsJson),
      creatorCredits: _decodeCreatorCredits(row.creatorCreditsJson),
      characters: _decodeStringList(row.charactersJson),
      characterDetails: _decodeMapList(row.characterDetailsJson),
      creators: _decodeMapList(row.creatorsJson),
      storyArcs: _decodeStringList(row.storyArcsJson),
      keyEvents: _decodeKeyEvents(row.keyEventsJson),
      isKeyComic: row.isKeyComic,
      keyReason: row.keyReason,
      variant: row.variant,
      variantDescription: row.variantDescription,
      barcode: row.barcode,
      series: _decodeSeries(row.seriesJson),
      publishing: _decodePublishing(row.publishingJson),
      editionTitle: row.editionTitle,
      titleExtension: row.titleExtension,
      physicalFormat: row.physicalFormat,
      physicalFormatLabel: row.physicalFormatLabel,
      links: _decodeLinks(row.linksJson),
      releases: releases,
      rawPayload: _decodeMap(row.rawPayloadJson) ?? const <String, dynamic>{},
    );
  }

  static ComicReleaseRowsCompanion toReleaseRow(
    ComicMediaId mediaId,
    ComicRelease release,
  ) {
    if (mediaId.value.isEmpty || release.id.isEmpty) {
      throw StateError('Cannot persist ComicRelease without an id');
    }

    return ComicReleaseRowsCompanion.insert(
      mediaId: mediaId.value,
      id: release.id,
      title: release.title,
      publisher: Value(release.publisher),
      imprint: Value(release.imprint),
      isbn: Value(release.isbn),
      upc: Value(release.upc),
      releaseDate: Value(release.releaseDate),
      coverImageUrl: Value(release.coverImageUrl),
      variantsJson: Value(_encodeMapList(
        release.variants.map((variant) => variant.toJson()),
      )),
    );
  }

  static ComicOwnedDetailsRowsCompanion toOwnedDetailsRow(
    String ownedItemId,
    ComicOwnedDetails details,
  ) {
    if (ownedItemId.isEmpty) {
      throw StateError('Cannot persist ComicOwnedDetails without an id');
    }

    return ComicOwnedDetailsRowsCompanion.insert(
      ownedItemId: ownedItemId,
      rawOrSlabbed: Value(details.rawOrSlabbed),
      gradingCompany: Value(details.gradingCompany),
      graderNotes: Value(details.graderNotes),
      labelType: Value(details.labelType),
      customLabel: Value(details.customLabel),
      pageQuality: Value(details.pageQuality),
      certificationNumber: Value(details.certificationNumber),
      signedBy: Value(details.signedBy),
      keyComic: Value(details.keyComic),
      keyReason: Value(details.keyReason),
      keyCategory: Value(details.keyCategory),
      keySeverity: Value(details.keySeverity),
      coverPriceCents: Value(details.coverPriceCents),
      lastBagBoardDate: Value(details.lastBagBoardDate),
    );
  }

  static ComicOwnedDetails fromOwnedDetailsRow(ComicOwnedDetailsRow row) {
    return ComicOwnedDetails(
      rawOrSlabbed: row.rawOrSlabbed,
      gradingCompany: row.gradingCompany,
      graderNotes: row.graderNotes,
      labelType: row.labelType,
      customLabel: row.customLabel,
      pageQuality: row.pageQuality,
      certificationNumber: row.certificationNumber,
      signedBy: row.signedBy,
      keyComic: row.keyComic,
      keyReason: row.keyReason,
      keyCategory: row.keyCategory,
      keySeverity: row.keySeverity,
      coverPriceCents: row.coverPriceCents,
      lastBagBoardDate: row.lastBagBoardDate,
    );
  }

  static ComicRelease fromReleaseRow(ComicReleaseRow row) {
    return ComicRelease(
      id: row.id,
      title: row.title,
      publisher: row.publisher,
      imprint: row.imprint,
      isbn: row.isbn,
      upc: row.upc,
      releaseDate: row.releaseDate,
      coverImageUrl: row.coverImageUrl,
      variants: _decodeVariants(row.variantsJson),
    );
  }

  static ComicOwnedItemsRowsCompanion toOwnedItemRow(ComicOwnedItem item) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.comic) {
      throw StateError('Cannot persist an invalid ComicOwnedItem');
    }

    final details = item.details;
    return ComicOwnedItemsRowsCompanion.insert(
      id: item.id.value,
      itemId: item.itemId,
      createdAt: Value(item.createdAt),
      isDigital: Value(item.isDigital),
      anchorType: Value(item.anchor?.apiValue),
      editionId: Value(item.anchor?.editionId),
      variantId: Value(item.anchor?.variantId),
      bundleReleaseId: Value(item.anchor?.bundleReleaseId),
      condition: Value(item.condition),
      grade: Value(item.grade),
      purchaseDate: Value(item.purchaseDate),
      pricePaidCents: Value(item.pricePaidCents),
      currency: Value(item.currency),
      personalNotes: Value(item.personalNotes),
      quantity: Value(item.quantity),
      indexNumber: Value(item.indexNumber),
      tags: Value(item.tags),
      updatedAt: item.updatedAt,
      deletedAt: Value(item.deletedAt),
      soldAt: Value(item.soldAt),
      sellPriceCents: Value(item.sellPriceCents),
      soldTo: Value(item.soldTo),
      ownerUserId: Value(item.ownerUserId),
      ownerLabel: Value(item.ownerLabel),
      locationId: Value(item.locationId),
      purchaseStore: Value(item.purchaseStore),
      collectionStatus: Value(item.collectionStatus),
      marketValueCents: Value(item.marketValueCents),
      rawOrSlabbed: Value(details.rawOrSlabbed),
      gradingCompany: Value(details.gradingCompany),
      graderNotes: Value(details.graderNotes),
      labelType: Value(details.labelType),
      customLabel: Value(details.customLabel),
      pageQuality: Value(details.pageQuality),
      certificationNumber: Value(details.certificationNumber),
      signedBy: Value(details.signedBy),
      keyComic: Value(details.keyComic),
      keyReason: Value(details.keyReason),
      keyCategory: Value(details.keyCategory),
      keySeverity: Value(details.keySeverity),
      coverPriceCents: Value(details.coverPriceCents),
      lastBagBoardDate: Value(details.lastBagBoardDate),
    );
  }

  static ComicOwnedItem fromOwnedItemRow(
    ComicOwnedItemsRow row, {
    ComicReadingState reading = const ComicReadingState(),
  }) {
    return ComicOwnedItem(
      id: ComicOwnedItemId(row.id),
      catalogRef: CatalogEntityRef(
        kind: 'comic',
        entityType: CatalogEntityType.work,
        id: row.itemId,
      ),
      createdAt: row.createdAt,
      isDigital: row.isDigital,
      anchor: PersonalItemAnchor.fromRaw(
        anchorType: row.anchorType,
        editionId: row.editionId,
        variantId: row.variantId,
        bundleReleaseId: row.bundleReleaseId,
      ),
      condition: row.condition,
      grade: row.grade,
      purchaseDate: row.purchaseDate,
      pricePaidCents: row.pricePaidCents,
      currency: row.currency,
      personalNotes: row.personalNotes,
      quantity: row.quantity,
      indexNumber: row.indexNumber,
      tags: row.tags,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      soldAt: row.soldAt,
      sellPriceCents: row.sellPriceCents,
      soldTo: row.soldTo,
      ownerUserId: row.ownerUserId,
      ownerLabel: row.ownerLabel,
      locationId: row.locationId,
      purchaseStore: row.purchaseStore,
      collectionStatus: row.collectionStatus,
      marketValueCents: row.marketValueCents,
      details: ComicOwnedDetails(
        rawOrSlabbed: row.rawOrSlabbed,
        gradingCompany: row.gradingCompany,
        graderNotes: row.graderNotes,
        labelType: row.labelType,
        customLabel: row.customLabel,
        pageQuality: row.pageQuality,
        certificationNumber: row.certificationNumber,
        signedBy: row.signedBy,
        keyComic: row.keyComic,
        keyReason: row.keyReason,
        keyCategory: row.keyCategory,
        keySeverity: row.keySeverity,
        coverPriceCents: row.coverPriceCents,
        lastBagBoardDate: row.lastBagBoardDate,
      ),
      reading: reading,
    );
  }

  static ComicReadingRowsCompanion toReadingRow(ComicOwnedItem item) {
    return ComicReadingRowsCompanion.insert(
      ownedItemId: item.id.value,
      rating: Value(item.reading.rating),
      status: Value(item.reading.status),
      startedAt: Value(item.reading.startedAt),
      finishedAt: Value(item.reading.finishedAt),
    );
  }

  static ComicReadingState fromReadingRow(ComicReadingRow row) {
    return ComicReadingState(
      rating: row.rating,
      status: row.status,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
    );
  }

  static String _encodeStringList(List<String> values) => jsonEncode(values);

  static String _encodeMapList(Iterable<Map<String, dynamic>> values) =>
      jsonEncode(values.toList(growable: false));

  static String? _encodeOptionalMap(Object? value) {
    if (value == null) return null;
    if (value is CatalogSeriesDetailsDto) {
      return value.hasData ? jsonEncode(value.toJson()) : null;
    }
    if (value is CatalogPublishingDetailsDto) {
      return value.hasData ? jsonEncode(value.toJson()) : null;
    }
    return null;
  }

  static dynamic _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  static Map<String, dynamic>? _decodeMap(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! Map<Object?, Object?>) return null;
    return Map<String, dynamic>.from(decoded);
  }

  static List<String> _decodeStringList(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <String>[];
    return decoded.whereType<String>().toList(growable: false);
  }

  static List<Map<String, dynamic>> _decodeMapList(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <Map<String, dynamic>>[];
    return decoded
        .whereType<Map<Object?, Object?>>()
        .map(Map<String, dynamic>.from)
        .toList(growable: false);
  }

  static List<ComicCreatorCredit> _decodeCreatorCredits(String raw) {
    return _decodeMapList(raw)
        .map(ComicCreatorCredit.fromJson)
        .where((credit) => credit.name.isNotEmpty)
        .toList(growable: false);
  }

  static List<ComicKeyEvent> _decodeKeyEvents(String raw) =>
      _decodeMapList(raw).map(ComicKeyEvent.fromJson).toList(growable: false);

  static List<ComicLink> _decodeLinks(String raw) {
    final links = <ComicLink>[];
    for (final value in _decodeMapList(raw)) {
      if (value['url'] is! String) continue;
      links.add(ComicLink.fromJson(value));
    }
    return links;
  }

  static List<CatalogVariantDto> _decodeVariants(String raw) {
    final variants = <CatalogVariantDto>[];
    for (final value in _decodeMapList(raw)) {
      if (value['id'] is! String) continue;
      variants.add(CatalogVariantDto.fromJson(value));
    }
    return variants;
  }

  static CatalogSeriesDetailsDto? _decodeSeries(String? raw) {
    final value = raw == null ? null : _decodeMap(raw);
    if (value == null) return null;
    final series = CatalogSeriesDetailsDto.fromJson(value);
    return series.hasData ? series : null;
  }

  static CatalogPublishingDetailsDto? _decodePublishing(String? raw) {
    final value = raw == null ? null : _decodeMap(raw);
    if (value == null) return null;
    final publishing = CatalogPublishingDetailsDto.fromJson(value);
    return publishing.hasData ? publishing : null;
  }
}
