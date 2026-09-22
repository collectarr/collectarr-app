import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';

export 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
export 'package:collectarr_app/features/library/kinds/music/workspace/music_preference_codec.dart';

/// Music fields are shared by the three scoped registries, but every scoped
/// schema selects only the fields owned by its entity.
abstract final class MusicWorkspaceFields {
  static final title = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.primaryLabel,
    entityScope: LibraryEntityScope.work,
  );

  static final artist = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.artist,
    label: 'Artist',
    getValue: (dto) => dto.artist,
    entityScope: LibraryEntityScope.work,
  );

  static final publisher = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.publisher,
    label: 'Label',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.work,
  );

  static final genre = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.genre,
    label: 'Genre',
    getValue: (dto) => dto.genre,
    entityScope: LibraryEntityScope.work,
  );

  static final releaseCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseCount,
    label: 'Release count',
    getValue: (dto) => dto.releaseCount,
    entityScope: LibraryEntityScope.work,
  );

  static final aggregateListenCount =
      numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.aggregateListenCount,
    label: 'Aggregate listens',
    getValue: (dto) => dto.aggregateListenCount,
    entityScope: LibraryEntityScope.work,
  );

  static final aggregateLastListened =
      dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.aggregateLastListened,
    label: 'Last listened',
    getValue: (dto) => dto.aggregateLastListened,
    entityScope: LibraryEntityScope.work,
  );

  static final listenedReleaseCount =
      numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.listenedReleaseCount,
    label: 'Listened releases',
    getValue: (dto) => dto.listenedReleaseCount,
    entityScope: LibraryEntityScope.work,
  );

  static final listenCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.listenCount,
    label: 'Listen count',
    getValue: (dto) => dto.listenCount,
    entityScope: LibraryEntityScope.release,
  );

  static final lastListened = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.lastListened,
    label: 'Last listened',
    getValue: (dto) => dto.lastListened,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseDate = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.work,
  );

  static final trackCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.trackCount,
    label: 'Track count',
    getValue: (dto) => dto.trackCount,
    entityScope: LibraryEntityScope.work,
  );

  static final barcode = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.barcode,
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.release,
  );

  static final condition =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
        context.source.ownedItemDispatch,
      );
      return owned is MusicOwnedItem ? owned.condition : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final location =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.copy,
  );

  static final status =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    entityScope: LibraryEntityScope.copy,
  );

  static final cover =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.imageUrl,
    entityScope: LibraryEntityScope.work,
  );

  static final rating =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, bool>(
    id: MusicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime>(
    id: MusicFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>(
    id: MusicFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final catalogNumber = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.catalogNumber,
    label: 'Catalog Number',
    getValue: (dto) => dto.catalogNumber,
    entityScope: LibraryEntityScope.release,
  );

  static final format = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.format,
    label: 'Format',
    getValue: (dto) => dto.format,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseType = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseType,
    label: 'Release type',
    getValue: (dto) => dto.releaseType,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseStatus = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseStatus,
    label: 'Release status',
    getValue: (dto) => dto.releaseStatus,
    entityScope: LibraryEntityScope.release,
  );

  static final language = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.language,
    label: 'Language',
    getValue: (dto) => dto.language,
    entityScope: LibraryEntityScope.release,
  );

  static final packaging = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.packaging,
    label: 'Packaging',
    getValue: (dto) => dto.packaging,
    entityScope: LibraryEntityScope.release,
  );

  static final boxSet = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.boxSet,
    label: 'Box set',
    getValue: (dto) => dto.boxSet,
    entityScope: LibraryEntityScope.release,
  );

  static final country = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.country,
    label: 'Country',
    getValue: (dto) => dto.country,
    entityScope: LibraryEntityScope.release,
  );

  static final discCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.discCount,
    label: 'Disc Count',
    getValue: (dto) => dto.discCount,
    entityScope: LibraryEntityScope.release,
  );

  static final signedBy =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.signedBy,
    label: 'Signed By',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
        context.source.ownedItemDispatch,
      );
      return owned is MusicOwnedItem ? owned.details.signedBy : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final grade =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.grade,
    label: 'Grade',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
        context.source.ownedItemDispatch,
      );
      return owned is MusicOwnedItem ? owned.grade : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final storage =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.storage,
    label: 'Storage',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
        context.source.ownedItemDispatch,
      );
      if (owned is! MusicOwnedItem) return null;
      final values = [
        for (final medium in owned.details.media) ...[
          if (medium.storageDevice?.trim().isNotEmpty == true)
            medium.storageDevice!.trim(),
          if (medium.storageSlot?.trim().isNotEmpty == true)
            medium.storageSlot!.trim(),
        ],
      ];
      return values.isEmpty ? null : values.join(' / ');
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final purchaseDate =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>(
    id: MusicFieldIds.purchaseDate,
    label: 'Purchase date',
    getValue: (context) => context.source.purchaseDate,
    entityScope: LibraryEntityScope.copy,
  );

  static final marketValue =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.marketValue,
    label: 'Market value',
    getValue: (context) => context.source.marketValueCents,
    entityScope: LibraryEntityScope.copy,
  );

  static final indexNumber =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.indexNumber,
    label: 'Index number',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
        context.source.ownedItemDispatch,
      );
      return owned is MusicOwnedItem ? owned.indexNumber : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final lastCleaned =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>(
    id: MusicFieldIds.lastCleaned,
    label: 'Last cleaned',
    getValue: (context) {
      final owned = MusicOwnedItemProjection.fromDispatch(
        context.source.ownedItemDispatch,
      );
      return owned is MusicOwnedItem ? owned.details.lastCleanedDate : null;
    },
    entityScope: LibraryEntityScope.copy,
  );
}

/// Materializes the Music field catalog for one entity boundary.
///
/// The same presentation value can be useful in more than one projection,
/// but each projection still owns its own field definition. This keeps the
/// scope explicit before the definition reaches the generic registry.
final class MusicWorkspaceFieldScope {
  MusicWorkspaceFieldScope(this.scope)
      : title = musicFieldForScope(MusicWorkspaceFields.title, scope),
        artist = musicFieldForScope(MusicWorkspaceFields.artist, scope),
        publisher = musicFieldForScope(MusicWorkspaceFields.publisher, scope),
        genre = musicFieldForScope(MusicWorkspaceFields.genre, scope),
        releaseCount =
            musicFieldForScope(MusicWorkspaceFields.releaseCount, scope),
        aggregateListenCount = musicFieldForScope(
            MusicWorkspaceFields.aggregateListenCount, scope),
        aggregateLastListened = musicFieldForScope(
            MusicWorkspaceFields.aggregateLastListened, scope),
        listenedReleaseCount = musicFieldForScope(
            MusicWorkspaceFields.listenedReleaseCount, scope),
        listenCount =
            musicFieldForScope(MusicWorkspaceFields.listenCount, scope),
        lastListened =
            musicFieldForScope(MusicWorkspaceFields.lastListened, scope),
        releaseDate =
            musicFieldForScope(MusicWorkspaceFields.releaseDate, scope),
        trackCount = musicFieldForScope(MusicWorkspaceFields.trackCount, scope),
        barcode = musicFieldForScope(MusicWorkspaceFields.barcode, scope),
        condition = musicFieldForScope(MusicWorkspaceFields.condition, scope),
        location = musicFieldForScope(MusicWorkspaceFields.location, scope),
        pricePaid = musicFieldForScope(MusicWorkspaceFields.pricePaid, scope),
        status = musicFieldForScope(MusicWorkspaceFields.status, scope),
        cover = musicFieldForScope(MusicWorkspaceFields.cover, scope),
        rating = musicFieldForScope(MusicWorkspaceFields.rating, scope),
        wishlist = musicFieldForScope(MusicWorkspaceFields.wishlist, scope),
        updatedAt = musicFieldForScope(MusicWorkspaceFields.updatedAt, scope),
        addedAt = musicFieldForScope(MusicWorkspaceFields.addedAt, scope),
        catalogNumber =
            musicFieldForScope(MusicWorkspaceFields.catalogNumber, scope),
        format = musicFieldForScope(MusicWorkspaceFields.format, scope),
        releaseType =
            musicFieldForScope(MusicWorkspaceFields.releaseType, scope),
        releaseStatus =
            musicFieldForScope(MusicWorkspaceFields.releaseStatus, scope),
        language = musicFieldForScope(MusicWorkspaceFields.language, scope),
        packaging = musicFieldForScope(MusicWorkspaceFields.packaging, scope),
        boxSet = musicFieldForScope(MusicWorkspaceFields.boxSet, scope),
        country = musicFieldForScope(MusicWorkspaceFields.country, scope),
        discCount = musicFieldForScope(MusicWorkspaceFields.discCount, scope),
        signedBy = musicFieldForScope(MusicWorkspaceFields.signedBy, scope),
        grade = musicFieldForScope(MusicWorkspaceFields.grade, scope),
        storage = musicFieldForScope(MusicWorkspaceFields.storage, scope),
        purchaseDate =
            musicFieldForScope(MusicWorkspaceFields.purchaseDate, scope),
        marketValue =
            musicFieldForScope(MusicWorkspaceFields.marketValue, scope),
        indexNumber =
            musicFieldForScope(MusicWorkspaceFields.indexNumber, scope),
        lastCleaned =
            musicFieldForScope(MusicWorkspaceFields.lastCleaned, scope);

  final LibraryEntityScope scope;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      title;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      artist;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      publisher;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      genre;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, num?>
      releaseCount;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, num?>
      aggregateListenCount;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
      aggregateLastListened;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, num?>
      listenedReleaseCount;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, num?>
      listenCount;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
      lastListened;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
      releaseDate;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, num?>
      trackCount;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      barcode;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      condition;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      location;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>
      pricePaid;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      status;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      cover;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>
      rating;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, bool>
      wishlist;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime>
      updatedAt;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
      addedAt;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      catalogNumber;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      format;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      releaseType;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      releaseStatus;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      language;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      packaging;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      boxSet;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      country;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, num?>
      discCount;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      signedBy;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      grade;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      storage;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
      purchaseDate;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>
      marketValue;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>
      indexNumber;
  final LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
      lastCleaned;
}

LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, TValue>
    musicFieldForScope<TValue>(
  LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, TValue> field,
  LibraryEntityScope scope,
) {
  return LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, TValue>(
    id: field.id,
    label: field.label,
    getValue: field.getValue,
    entityScope: scope,
    origin: field.origin,
    cellValue: field.cellValue,
    sortable: field.sortable,
    groupable: field.groupable,
  );
}

MusicWorkspaceFieldScope musicWorkspaceFieldsForScope(
  LibraryEntityScope scope,
) =>
    MusicWorkspaceFieldScope(scope);

LibraryOwnedGroupBucketValueMutator musicOwnedConditionBucketValueMutator() {
  return (item, currentLabel, {String? replacement}) {
    if (item is! LibraryOwnedItemDispatch ||
        item.kind != CatalogMediaKind.music ||
        item.value is! MusicOwnedItem) {
      return null;
    }
    final owned = item.value as MusicOwnedItem;
    if (owned.condition?.trim() != currentLabel.trim()) return null;
    final next = replacement?.trim();
    return UpdateOwnedItemCommand(
      ownedRef: OwnedItemRef(
        kind: CatalogMediaKind.music,
        id: OwnedItemId(owned.id.value),
      ),
      payload: MusicOwnedItemUpdatePayload(
        targetRef: const Patch<CatalogEntityRef?>.unchanged(),
        quantity: const Patch.unchanged(),
        condition: next == null || next.isEmpty
            ? const Patch.clear()
            : Patch.set(next),
        grade: const Patch.unchanged(),
        purchaseDate: const Patch.unchanged(),
        pricePaidCents: const Patch.unchanged(),
        currency: const Patch.unchanged(),
        personalNotes: const Patch.unchanged(),
        locationId: const Patch.unchanged(),
        purchaseStore: const Patch.unchanged(),
        collectionStatus: const Patch.unchanged(),
        isDigital: const Patch.unchanged(),
        tags: const Patch.unchanged(),
        soldAt: const Patch.unchanged(),
        sellPriceCents: const Patch.unchanged(),
        soldTo: const Patch.unchanged(),
        marketValueCents: const Patch.unchanged(),
        indexNumber: const Patch.unchanged(),
        details: const Patch.unchanged(),
      ),
    );
  };
}
