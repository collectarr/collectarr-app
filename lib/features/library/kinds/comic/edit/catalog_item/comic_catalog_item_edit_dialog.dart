import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/catalog_item/comic_catalog_item_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

Widget buildComicCatalogItemLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _ComicCatalogItemEditDialog(request: request);

class _ComicCatalogItemEditDialog extends StatefulWidget {
  const _ComicCatalogItemEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_ComicCatalogItemEditDialog> createState() =>
      _ComicCatalogItemEditDialogState();
}

class _ComicCatalogItemEditDialogState
    extends State<_ComicCatalogItemEditDialog> {
  late final ComicCatalogItem _media;
  late final ComicCatalogItemFormValues _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.kindCapability
        .mapTransport((transport) => transport);
    _media = ComicCatalogItem.fromJson(transport.payload);
    _draft = comicCatalogItemFormValuesFrom(_media);
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<ComicCatalogItem, ComicCatalogItemFormValues>(
        schema: comicCatalogItemEditSchema,
        model: _media,
        draft: _draft,
        title: comicCatalogItemEditSchema.title?.call(_media) ?? 'Edit comic',
        icon: widget.request.type.identity.icon,
        mediaKind: widget.request.type.kind.apiValue,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_comic_catalog_item',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _media.toJson(),
          proposedFields: comicCatalogItemFromFormValues(
            original: _media,
            values: _draft,
          ).toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) async {
          final updatedMedia = comicCatalogItemFromFormValues(
            original: _media,
            values: _draft,
          );
          final updated = widget.request.kindItem.kindCapability.mapTransport(
            (transport) => CatalogSearchCandidate.fromItem(
              transport.replacingKindData(updatedMedia),
            ),
          );
          await commitLibraryEdit(
            context,
            LibraryEditSelection(kindItem: updated),
          );
        },
      );
}
