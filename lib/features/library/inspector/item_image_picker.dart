import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

const _itemImageUuid = Uuid();

const itemImageTypeLabels = {
  'front_cover': 'Front Cover',
  'back_cover': 'Back Cover',
  'auxiliary': 'Photos',
};

Future<String?> pickAndStoreOwnedItemImage({
  required BuildContext context,
  required LocalDatabase db,
  required String ownedItemId,
  String? imageType,
}) async {
  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (picked == null || !context.mounted) {
      return null;
    }

    final selectedType = imageType ??
        await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Image type'),
            children: [
              for (final entry in itemImageTypeLabels.entries)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, entry.key),
                  child: Text(entry.value),
                ),
            ],
          ),
        );
    if (selectedType == null || !context.mounted) {
      return null;
    }

    final bytes = await picked.readAsBytes();
    final base64Data = base64Encode(bytes);

    await ItemImagesCacheRepository(db).upsert(
      id: _itemImageUuid.v4(),
      ownedItemId: ownedItemId,
      imageType: selectedType,
      imageData: base64Data,
    );

    if (!context.mounted) {
      return selectedType;
    }
    final label = itemImageTypeLabels[selectedType] ?? 'Image';
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(content: Text('$label saved for this item.')),
    );
    return selectedType;
  } on MissingPluginException {
    if (!context.mounted) {
      return null;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Image picker is not available in this environment.'),
      ),
    );
    return null;
  } on PlatformException {
    if (!context.mounted) {
      return null;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Could not open the image picker right now.'),
      ),
    );
    return null;
  }
}