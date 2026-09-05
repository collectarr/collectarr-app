import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/models/grading_details.dart';
import 'package:flutter/foundation.dart';

/// Represents a tri-state patch operation: unchanged, set new value, or clear value.
@immutable
sealed class Patch<T> {
  const Patch();

  const factory Patch.unchanged() = Unchanged<T>;
  const factory Patch.set(T value) = SetValue<T>;
  const factory Patch.clear() = ClearValue<T>;

  R when<R>({
    required R Function() unchanged,
    required R Function(T value) set,
    required R Function() clear,
  }) {
    return switch (this) {
      Unchanged<T>() => unchanged(),
      SetValue<T>(:final value) => set(value),
      ClearValue<T>() => clear(),
    };
  }

  T? valueOrNull() => switch (this) {
        SetValue<T>(:final value) => value,
        _ => null,
      };
}

class Unchanged<T> extends Patch<T> {
  const Unchanged();
}

class SetValue<T> extends Patch<T> {
  const SetValue(this.value);
  final T value;
}

class ClearValue<T> extends Patch<T> {
  const ClearValue();
}

/// Draft containing common personal collection fields.
@immutable
class OwnedItemCommonDraft {
  const OwnedItemCommonDraft({
    this.quantity = 1,
    this.condition,
    this.grade,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.personalNotes,
    this.locationId,
    this.purchaseStore,
    this.collectionStatus,
    this.isDigital,
    this.tags,
    this.rating,
    this.readStatus,
    this.startedAt,
    this.finishedAt,
    this.editionId,
    this.variantId,
    this.bundleReleaseId,
  });

  final int quantity;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final String? locationId;
  final String? purchaseStore;
  final String? collectionStatus;
  final bool? isDigital;
  final String? tags;
  final int? rating;
  final String? readStatus;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
}

/// Sealed hierarchy of kind-specific drafts.
@immutable
sealed class OwnedDetailsDraft {
  const OwnedDetailsDraft();
  OwnedItemDetails toDetails();
}

class ComicOwnedDetailsDraft extends OwnedDetailsDraft {
  const ComicOwnedDetailsDraft({
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
    this.lastBagBoardDate,
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
  final DateTime? lastBagBoardDate;

  @override
  ComicOwnedDetails toDetails() => ComicOwnedDetails(
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
        lastBagBoardDate: lastBagBoardDate,
      );
}

class MangaOwnedDetailsDraft extends OwnedDetailsDraft {
  const MangaOwnedDetailsDraft({
    this.rawOrSlabbed,
    this.signedBy,
    this.gradingCompany,
    this.graderNotes,
    this.labelType,
    this.customLabel,
    this.pageQuality,
    this.certificationNumber,
    this.obiStripPresent = false,
    this.slipcoverPresent = false,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
    this.boxSetOuterCondition,
    this.insertsPresent = false,
    this.printing,
    this.localizedEdition,
  });

  final String? rawOrSlabbed;
  final String? signedBy;
  final String? gradingCompany;
  final String? graderNotes;
  final String? labelType;
  final String? customLabel;
  final String? pageQuality;
  final String? certificationNumber;
  final bool obiStripPresent;
  final bool slipcoverPresent;
  final bool dustJacketPresent;
  final String? dustJacketCondition;
  final String? boxSetOuterCondition;
  final bool insertsPresent;
  final String? printing;
  final String? localizedEdition;

  @override
  MangaOwnedDetails toDetails() => MangaOwnedDetails(
        grading: GradingDetails(
          rawOrSlabbed: rawOrSlabbed,
          gradingCompany: gradingCompany,
          graderNotes: graderNotes,
          labelType: labelType,
          customLabel: customLabel,
          pageQuality: pageQuality,
          certificationNumber: certificationNumber,
        ),
        signedBy: signedBy,
        gradingCompany: gradingCompany,
        graderNotes: graderNotes,
        obiStripPresent: obiStripPresent,
        slipcoverPresent: slipcoverPresent,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
        boxSetOuterCondition: boxSetOuterCondition,
        insertsPresent: insertsPresent,
        printing: printing,
        localizedEdition: localizedEdition,
      );
}

class MovieOwnedDetailsDraft extends OwnedDetailsDraft {
  const MovieOwnedDetailsDraft({
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
  MovieOwnedDetails toDetails() => MovieOwnedDetails(
        features: features,
        hdrFormats: hdrFormats,
        boxSetId: boxSetId,
        boxSetName: boxSetName,
        region: region,
        packaging: packaging,
        distributor: distributor,
      );
}

class TvOwnedDetailsDraft extends OwnedDetailsDraft {
  const TvOwnedDetailsDraft({
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
  TvOwnedDetails toDetails() => TvOwnedDetails(
        features: features,
        hdrFormats: hdrFormats,
        boxSetId: boxSetId,
        boxSetName: boxSetName,
        region: region,
        packaging: packaging,
        distributor: distributor,
      );
}

class AnimeOwnedDetailsDraft extends OwnedDetailsDraft {
  const AnimeOwnedDetailsDraft({
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
  AnimeOwnedDetails toDetails() => AnimeOwnedDetails(
        features: features,
        hdrFormats: hdrFormats,
        boxSetId: boxSetId,
        boxSetName: boxSetName,
        region: region,
        packaging: packaging,
        distributor: distributor,
      );
}

class GameOwnedDetailsDraft extends OwnedDetailsDraft {
  const GameOwnedDetailsDraft({
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
  GameOwnedDetails toDetails() => GameOwnedDetails(
        completeness: completeness,
        hasBox: hasBox,
        hasManual: hasManual,
        priceChartingId: priceChartingId,
        coreRegion: coreRegion,
        valueIsLocked: valueIsLocked,
      );
}

class MusicOwnedDetailsDraft extends OwnedDetailsDraft {
  const MusicOwnedDetailsDraft({
    this.storageDevice,
    this.storageSlot,
    this.signedBy,
    this.lastCleanedDate,
    this.matrixRunouts = const [],
  });

  final String? storageDevice;
  final String? storageSlot;
  final String? signedBy;
  final DateTime? lastCleanedDate;
  final List<MusicMatrixRunout> matrixRunouts;

  @override
  MusicOwnedDetails toDetails() => MusicOwnedDetails(
        storageDevice: storageDevice,
        storageSlot: storageSlot,
        signedBy: signedBy,
        lastCleanedDate: lastCleanedDate,
        matrixRunouts: matrixRunouts,
      );
}

class BookOwnedDetailsDraft extends OwnedDetailsDraft {
  const BookOwnedDetailsDraft({
    this.signedBy,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
  });

  final String? signedBy;
  final bool dustJacketPresent;
  final String? dustJacketCondition;

  @override
  BookOwnedDetails toDetails() => BookOwnedDetails(
        signedBy: signedBy,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
      );
}

class BoardgameOwnedDetailsDraft extends OwnedDetailsDraft {
  const BoardgameOwnedDetailsDraft({
    this.editionLanguage,
    this.editionRegion,
    this.componentCondition,
    this.componentCompleteness,
    this.missingPiecesNotes,
    this.isSleeved = false,
    this.hasCustomInsert = false,
    this.hasPaintedMiniatures = false,
    this.storageNotes,
  });

  final String? editionLanguage;
  final String? editionRegion;
  final String? componentCondition;
  final String? componentCompleteness;
  final String? missingPiecesNotes;
  final bool isSleeved;
  final bool hasCustomInsert;
  final bool hasPaintedMiniatures;
  final String? storageNotes;

  @override
  BoardgameOwnedDetails toDetails() => BoardgameOwnedDetails(
        editionLanguage: editionLanguage,
        editionRegion: editionRegion,
        componentCondition: componentCondition,
        componentCompleteness: componentCompleteness,
        missingPiecesNotes: missingPiecesNotes,
        isSleeved: isSleeved,
        hasCustomInsert: hasCustomInsert,
        hasPaintedMiniatures: hasPaintedMiniatures,
        storageNotes: storageNotes,
      );
}

class GenericOwnedDetailsDraft extends OwnedDetailsDraft {
  const GenericOwnedDetailsDraft();

  @override
  GenericOwnedDetails toDetails() => const GenericOwnedDetails();
}

OwnedDetailsDraft defaultDetailsDraftForKind(CatalogMediaKind kind) {
  if (kind == CatalogMediaKind.unknown) {
    return const GenericOwnedDetailsDraft();
  }
  return defaultLibraryKindRegistry.getByKind(kind).defaultOwnedDetailsDraft();
}

/// Command to add an owned item to collection.
@immutable
final class AddOwnedItemCommand<TDetails extends OwnedDetailsDraft> {
  const AddOwnedItemCommand({
    required this.catalogRef,
    required this.common,
    required this.details,
  });

  final CatalogEntityRef catalogRef;
  final OwnedItemCommonDraft common;
  final TDetails details;
}

/// Command to update an existing owned item in collection.
@immutable
final class UpdateOwnedItemCommand<TDetails extends OwnedDetailsDraft> {
  const UpdateOwnedItemCommand({
    required this.ownedItemId,
    this.quantity = const Patch.unchanged(),
    this.condition = const Patch.unchanged(),
    this.grade = const Patch.unchanged(),
    this.purchaseDate = const Patch.unchanged(),
    this.pricePaidCents = const Patch.unchanged(),
    this.currency = const Patch.unchanged(),
    this.personalNotes = const Patch.unchanged(),
    this.locationId = const Patch.unchanged(),
    this.purchaseStore = const Patch.unchanged(),
    this.collectionStatus = const Patch.unchanged(),
    this.isDigital = const Patch.unchanged(),
    this.tags = const Patch.unchanged(),
    this.rating = const Patch.unchanged(),
    this.readStatus = const Patch.unchanged(),
    this.startedAt = const Patch.unchanged(),
    this.finishedAt = const Patch.unchanged(),
    this.soldAt = const Patch.unchanged(),
    this.sellPriceCents = const Patch.unchanged(),
    this.soldTo = const Patch.unchanged(),
    this.marketValueCents = const Patch.unchanged(),
    this.indexNumber = const Patch.unchanged(),
    this.details = const Patch.unchanged(),
  });

  final String ownedItemId;
  final Patch<int> quantity;
  final Patch<String?> condition;
  final Patch<String?> grade;
  final Patch<DateTime?> purchaseDate;
  final Patch<int?> pricePaidCents;
  final Patch<String?> currency;
  final Patch<String?> personalNotes;
  final Patch<String?> locationId;
  final Patch<String?> purchaseStore;
  final Patch<String?> collectionStatus;
  final Patch<bool?> isDigital;
  final Patch<String?> tags;
  final Patch<int?> rating;
  final Patch<String?> readStatus;
  final Patch<DateTime?> startedAt;
  final Patch<DateTime?> finishedAt;
  final Patch<DateTime?> soldAt;
  final Patch<int?> sellPriceCents;
  final Patch<String?> soldTo;
  final Patch<int?> marketValueCents;
  final Patch<int?> indexNumber;
  final Patch<TDetails> details;
}

/// Helper extension to map concrete details to drafts.
extension OwnedItemDetailsToDraft on OwnedItemDetails {
  OwnedDetailsDraft toDraft() {
    return switch (this) {
      ComicOwnedDetails c => ComicOwnedDetailsDraft(
          rawOrSlabbed: c.rawOrSlabbed,
          gradingCompany: c.gradingCompany,
          graderNotes: c.graderNotes,
          signedBy: c.signedBy,
          labelType: c.labelType,
          customLabel: c.customLabel,
          pageQuality: c.pageQuality,
          certificationNumber: c.certificationNumber,
          keyComic: c.keyComic,
          keyReason: c.keyReason,
          keyCategory: c.keyCategory,
          keySeverity: c.keySeverity,
          coverPriceCents: c.coverPriceCents,
          lastBagBoardDate: c.lastBagBoardDate,
        ),
      MangaOwnedDetails c => MangaOwnedDetailsDraft(
          signedBy: c.signedBy,
          gradingCompany: c.gradingCompany,
          graderNotes: c.graderNotes,
          obiStripPresent: c.obiStripPresent,
          slipcoverPresent: c.slipcoverPresent,
          dustJacketPresent: c.dustJacketPresent,
          dustJacketCondition: c.dustJacketCondition,
          boxSetOuterCondition: c.boxSetOuterCondition,
          insertsPresent: c.insertsPresent,
          printing: c.printing,
          localizedEdition: c.localizedEdition,
        ),
      MovieOwnedDetails v => MovieOwnedDetailsDraft(
          features: v.features,
          hdrFormats: v.hdrFormats,
          boxSetId: v.boxSetId,
          boxSetName: v.boxSetName,
          region: v.region,
          packaging: v.packaging,
          distributor: v.distributor,
        ),
      TvOwnedDetails v => TvOwnedDetailsDraft(
          features: v.features,
          hdrFormats: v.hdrFormats,
          boxSetId: v.boxSetId,
          boxSetName: v.boxSetName,
          region: v.region,
          packaging: v.packaging,
          distributor: v.distributor,
        ),
      AnimeOwnedDetails v => AnimeOwnedDetailsDraft(
          features: v.features,
          hdrFormats: v.hdrFormats,
          boxSetId: v.boxSetId,
          boxSetName: v.boxSetName,
          region: v.region,
          packaging: v.packaging,
          distributor: v.distributor,
        ),
      GameOwnedDetails g => GameOwnedDetailsDraft(
          completeness: g.completeness,
          hasBox: g.hasBox,
          hasManual: g.hasManual,
          priceChartingId: g.priceChartingId,
          coreRegion: g.coreRegion,
          valueIsLocked: g.valueIsLocked,
        ),
      MusicOwnedDetails m => MusicOwnedDetailsDraft(
          storageDevice: m.storageDevice,
          storageSlot: m.storageSlot,
        ),
      BookOwnedDetails b => BookOwnedDetailsDraft(signedBy: b.signedBy),
      BoardgameOwnedDetails() => const BoardgameOwnedDetailsDraft(),
      GenericOwnedDetails() => const GenericOwnedDetailsDraft(),
      _ => const GenericOwnedDetailsDraft(),
    };
  }
}
