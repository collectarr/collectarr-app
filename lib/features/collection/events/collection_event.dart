import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';

@immutable
sealed class CollectionEvent {
  const CollectionEvent();
}

final class OwnedItemAdded extends CollectionEvent {
  const OwnedItemAdded(this.ownedRef);
  final OwnedItemRef ownedRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedItemAdded &&
          runtimeType == other.runtimeType &&
          ownedRef == other.ownedRef;

  @override
  int get hashCode => ownedRef.hashCode;
}

final class OwnedItemUpdated extends CollectionEvent {
  const OwnedItemUpdated(this.ownedRef);
  final OwnedItemRef ownedRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedItemUpdated &&
          runtimeType == other.runtimeType &&
          ownedRef == other.ownedRef;

  @override
  int get hashCode => ownedRef.hashCode;
}

final class OwnedItemRemoved extends CollectionEvent {
  const OwnedItemRemoved(this.ownedRef);
  final OwnedItemRef ownedRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedItemRemoved &&
          runtimeType == other.runtimeType &&
          ownedRef == other.ownedRef;

  @override
  int get hashCode => ownedRef.hashCode;
}

final class CatalogItemChanged extends CollectionEvent {
  const CatalogItemChanged(this.catalogRef);
  final CatalogEntityRef catalogRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogItemChanged &&
          runtimeType == other.runtimeType &&
          catalogRef == other.catalogRef;

  @override
  int get hashCode => catalogRef.hashCode;
}

final class WishlistChanged extends CollectionEvent {
  const WishlistChanged(this.catalogRef);
  final CatalogEntityRef catalogRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistChanged &&
          runtimeType == other.runtimeType &&
          catalogRef == other.catalogRef;

  @override
  int get hashCode => catalogRef.hashCode;
}

final class TrackingChanged extends CollectionEvent {
  const TrackingChanged();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingChanged && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class WatchSessionChanged extends CollectionEvent {
  const WatchSessionChanged();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchSessionChanged && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class MetadataOverrideChanged extends CollectionEvent {
  const MetadataOverrideChanged(this.catalogRef);
  final CatalogEntityRef catalogRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetadataOverrideChanged &&
          runtimeType == other.runtimeType &&
          catalogRef == other.catalogRef;

  @override
  int get hashCode => catalogRef.hashCode;
}

final class CustomEpisodeChanged extends CollectionEvent {
  const CustomEpisodeChanged();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomEpisodeChanged && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
