import 'package:flutter/foundation.dart';

@immutable
sealed class CollectionEvent {
  const CollectionEvent();
}

final class OwnedItemChanged extends CollectionEvent {
  const OwnedItemChanged(this.ownedItemId);
  final String ownedItemId;
}

final class WishlistChanged extends CollectionEvent {
  const WishlistChanged();
}

final class TrackingChanged extends CollectionEvent {
  const TrackingChanged();
}

final class WatchSessionChanged extends CollectionEvent {
  const WatchSessionChanged();
}

final class MetadataOverrideChanged extends CollectionEvent {
  const MetadataOverrideChanged();
}

final class CustomEpisodeChanged extends CollectionEvent {
  const CustomEpisodeChanged();
}
