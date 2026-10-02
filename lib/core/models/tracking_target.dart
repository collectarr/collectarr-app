import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class TrackingTarget {
  const TrackingTarget();

  const factory TrackingTarget.catalog(CatalogEntityRef ref) =
      CatalogTrackingTarget;
  const factory TrackingTarget.owned(CollectionItemRef collectionItemRef) =
      CollectionItemTrackingTarget;
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

final class CollectionItemTrackingTarget extends TrackingTarget {
  const CollectionItemTrackingTarget(this.collectionItemRef);
  final CollectionItemRef collectionItemRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionItemTrackingTarget &&
          runtimeType == other.runtimeType &&
          collectionItemRef == other.collectionItemRef;

  @override
  int get hashCode => collectionItemRef.hashCode;
}
