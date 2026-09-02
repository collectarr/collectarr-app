import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

typedef LibraryGroupBucketValueMutator = LibraryMetadataItem? Function(
  LibraryMetadataItem item,
  String currentLabel, {
  String? replacement,
});

typedef LibraryOwnedGroupBucketValueMutator
    = UpdateOwnedItemCommand<OwnedDetailsDraft>? Function(
  OwnedItem item,
  String currentLabel, {
  String? replacement,
});

LibraryGroupBucketValueMutator libraryStringBucketValueMutator(
  String payloadKey, {
  Iterable<String> mirrorKeys = const [],
  String? nestedValueKey,
}) {
  return (item, currentLabel, {String? replacement}) {
    final payload = Map<String, dynamic>.from(
      item.kindMetadata.toSyncPayload(),
    );
    final keys = <String>{payloadKey, ...mirrorKeys};
    if (nestedValueKey != null) {
      keys.add(nestedValueKey);
    }
    final next = replacement?.trim();
    var changed = false;
    for (final key in keys) {
      if (payload[key]?.toString().trim() != currentLabel.trim()) {
        continue;
      }
      changed = true;
      _setOrRemoveStringValue(payload, key, next);
    }

    if (nestedValueKey != null) {
      final rawPub = payload['publishing'];
      if (rawPub is Map) {
        final publishing = Map<String, dynamic>.from(rawPub);
        if (publishing[nestedValueKey]?.toString().trim() ==
            currentLabel.trim()) {
          changed = true;
          _setOrRemoveStringValue(publishing, nestedValueKey, next);
          if (publishing.isEmpty) {
            payload.remove('publishing');
          } else {
            payload['publishing'] = publishing;
          }
        }
      }
    }

    if (!changed) {
      return null;
    }
    return _libraryMetadataItemWithPayload(item, payload);
  };
}

LibraryGroupBucketValueMutator libraryStringListBucketValueMutator(
  String payloadKey, {
  Iterable<String> scalarMirrorKeys = const [],
}) {
  return (item, currentLabel, {String? replacement}) {
    final payload = Map<String, dynamic>.from(
      item.kindMetadata.toSyncPayload(),
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
    return _libraryMetadataItemWithPayload(item, payload);
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

LibraryMetadataItem _libraryMetadataItemWithPayload(
  LibraryMetadataItem item,
  Map<String, dynamic> payload,
) {
  return LibraryMetadataItem(
    identity: item.identity,
    kindMetadata: LibraryKindMetadataDecoders.decode(item.mediaKind, payload),
  );
}

LibraryOwnedGroupBucketValueMutator libraryOwnedConditionBucketValueMutator() {
  return (item, currentLabel, {String? replacement}) {
    if (item.condition?.trim() != currentLabel.trim()) {
      return null;
    }
    final next = replacement?.trim();
    return UpdateOwnedItemCommand<OwnedDetailsDraft>(
      ownedItemId: item.id,
      condition:
          next == null || next.isEmpty ? const Patch.clear() : Patch.set(next),
    );
  };
}
