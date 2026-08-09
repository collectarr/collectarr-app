import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class LibraryAddKindDraft {
  const LibraryAddKindDraft();

  CatalogMediaKind get kind;
  OwnedDetailsDraft toOwnedDetailsDraft();
}

final class ComicAddDraft extends LibraryAddKindDraft {
  const ComicAddDraft({
    this.rawOrSlabbed,
    this.gradingCompany,
    this.graderNotes,
    this.signedBy,
    this.labelType,
    this.customLabel,
    this.pageQuality,
    this.certificationNumber,
    this.keyComic = false,
    this.keyReason,
    this.keyCategory,
    this.keySeverity,
    this.coverPriceCents,
  });

  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final String? labelType;
  final String? customLabel;
  final String? pageQuality;
  final String? certificationNumber;
  final bool keyComic;
  final String? keyReason;
  final String? keyCategory;
  final String? keySeverity;
  final int? coverPriceCents;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => ComicOwnedDetailsDraft(
        rawOrSlabbed: rawOrSlabbed,
        gradingCompany: gradingCompany,
        graderNotes: graderNotes,
        signedBy: signedBy,
        labelType: labelType,
        customLabel: customLabel,
        pageQuality: pageQuality,
        certificationNumber: certificationNumber,
        keyComic: keyComic,
        keyReason: keyReason,
        keyCategory: keyCategory,
        keySeverity: keySeverity,
        coverPriceCents: coverPriceCents,
      );
}

final class VideoAddDraft extends LibraryAddKindDraft {
  const VideoAddDraft({
    this.features,
    this.hdrFormats = const [],
    this.boxSetId,
    this.boxSetName,
    this.region,
    this.packaging,
    this.distributor,
  });

  final String? features;
  final List<String> hdrFormats;
  final String? boxSetId;
  final String? boxSetName;
  final String? region;
  final String? packaging;
  final String? distributor;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => VideoOwnedDetailsDraft(
        features: features,
        hdrFormats: hdrFormats,
        boxSetId: boxSetId,
        boxSetName: boxSetName,
        region: region,
        packaging: packaging,
        distributor: distributor,
      );
}

final class GameAddDraft extends LibraryAddKindDraft {
  const GameAddDraft({
    this.completeness,
    this.hasBox,
    this.hasManual,
    this.priceChartingId,
    this.coreRegion,
    this.valueIsLocked,
  });

  final String? completeness;
  final bool? hasBox;
  final bool? hasManual;
  final String? priceChartingId;
  final String? coreRegion;
  final bool? valueIsLocked;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => GameOwnedDetailsDraft(
        completeness: completeness,
        hasBox: hasBox,
        hasManual: hasManual,
        priceChartingId: priceChartingId,
        coreRegion: coreRegion,
        valueIsLocked: valueIsLocked,
      );
}

final class MusicAddDraft extends LibraryAddKindDraft {
  const MusicAddDraft({
    this.storageDevice,
    this.storageSlot,
  });

  final String? storageDevice;
  final String? storageSlot;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => MusicOwnedDetailsDraft(
        storageDevice: storageDevice,
        storageSlot: storageSlot,
      );
}

final class BookAddDraft extends LibraryAddKindDraft {
  const BookAddDraft();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => const BookOwnedDetailsDraft();
}

final class BoardGameAddDraft extends LibraryAddKindDraft {
  const BoardGameAddDraft();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => const BoardgameOwnedDetailsDraft();
}

final class GenericAddDraft extends LibraryAddKindDraft {
  const GenericAddDraft();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.unknown;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => const GenericOwnedDetailsDraft();
}

LibraryAddKindDraft defaultAddKindDraftForKind(CatalogMediaKind kind) {
  return switch (kind) {
    CatalogMediaKind.comic || CatalogMediaKind.manga => const ComicAddDraft(),
    CatalogMediaKind.movie ||
    CatalogMediaKind.tv ||
    CatalogMediaKind.anime =>
      const VideoAddDraft(),
    CatalogMediaKind.game => const GameAddDraft(),
    CatalogMediaKind.music => const MusicAddDraft(),
    CatalogMediaKind.book => const BookAddDraft(),
    CatalogMediaKind.boardgame => const BoardGameAddDraft(),
    _ => const GenericAddDraft(),
  };
}
