import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';

@immutable
sealed class CollectionEvent {
  const CollectionEvent();
}

final class LibraryEntryAdded extends CollectionEvent {
  const LibraryEntryAdded(this.libraryEntryRef);
  final LibraryEntryRef libraryEntryRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryEntryAdded &&
          runtimeType == other.runtimeType &&
          libraryEntryRef == other.libraryEntryRef;

  @override
  int get hashCode => libraryEntryRef.hashCode;
}

final class LibraryEntryUpdated extends CollectionEvent {
  const LibraryEntryUpdated(this.libraryEntryRef);
  final LibraryEntryRef libraryEntryRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryEntryUpdated &&
          runtimeType == other.runtimeType &&
          libraryEntryRef == other.libraryEntryRef;

  @override
  int get hashCode => libraryEntryRef.hashCode;
}

final class LibraryEntryRemoved extends CollectionEvent {
  const LibraryEntryRemoved(this.libraryEntryRef);
  final LibraryEntryRef libraryEntryRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryEntryRemoved &&
          runtimeType == other.runtimeType &&
          libraryEntryRef == other.libraryEntryRef;

  @override
  int get hashCode => libraryEntryRef.hashCode;
}

final class CatalogItemChanged extends CollectionEvent {
  const CatalogItemChanged(this.catalogRef);
  final CatalogItemRef catalogRef;

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
  const MetadataOverrideChanged(this.libraryEntryRef);
  final LibraryEntryRef libraryEntryRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetadataOverrideChanged &&
          runtimeType == other.runtimeType &&
          libraryEntryRef == other.libraryEntryRef;

  @override
  int get hashCode => libraryEntryRef.hashCode;
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
