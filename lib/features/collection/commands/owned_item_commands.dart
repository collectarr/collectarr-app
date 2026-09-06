import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter/foundation.dart';

export 'package:collectarr_app/features/library/config/owned_details_draft.dart';

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

OwnedDetailsDraft defaultDetailsDraftForKind(CatalogMediaKind kind) {
  return libraryKindRuntimeForKind(kind).defaultOwnedDetailsDraft();
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
