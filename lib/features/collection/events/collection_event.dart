import 'package:flutter/foundation.dart';

@immutable
sealed class CollectionEvent {
  const CollectionEvent();
}

final class OwnedItemAdded extends CollectionEvent {
  const OwnedItemAdded(this.ownedItemId);
  final String ownedItemId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedItemAdded &&
          runtimeType == other.runtimeType &&
          ownedItemId == other.ownedItemId;

  @override
  int get hashCode => ownedItemId.hashCode;
}

final class OwnedItemUpdated extends CollectionEvent {
  const OwnedItemUpdated(this.ownedItemId);
  final String ownedItemId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedItemUpdated &&
          runtimeType == other.runtimeType &&
          ownedItemId == other.ownedItemId;

  @override
  int get hashCode => ownedItemId.hashCode;
}

final class OwnedItemRemoved extends CollectionEvent {
  const OwnedItemRemoved(this.ownedItemId);
  final String ownedItemId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedItemRemoved &&
          runtimeType == other.runtimeType &&
          ownedItemId == other.ownedItemId;

  @override
  int get hashCode => ownedItemId.hashCode;
}

final class CatalogItemChanged extends CollectionEvent {
  const CatalogItemChanged(this.catalogItemId);
  final String catalogItemId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogItemChanged &&
          runtimeType == other.runtimeType &&
          catalogItemId == other.catalogItemId;

  @override
  int get hashCode => catalogItemId.hashCode;
}

final class WishlistChanged extends CollectionEvent {
  const WishlistChanged(this.catalogItemId);
  final String catalogItemId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistChanged &&
          runtimeType == other.runtimeType &&
          catalogItemId == other.catalogItemId;

  @override
  int get hashCode => catalogItemId.hashCode;
}

final class TrackingChanged extends CollectionEvent {
  const TrackingChanged(this.trackingEntryId);
  final String trackingEntryId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingChanged &&
          runtimeType == other.runtimeType &&
          trackingEntryId == other.trackingEntryId;

  @override
  int get hashCode => trackingEntryId.hashCode;
}

final class WatchSessionChanged extends CollectionEvent {
  const WatchSessionChanged(this.watchSessionId);
  final String watchSessionId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchSessionChanged &&
          runtimeType == other.runtimeType &&
          watchSessionId == other.watchSessionId;

  @override
  int get hashCode => watchSessionId.hashCode;
}

final class MetadataOverrideChanged extends CollectionEvent {
  const MetadataOverrideChanged(this.itemId);
  final String itemId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetadataOverrideChanged &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId;

  @override
  int get hashCode => itemId.hashCode;
}

final class CustomEpisodeChanged extends CollectionEvent {
  const CustomEpisodeChanged(this.customEpisodeId);
  final String customEpisodeId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomEpisodeChanged &&
          runtimeType == other.runtimeType &&
          customEpisodeId == other.customEpisodeId;

  @override
  int get hashCode => customEpisodeId.hashCode;
}
