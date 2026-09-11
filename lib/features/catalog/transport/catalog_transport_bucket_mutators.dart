import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

/// Structural mutation contract for editing a bucket-backed catalog value.
///
/// The caller supplies an already selected schema-v1 catalog transport. The
/// implementation only performs payload mechanics; field meaning and the
/// payload keys remain owned by the kind that registers the mutator.
typedef CatalogTransportBucketValueMutator = CatalogImportSnapshot? Function(
  CatalogSearchCandidate source,
  String currentLabel, {
  String? replacement,
});

CatalogTransportBucketValueMutator catalogTransportStringBucketValueMutator(
  Iterable<String> payloadKeys, {
  String? nestedContainerKey,
  String? nestedValueKey,
}) {
  return (item, currentLabel, {String? replacement}) {
    final payload = item.mapTransport(
      (transport) => Map<String, dynamic>.from(transport.payload),
    );
    final keys = payloadKeys.toSet();
    final next = replacement?.trim();
    var changed = false;
    for (final key in keys) {
      if (payload[key]?.toString().trim() != currentLabel.trim()) {
        continue;
      }
      changed = true;
      _setOrRemoveStringValue(payload, key, next);
    }

    final nestedKey = nestedContainerKey;
    if (nestedValueKey != null && nestedKey != null) {
      final rawNested = payload[nestedKey];
      if (rawNested is Map) {
        final nested = Map<String, dynamic>.from(rawNested);
        if (nested[nestedValueKey]?.toString().trim() == currentLabel.trim()) {
          changed = true;
          _setOrRemoveStringValue(nested, nestedValueKey, next);
          if (nested.isEmpty) {
            payload.remove(nestedKey);
          } else {
            payload[nestedKey] = nested;
          }
        }
      }
    }

    if (!changed) {
      return null;
    }
    return _catalogSnapshotWithPayload(item, payload);
  };
}

CatalogTransportBucketValueMutator catalogTransportStringListBucketValueMutator(
  String payloadKey, {
  Iterable<String> scalarMirrorKeys = const [],
}) {
  return (item, currentLabel, {String? replacement}) {
    final payload = item.mapTransport(
      (transport) => Map<String, dynamic>.from(transport.payload),
    );
    final rawValues = payload[payloadKey];
    final current = currentLabel.trim();
    final next = replacement?.trim();
    var changed = false;
    if (rawValues is Iterable) {
      final values = [
        for (final rawValue in rawValues) rawValue.toString().trim(),
      ];
      final wholeListMatches =
          values.length > 1 && values.join(', ') == current;
      changed = wholeListMatches;
      final nextValues = <String>[];
      final seen = <String>{};
      if (wholeListMatches) {
        if (next != null && next.isNotEmpty) {
          nextValues.add(next);
        }
      } else {
        for (final value in values) {
          if (value != current) {
            if (value.isNotEmpty && seen.add(value.toLowerCase())) {
              nextValues.add(value);
            }
            continue;
          }
          changed = true;
          if (next != null && next.isNotEmpty && seen.add(next.toLowerCase())) {
            nextValues.add(next);
          }
        }
      }

      if (changed) {
        if (nextValues.isEmpty) {
          payload.remove(payloadKey);
        } else {
          payload[payloadKey] = List<String>.unmodifiable(nextValues);
        }
      }
    }

    for (final scalarKey in scalarMirrorKeys) {
      if (payload[scalarKey]?.toString().trim() != current) {
        continue;
      }
      changed = true;
      _setOrRemoveStringValue(payload, scalarKey, next);
    }
    if (!changed) {
      return null;
    }
    return _catalogSnapshotWithPayload(item, payload);
  };
}

void _setOrRemoveStringValue(
  Map<String, dynamic> payload,
  String key,
  String? value,
) {
  if (value == null || value.isEmpty) {
    payload.remove(key);
  } else {
    payload[key] = value;
  }
}

CatalogImportSnapshot _catalogSnapshotWithPayload(
  CatalogSearchCandidate item,
  Map<String, dynamic> payload,
) {
  return CatalogImportSnapshot.fromJson({
    'id': item.id,
    'kind': item.mediaKind.apiValue,
    ...payload,
  });
}
