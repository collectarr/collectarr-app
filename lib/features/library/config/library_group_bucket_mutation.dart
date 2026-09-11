import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';

typedef LibraryGroupBucketValueMutator = CatalogImportSnapshot? Function(
  LibraryWorkspaceSource source,
  String currentLabel, {
  String? replacement,
});

typedef LibraryOwnedGroupBucketValueMutator = UpdateOwnedItemCommand? Function(
  Object item,
  String currentLabel, {
  String? replacement,
});

LibraryGroupBucketValueMutator libraryCatalogStringBucketValueMutator(
  Iterable<String> payloadKeys, {
  String? nestedContainerKey,
  String? nestedValueKey,
}) {
  return (source, currentLabel, {String? replacement}) {
    final item = source.catalogTransport;
    if (item == null) return null;
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

LibraryGroupBucketValueMutator libraryCatalogStringListBucketValueMutator(
  String payloadKey, {
  Iterable<String> scalarMirrorKeys = const [],
}) {
  return (source, currentLabel, {String? replacement}) {
    final item = source.catalogTransport;
    if (item == null) return null;
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
  LibraryAddCatalogTransport item,
  Map<String, dynamic> payload,
) {
  return CatalogImportSnapshot.fromJson({
    'id': item.id,
    'kind': item.mediaKind.apiValue,
    ...payload,
  });
}
