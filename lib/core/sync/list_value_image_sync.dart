import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:uuid/uuid.dart';

/// Sync entity carrying an image loaded for a list value.
const listValueImageEntityType = 'list_value_image';

/// The largest image Sync accepts; its protocol contract states the same.
const maxSyncedListValueImageBytes = 2 * 1024 * 1024;

/// The same list value has the same id on every device, so devices that load
/// an image for it replace each other's instead of keeping two.
String listValueImageSyncId(String list, String valueKey) =>
    const Uuid().v5(Namespace.url.value, '$list\n$valueKey');

SyncChange listValueImageChange({
  required String list,
  required String valueKey,
  required String value,
  Uint8List? image,
}) =>
    SyncChange(
      id: const Uuid().v4(),
      entityType: listValueImageEntityType,
      entityId: listValueImageSyncId(list, valueKey),
      action: image == null ? 'delete' : 'upsert',
      payload: {
        'list_key': list,
        'value': value,
        if (image != null) 'image': base64Encode(image),
      },
      clientChangedAt: DateTime.now().toUtc(),
    );
