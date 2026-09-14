import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class TrackingTarget {
  const TrackingTarget();

  const factory TrackingTarget.catalog(CatalogEntityRef ref) =
      CatalogTrackingTarget;
  const factory TrackingTarget.owned(OwnedItemRef ownedRef) =
      OwnedItemTrackingTarget;
}

final class CatalogTrackingTarget extends TrackingTarget {
  const CatalogTrackingTarget(this.ref);
  final CatalogEntityRef ref;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogTrackingTarget &&
          runtimeType == other.runtimeType &&
          ref == other.ref;

  @override
  int get hashCode => ref.hashCode;
}

final class OwnedItemTrackingTarget extends TrackingTarget {
  const OwnedItemTrackingTarget(this.ownedRef);
  final OwnedItemRef ownedRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedItemTrackingTarget &&
          runtimeType == other.runtimeType &&
          ownedRef == other.ownedRef;

  @override
  int get hashCode => ownedRef.hashCode;
}
