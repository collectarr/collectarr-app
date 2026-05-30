import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_panel.dart';
import 'package:flutter/material.dart';

Widget buildComicLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return ComicLibraryEditDialog(request: request);
}

class ComicLibraryEditDialog extends StatelessWidget {
  const ComicLibraryEditDialog({
    super.key,
    required this.request,
  });

  final LibraryEditDialogRequest request;

  @override
  Widget build(BuildContext context) {
    final panelKey = GlobalKey();
    return Dialog(
      child: SizedBox(
        width: 980,
        height: 680,
        child: Column(
          children: [
            Expanded(child: ComicEditPanel(key: panelKey)),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final state = panelKey.currentState as dynamic?;
                      final map = state?.toMap?.call() as Map<String, dynamic>?;
                      if (map == null) {
                        Navigator.of(context).pop(null);
                        return;
                      }

                      final updatedPublishing = CatalogPublishingDetails(
                        imprint: emptyToNull(map['imprint'] ?? ''),
                        seriesGroup: emptyToNull(map['seriesGroup'] ?? ''),
                      );

                      final updatedItem = request.item.copyWith(
                        barcode: emptyToNull(map['barcode'] ?? ''),
                        variant: emptyToNull(map['variant'] ?? ''),
                        publisher: emptyToNull(map['publisher'] ?? ''),
                        releaseDate: parseDate(map['releaseDate'] ?? ''),
                        releaseYear: parseInt(map['year'] ?? ''),
                        publishing: updatedPublishing.hasData ? updatedPublishing : null,
                        creators: (map['creators'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? request.item.creators,
                        characters: (map['characters'] as List<dynamic>?)?.cast<String>() ?? request.item.characters,
                      );

                      final personal = request.ownedItem == null
                          ? null
                          : LibraryPersonalEditSelection(
                              anchorType: request.ownedItem?.anchorType ?? PersonalItemAnchorType.item.apiValue,
                              editionId: request.ownedItem?.editionId,
                              variantId: request.ownedItem?.variantId,
                              bundleReleaseId: request.ownedItem?.bundleReleaseId,
                              condition: null,
                              grade: emptyToNull(map['grade'] ?? ''),
                              purchaseDate: parseDate(map['purchaseDate'] ?? ''),
                              pricePaidCents: parseMoneyCents(map['purchasePrice'] ?? ''),
                              currency: emptyToNull(map['purchaseCurrency'] ?? ''),
                              personalNotes: emptyToNull(map['summary'] ?? ''),
                              quantity: request.ownedItem?.quantity ?? 1,
                              locationId: null,
                              locationChanged: false,
                              tags: emptyToNull(map['tags'] ?? ''),
                            );

                      final selection = LibraryEditSelection(
                        item: updatedItem,
                        personal: personal,
                        customFieldEdits: {},
                        itemImageEdits: [],
                      );

                      Navigator.of(context).pop(selection);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}