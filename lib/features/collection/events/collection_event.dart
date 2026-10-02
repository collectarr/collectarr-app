import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';

@immutable
sealed class CollectionEvent {
  const CollectionEvent();
}

final class CollectionItemAdded extends CollectionEvent {
  const CollectionItemAdded(this.collectionItemRef);
  final CollectionItemRef collectionItemRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionItemAdded &&
          runtimeType == other.runtimeType &&
          collectionItemRef == other.collectionItemRef;

  @override
  int get hashCode => collectionItemRef.hashCode;
}

final class CollectionItemUpdated extends CollectionEvent {
  const CollectionItemUpdated(this.collectionItemRef);
  final CollectionItemRef collectionItemRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionItemUpdated &&
          runtimeType == other.runtimeType &&
          collectionItemRef == other.collectionItemRef;

  @override
  int get hashCode => collectionItemRef.hashCode;
}

final class CollectionItemRemoved extends CollectionEvent {
  const CollectionItemRemoved(this.collectionItemRef);
  final CollectionItemRef collectionItemRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionItemRemoved &&
          runtimeType == other.runtimeType &&
          collectionItemRef == other.collectionItemRef;

  @override
  int get hashCode => collectionItemRef.hashCode;
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
  final CatalogItemRef catalogRef;

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
  final CatalogItemRef catalogRef;

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
